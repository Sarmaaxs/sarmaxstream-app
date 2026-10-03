import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../music/presentation/music_home_page.dart';

/// Full-screen video page (YouTube videos and movie trailers).
/// Pauses the music player first, so two things never play at once.
class VideoPage extends ConsumerStatefulWidget {
  const VideoPage(
      {super.key, required this.videoId, required this.title, this.subtitle});
  final String videoId; // must be a validated 11-character YouTube id
  final String title;
  final String? subtitle;
  @override
  ConsumerState<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends ConsumerState<VideoPage> {
  late final YoutubePlayerController _yt;

  @override
  void initState() {
    super.initState();
    final music = ref.read(musicControllerProvider);
    if (music.playing && music.canToggle) music.togglePlay();
    _yt = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(showFullscreenButton: true),
    );
  }

  @override
  void dispose() {
    _yt.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => YoutubePlayerScaffold(
        controller: _yt,
        aspectRatio: 16 / 9,
        builder: (context, player) => Scaffold(
          appBar: AppBar(
              title: Text(widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
          body: ListView(children: [
            player,
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                if (widget.subtitle != null && widget.subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(widget.subtitle!,
                      style: const TextStyle(color: Colors.white54)),
                ],
              ]),
            ),
          ]),
        ),
      );
}
