import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../domain/media_item.dart';
import 'media_detail_page.dart';

void openMedia(BuildContext context, MediaItem item) => Navigator.of(context)
    .push(MaterialPageRoute<void>(builder: (_) => MediaDetailPage(item: item)));

String mediaMeta(MediaItem m) {
  final parts = <String>[
    if (m.year != null) m.year!,
    if (m.rating > 0) '★ ${m.rating.toStringAsFixed(1)}',
  ];
  return parts.join('  •  ');
}

class PosterCard extends StatelessWidget {
  const PosterCard({super.key, required this.item, this.width = 120});
  final MediaItem item;
  final double width;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          onTap: () => openMedia(context, item),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radius),
                child: AspectRatio(
                    aspectRatio: 2 / 3, child: RemoteImage(url: item.poster))),
            const SizedBox(height: 6),
            Text(item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            Text(mediaMeta(item),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
          ]),
        ),
      );
}

typedef MediaLoader = Future<List<MediaItem>> Function();

/// A titled horizontal row of posters that loads itself.
class MediaRow extends StatefulWidget {
  const MediaRow({super.key, required this.title, required this.loader});
  final String title;
  final MediaLoader loader;
  @override
  State<MediaRow> createState() => _MediaRowState();
}

class _MediaRowState extends State<MediaRow> {
  late Future<List<MediaItem>> _future = widget.loader();

  void _retry() => setState(() => _future = widget.loader());

  @override
  Widget build(BuildContext context) => FutureBuilder<List<MediaItem>>(
        future: _future,
        builder: (context, snap) {
          final items = snap.data;
          if (snap.connectionState == ConnectionState.done &&
              !snap.hasError &&
              (items == null || items.isEmpty)) {
            return const SizedBox.shrink();
          }
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SectionTitle(widget.title),
            SizedBox(
              height: 236,
              child: snap.hasError
                  ? ErrorRetry(onRetry: _retry)
                  : items == null
                      ? ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: 5,
                          separatorBuilder: (context, i) => const SizedBox(width: 12),
                          itemBuilder: (context, i) => ClipRRect(
                              borderRadius: BorderRadius.circular(AppTheme.radius),
                              child: const SizedBox(
                                  width: 120,
                                  height: 180,
                                  child: ColoredBox(color: AppTheme.surfaceAlt))))
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: items.length,
                          separatorBuilder: (context, i) => const SizedBox(width: 12),
                          itemBuilder: (context, i) => PosterCard(item: items[i])),
            ),
          ]);
        },
      );
}
