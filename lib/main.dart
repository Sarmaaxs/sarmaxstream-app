import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/api/api_client.dart';
import 'core/cache/local_store.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/brand_mark.dart';
import 'features/music/application/music_controller.dart';
import 'features/music/data/music_api.dart';
import 'features/music/data/music_audio_handler.dart';
import 'features/music/presentation/music_home_page.dart';

class StartupSnapshot {
  const StartupSnapshot({this.controller, this.failed = false});
  final MusicController? controller;
  final bool failed;
}

final startupSnapshot = ValueNotifier<StartupSnapshot>(const StartupSnapshot());

// Technical details go to the developer log of debug builds only.
// Users never see them, and release builds never write them to the device log.
void _reportStartupError(Object error, [StackTrace? stack]) {
  if (kDebugMode) debugPrint('Startup error: $error\n$stack');
  if (startupSnapshot.value.controller == null) {
    startupSnapshot.value = const StartupSnapshot(failed: true);
  }
}

void main() {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (details) {
      if (kDebugMode) FlutterError.presentError(details);
    };
    runApp(const BootstrapApp());
  }, (error, stack) {
    _reportStartupError(error, stack);
  });
}

class BootstrapApp extends StatefulWidget {
  const BootstrapApp({super.key});
  @override
  State<BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<BootstrapApp> {
  bool _starting = false;
  // AudioService.init may only be called once, so keep the handler for retries.
  MusicAudioHandler? _handler;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    if (_starting) return;
    _starting = true;
    startupSnapshot.value = const StartupSnapshot();
    try {
      final client = ApiClient();
      final store = await LocalStore.load().timeout(const Duration(seconds: 8));
      final session =
          await AudioSession.instance.timeout(const Duration(seconds: 8));
      await session
          .configure(const AudioSessionConfiguration.music())
          .timeout(const Duration(seconds: 8));
      final handler = _handler ??= await AudioService.init<MusicAudioHandler>(
        builder: MusicAudioHandler.new,
        config: AudioServiceConfig(
          androidNotificationChannelId: 'com.sarmax.sarmaxstream.music',
          androidNotificationChannelName: 'SarmaxStream Music',
          // "ongoing" is only allowed together with stop-foreground-on-pause.
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
        ),
      ).timeout(const Duration(seconds: 12));
      final api = MusicApi(client, store);
      unawaited(api.pruneExpired());
      final controller = MusicController(api, handler);
      startupSnapshot.value = StartupSnapshot(controller: controller);
    } catch (error, stack) {
      _reportStartupError(error, stack);
    } finally {
      _starting = false;
    }
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<StartupSnapshot>(
        valueListenable: startupSnapshot,
        builder: (context, snapshot, _) {
          if (snapshot.failed) {
            return StartupErrorScreen(onRetry: _start);
          }
          if (snapshot.controller == null) {
            return const StartupLoadingScreen();
          }
          return ProviderScope(
            overrides: [
              musicControllerProvider.overrideWithValue(snapshot.controller!)
            ],
            child: const SarmaxApp(),
          );
        },
      );
}

class StartupLoadingScreen extends StatelessWidget {
  const StartupLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: const Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BrandMark(size: 64),
                SizedBox(height: 20),
                Text('SarmaxStream',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                SizedBox(height: 18),
                CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      );
}

class StartupErrorScreen extends StatelessWidget {
  const StartupErrorScreen({super.key, required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const BrandMark(size: 58),
                    const SizedBox(height: 18),
                    const Text("Couldn't open SarmaxStream",
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    const Text('Check your internet connection and try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 22),
                    FilledButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try again')),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class SarmaxApp extends StatelessWidget {
  const SarmaxApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
      title: 'SarmaxStream',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const MusicHomePage());
}
