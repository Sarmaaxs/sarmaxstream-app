import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../music/domain/track.dart' show formatDuration;
import '../domain/youtube_video.dart';
import 'video_page.dart';

void openVideo(BuildContext context, YoutubeVideo v) =>
    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) =>
            VideoPage(videoId: v.id, title: v.title, subtitle: v.channel)));

class _Thumb extends StatelessWidget {
  const _Thumb(this.video);
  final YoutubeVideo video;
  @override
  Widget build(BuildContext context) {
    final length = video.duration.isEmpty ? null : formatDuration(video.duration);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radius),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(fit: StackFit.expand, children: [
          RemoteImage(url: video.safeThumbnail, icon: Icons.smart_display_outlined),
          if (length != null && length != '--:--')
            Positioned(
              right: 6,
              bottom: 6,
              child: DecoratedBox(
                decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .78),
                    borderRadius: BorderRadius.circular(5)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Text(length,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}

/// Large card used in vertical lists.
class VideoTile extends StatelessWidget {
  const VideoTile({super.key, required this.video});
  final YoutubeVideo video;
  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        onTap: () => openVideo(context, video),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _Thumb(video),
          const SizedBox(height: 8),
          Text(video.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, height: 1.25)),
          const SizedBox(height: 3),
          Text(video.channel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
        ]),
      );
}

/// Small card used in horizontal rows.
class VideoCard extends StatelessWidget {
  const VideoCard({super.key, required this.video, this.width = 220});
  final YoutubeVideo video;
  final double width;
  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          onTap: () => openVideo(context, video),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _Thumb(video),
            const SizedBox(height: 6),
            Text(video.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13, height: 1.2)),
          ]),
        ),
      );
}
