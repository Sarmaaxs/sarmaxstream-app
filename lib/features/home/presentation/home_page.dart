import 'package:flutter/material.dart';

import '../../../core/api/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../movies/domain/media_item.dart';
import '../../movies/presentation/media_widgets.dart';
import '../../youtube/domain/youtube_video.dart';
import '../../youtube/presentation/youtube_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onNavigate});

  /// Switches the app to another tab (1 movies, 2 YouTube, 3 music).
  final ValueChanged<int> onNavigate;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<MediaItem>> _trending = tmdbApi.list('trending/all/week');
  late Future<List<YoutubeVideo>> _videos = youtubeApi.videos();
  int _generation = 0; // changes on refresh so the rows load again

  void _reload() => setState(() {
        _generation++;
        _trending = tmdbApi.list('trending/all/week');
        _videos = youtubeApi.videos();
      });

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        color: AppTheme.lime,
        onRefresh: () async => _reload(),
        child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: AppHeader()),
              SliverToBoxAdapter(child: _Hero(future: _trending)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: Row(children: [
                    _Shortcut(
                        icon: Icons.movie_outlined,
                        label: 'Movies & TV',
                        onTap: () => widget.onNavigate(1)),
                    const SizedBox(width: 10),
                    _Shortcut(
                        icon: Icons.smart_display_outlined,
                        label: 'YouTube',
                        onTap: () => widget.onNavigate(2)),
                    const SizedBox(width: 10),
                    _Shortcut(
                        icon: Icons.headphones_outlined,
                        label: 'Music',
                        onTap: () => widget.onNavigate(3)),
                  ]),
                ),
              ),
              SliverToBoxAdapter(
                  child: MediaRow(
                      key: ValueKey('trending$_generation'),
                      title: 'Trending now',
                      loader: () => _trending)),
              SliverToBoxAdapter(
                  child: MediaRow(
                      key: ValueKey('popular$_generation'),
                      title: 'Popular movies',
                      loader: () => tmdbApi.list('movie/popular', type: 'movie'))),
              SliverToBoxAdapter(child: _VideoStrip(future: _videos, onRetry: _reload)),
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
            ]),
      );
}

class _Hero extends StatelessWidget {
  const _Hero({required this.future});
  final Future<List<MediaItem>> future;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(
            aspectRatio: 16 / 11,
            child: FutureBuilder<List<MediaItem>>(
              future: future,
              builder: (context, snap) {
                final items = snap.data;
                final item = items == null || items.isEmpty
                    ? null
                    : items.firstWhere((m) => m.backdrop != null,
                        orElse: () => items.first);
                if (item == null) {
                  return const ColoredBox(color: AppTheme.surface);
                }
                return InkWell(
                  onTap: () => openMedia(context, item),
                  child: Stack(fit: StackFit.expand, children: [
                    RemoteImage(url: item.backdrop ?? item.poster),
                    const DecoratedBox(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: [.35, 1],
                                colors: [Colors.transparent, Color(0xEE08080A)]))),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('TRENDING',
                            style: TextStyle(
                                color: AppTheme.lime,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.4)),
                        const SizedBox(height: 4),
                        Text(item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w800, height: 1.1)),
                        const SizedBox(height: 4),
                        Text(mediaMeta(item),
                            style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
                      ]),
                    ),
                  ]),
                );
              },
            ),
          ),
        ),
      );
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(
        child: Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTheme.radius),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(children: [
                Icon(icon, color: AppTheme.lime),
                const SizedBox(height: 6),
                Text(label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ),
      );
}

class _VideoStrip extends StatelessWidget {
  const _VideoStrip({required this.future, required this.onRetry});
  final Future<List<YoutubeVideo>> future;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => FutureBuilder<List<YoutubeVideo>>(
        future: future,
        builder: (context, snap) {
          final videos = snap.data;
          if (videos != null && videos.isEmpty) return const SizedBox.shrink();
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SectionTitle('Trending on YouTube'),
            SizedBox(
              height: 178,
              child: snap.hasError
                  ? ErrorRetry(onRetry: onRetry)
                  : videos == null
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: videos.length > 12 ? 12 : videos.length,
                          separatorBuilder: (context, i) => const SizedBox(width: 12),
                          itemBuilder: (context, i) => VideoCard(video: videos[i])),
            ),
          ]);
        },
      );
}
