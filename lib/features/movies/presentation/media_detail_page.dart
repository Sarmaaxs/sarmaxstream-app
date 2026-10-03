import 'package:flutter/material.dart';

import '../../../core/api/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../youtube/presentation/video_page.dart';
import '../domain/media_item.dart';
import 'media_widgets.dart';

class MediaDetailPage extends StatefulWidget {
  const MediaDetailPage({super.key, required this.item});
  final MediaItem item;
  @override
  State<MediaDetailPage> createState() => _MediaDetailPageState();
}

class _MediaDetailPageState extends State<MediaDetailPage> {
  late Future<MediaDetail> _future =
      tmdbApi.detail(widget.item.mediaType, widget.item.id);

  void _retry() => setState(
      () => _future = tmdbApi.detail(widget.item.mediaType, widget.item.id));

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 250,
          backgroundColor: AppTheme.background,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(fit: StackFit.expand, children: [
              RemoteImage(url: item.backdrop ?? item.poster),
              const DecoratedBox(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, AppTheme.background]))),
            ]),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.title,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              FutureBuilder<MediaDetail>(
                future: _future,
                builder: (context, snap) {
                  final d = snap.data;
                  final runtime = d?.runtimeMinutes;
                  final seasons = d?.seasons;
                  final trailer = d?.trailerId;
                  final meta = <String>[
                    item.isTv ? 'TV show' : 'Movie',
                    if (item.year != null) item.year!,
                    if (runtime != null) formatMinutes(runtime),
                    if (seasons != null)
                      '$seasons season${seasons == 1 ? '' : 's'}',
                    if (item.rating > 0) '★ ${item.rating.toStringAsFixed(1)}',
                  ];
                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(meta.join('  •  '),
                        style: const TextStyle(color: AppTheme.muted)),
                    if (d != null && d.tagline.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(d.tagline,
                          style: const TextStyle(
                              fontStyle: FontStyle.italic, color: AppTheme.muted)),
                    ],
                    if (d != null && d.genres.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        for (final g in d.genres) Chip(label: Text(g))
                      ]),
                    ],
                    const SizedBox(height: 16),
                    if (trailer != null)
                      FilledButton.icon(
                          onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                  builder: (_) => VideoPage(
                                      videoId: trailer,
                                      title: '${item.title} · Trailer'))),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Watch trailer'))
                    else if (snap.connectionState != ConnectionState.done)
                      const LinearProgressIndicator(minHeight: 2),
                    if (snap.hasError) ErrorRetry(onRetry: _retry),
                  ]);
                },
              ),
              const SizedBox(height: 18),
              if (item.overview.isNotEmpty)
                Text(item.overview, style: const TextStyle(height: 1.45, fontSize: 15)),
            ]),
          ),
        ),
        SliverToBoxAdapter(
          child: FutureBuilder<MediaDetail>(
            future: _future,
            builder: (context, snap) {
              final d = snap.data;
              if (d == null) return const SizedBox(height: 40);
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (d.cast.isNotEmpty) ...[
                  const SectionTitle('Cast'),
                  SizedBox(
                    height: 132,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: d.cast.length,
                      separatorBuilder: (context, i) => const SizedBox(width: 14),
                      itemBuilder: (context, i) => _CastTile(member: d.cast[i]),
                    ),
                  ),
                ],
                if (d.similar.isNotEmpty)
                  MediaRow(title: 'More like this', loader: () async => d.similar),
                const SizedBox(height: 36),
              ]);
            },
          ),
        ),
      ]),
    );
  }
}

class _CastTile extends StatelessWidget {
  const _CastTile({required this.member});
  final CastMember member;
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 84,
        child: Column(children: [
          ClipOval(
              child: SizedBox(
                  width: 72,
                  height: 72,
                  child: RemoteImage(url: member.photo, icon: Icons.person))),
          const SizedBox(height: 6),
          Text(member.name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ]),
      );
}
