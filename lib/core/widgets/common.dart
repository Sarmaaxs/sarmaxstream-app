import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../features/settings/presentation/settings_page.dart';
import '../theme/app_theme.dart';
import '../theme/brand_mark.dart';

/// Wordmark + settings button shown at the top of every main screen.
class AppHeader extends StatelessWidget {
  const AppHeader({super.key, this.padding = const EdgeInsets.fromLTRB(20, 16, 8, 0)});
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Padding(
        padding: padding,
        child: Row(children: [
          const Wordmark(fontSize: 26),
          const Spacer(),
          IconButton(
              tooltip: 'Settings',
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const SettingsPage())),
              icon: const Icon(Icons.settings_outlined)),
        ]),
      );
}

/// A network image that only loads when given a well-formed https URL.
class RemoteImage extends StatelessWidget {
  const RemoteImage(
      {super.key,
      required this.url,
      this.fit = BoxFit.cover,
      this.icon = Icons.movie_outlined});
  final String? url;
  final BoxFit fit;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    Widget placeholder() => ColoredBox(
        color: AppTheme.surfaceAlt,
        child: Center(child: Icon(icon, color: Colors.white24)));
    final u = url;
    if (u == null) return placeholder();
    return CachedNetworkImage(
        imageUrl: u,
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 150),
        placeholder: (context, url) => const ColoredBox(color: AppTheme.surfaceAlt),
        errorWidget: (context, url, error) => placeholder());
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
      child: Text(text,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)));
}

/// Friendly error with a retry button. Never shows technical details.
class ErrorRetry extends StatelessWidget {
  const ErrorRetry({super.key, required this.onRetry, this.message});
  final VoidCallback onRetry;
  final String? message;
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.wifi_off_rounded, color: AppTheme.muted),
            const SizedBox(height: 8),
            Text(message ?? "Couldn't load this. Check your connection.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.muted)),
            const SizedBox(height: 8),
            TextButton(onPressed: onRetry, child: const Text('Try again')),
          ]),
        ),
      );
}

String formatMinutes(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '${m}m';
  return m == 0 ? '${h}h' : '${h}h ${m}m';
}
