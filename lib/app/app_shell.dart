import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/home/presentation/home_page.dart';
import '../features/movies/presentation/movies_page.dart';
import '../features/music/presentation/music_home_page.dart';
import '../features/youtube/presentation/youtube_page.dart';

/// Home, Movies & TV, YouTube and Music in one app, with the music mini
/// player kept above the bottom bar on every tab.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});
  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _tab = 0;
  final Set<int> _opened = {0};

  void _go(int i) => setState(() {
        _tab = i;
        _opened.add(i);
      });

  // Tabs are built the first time they are opened, so the app does not fire
  // every network request at startup.
  Widget _page(int i) {
    if (!_opened.contains(i)) return const SizedBox.shrink();
    switch (i) {
      case 0:
        return HomePage(onNavigate: _go);
      case 1:
        return const MoviesPage();
      case 2:
        return const YoutubePage();
      default:
        return const MusicHomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final music = ref.watch(musicControllerProvider);
    return PopScope(
      canPop: _tab == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _go(0);
      },
      child: ListenableBuilder(
        listenable: music,
        builder: (context, _) => Scaffold(
          body: SafeArea(
            child: IndexedStack(
                index: _tab, children: [for (var i = 0; i < 4; i++) _page(i)]),
          ),
          bottomNavigationBar: Column(mainAxisSize: MainAxisSize.min, children: [
            if (music.current != null) ...[
              if (music.youtubeOnly != null)
                YoutubeDock(
                    key: const ValueKey('yt-dock'), track: music.youtubeOnly!),
              MiniPlayer(controller: music),
            ],
            NavigationBar(
              selectedIndex: _tab,
              onDestinationSelected: _go,
              destinations: const [
                NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Home'),
                NavigationDestination(
                    icon: Icon(Icons.movie_outlined),
                    selectedIcon: Icon(Icons.movie),
                    label: 'Movies'),
                NavigationDestination(
                    icon: Icon(Icons.smart_display_outlined),
                    selectedIcon: Icon(Icons.smart_display),
                    label: 'YouTube'),
                NavigationDestination(
                    icon: Icon(Icons.headphones_outlined),
                    selectedIcon: Icon(Icons.headphones),
                    label: 'Music'),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
