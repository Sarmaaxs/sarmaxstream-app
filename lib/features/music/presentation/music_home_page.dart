import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../application/music_controller.dart';
import '../domain/track.dart';

final musicControllerProvider =
    Provider<MusicController>((ref) => throw UnimplementedError());

class MusicHomePage extends ConsumerStatefulWidget {
  const MusicHomePage({super.key});
  @override
  ConsumerState<MusicHomePage> createState() => _MusicHomePageState();
}

/// The Music tab. The app shell provides the Scaffold, the mini player and
/// the bottom navigation.
class _MusicHomePageState extends ConsumerState<MusicHomePage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(musicControllerProvider);
    return ListenableBuilder(
        listenable: c,
        builder: (context, _) =>
            _MusicHomeContent(search: _search, controller: c));
  }
}

class _MusicHomeContent extends StatelessWidget {
  const _MusicHomeContent({required this.search, required this.controller});
  final TextEditingController search;
  final MusicController controller;

  void _onTrackTap(Track t) {
    // Tapping the song that is already loaded pauses / resumes it.
    if (controller.isActive(t) && controller.canToggle) {
      controller.togglePlay();
    } else {
      controller.playTrack(t);
    }
  }

  @override
  Widget build(BuildContext context) => CustomScrollView(slivers: [
        const SliverToBoxAdapter(child: AppHeader()),
        SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverToBoxAdapter(
                child: TextField(
                    controller: search,
                    onChanged: controller.searchChanged,
                    textInputAction: TextInputAction.search,
                    maxLength: 100,
                    buildCounter: (_,
                            {required currentLength,
                            required isFocused,
                            maxLength}) =>
                        null,
                    decoration: const InputDecoration(
                        hintText: 'What do you want to play?',
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: Icon(Icons.tune))))),
        SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 6),
            sliver: SliverToBoxAdapter(
                child: Row(children: [
              Text(controller.query.isEmpty ? 'Made for you' : 'Search results',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const Spacer(),
              TextButton(
                  onPressed: controller.query.isEmpty
                      ? null
                      : () {
                          search.clear();
                          controller.searchChanged('');
                        },
                  child: const Text('Clear'))
            ]))),
        if (controller.error != null)
          SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              sliver:
                  SliverToBoxAdapter(child: _ErrorBanner(controller.error!))),
        if (controller.loading)
          const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator())),
        if (!controller.loading && controller.results.isEmpty)
          SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(hasQuery: controller.query.trim().isNotEmpty)),
        if (!controller.loading && controller.results.isNotEmpty)
          SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              sliver: SliverList.builder(
                  itemCount: controller.results.length,
                  itemBuilder: (_, i) {
                    final t = controller.results[i];
                    final active = controller.isActive(t);
                    return TrackTile(
                        track: t,
                        active: active,
                        playing: active && controller.playing,
                        busy: controller.resolving && active,
                        onTap: () => _onTrackTap(t));
                  })),
      ]);
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasQuery});
  final bool hasQuery;
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(hasQuery ? Icons.music_off : Icons.explore_outlined,
                size: 50, color: AppTheme.lime),
            const SizedBox(height: 16),
            Text(hasQuery ? 'No tracks found' : 'Find your next repeat',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
                hasQuery
                    ? 'Try a different title or artist.'
                    : 'Search for a song to start listening.',
                style: const TextStyle(color: Colors.white54))
          ])));
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner(this.message);
  final String message;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: .14),
          borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        const Icon(Icons.info_outline, color: Colors.orange),
        const SizedBox(width: 10),
        Expanded(child: Text(message))
      ]));
}

/// Album art. Only well-formed https URLs are loaded; anything else shows a
/// placeholder instead.
class _Artwork extends StatelessWidget {
  const _Artwork({required this.url, required this.size, this.radius = 12});
  final String? url;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    Widget placeholder() => Container(
        color: AppTheme.surfaceAlt, child: const Icon(Icons.music_note));
    return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
            width: size,
            height: size,
            child: url == null
                ? placeholder()
                : CachedNetworkImage(
                    imageUrl: url!,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => placeholder())));
  }
}

class TrackTile extends StatelessWidget {
  const TrackTile(
      {super.key,
      required this.track,
      required this.active,
      required this.playing,
      required this.busy,
      required this.onTap});
  final Track track;
  final bool active;
  final bool playing;
  final bool busy;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: busy ? null : onTap,
          child: Padding(
              padding: const EdgeInsets.all(9),
              child: Row(children: [
                _Artwork(url: track.safeThumbnail, size: 60),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 5),
                      Text(
                          '${track.artist}  •  ${formatDuration(track.duration)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12))
                    ])),
                const SizedBox(width: 8),
                IconButton(
                    tooltip: playing ? 'Pause' : 'Play',
                    onPressed: busy ? null : onTap,
                    style: IconButton.styleFrom(
                        backgroundColor: active
                            ? AppTheme.lime.withValues(alpha: .16)
                            : Colors.white.withValues(alpha: .06)),
                    icon: busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Icon(playing ? Icons.pause : Icons.play_arrow,
                            color: AppTheme.lime))
              ]))));
}

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key, required this.controller});
  final MusicController controller;
  @override
  Widget build(BuildContext context) {
    final track = controller.current!;
    final ytOnly = controller.youtubeOnly != null;
    return Material(
        color: AppTheme.surface,
        // The navigation bar below already handles the bottom inset.
        child: SafeArea(
            top: false,
            bottom: false,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                child: Row(children: [
                  _Artwork(url: track.safeThumbnail, size: 42, radius: 8),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700))),
                  IconButton(
                      tooltip: 'Previous',
                      onPressed: controller.previous,
                      icon: const Icon(Icons.skip_previous)),
                  IconButton(
                      tooltip: controller.playing ? 'Pause' : 'Play',
                      onPressed: ytOnly ? null : controller.togglePlay,
                      icon: controller.resolving
                          ? const SizedBox(
                              width: 26,
                              height: 26,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2.5))
                          : Icon(
                              controller.playing
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_fill,
                              color: ytOnly ? Colors.white24 : AppTheme.lime,
                              size: 30)),
                  IconButton(
                      tooltip: 'Next',
                      onPressed: controller.next,
                      icon: const Icon(Icons.skip_next))
                ]))));
  }
}

/// Songs that exist only on YouTube play in YouTube's own embedded player.
/// (YouTube only allows this while the app is open on screen.)
/// The controller only passes a track here after checking that its id is a
/// well-formed 11-character YouTube id.
class YoutubeDock extends StatefulWidget {
  const YoutubeDock({super.key, required this.track});
  final Track track;
  @override
  State<YoutubeDock> createState() => _YoutubeDockState();
}

class _YoutubeDockState extends State<YoutubeDock> {
  late final YoutubePlayerController _yt;

  @override
  void initState() {
    super.initState();
    _yt = YoutubePlayerController.fromVideoId(
      videoId: widget.track.videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(showFullscreenButton: false),
    );
  }

  @override
  void didUpdateWidget(YoutubeDock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.track.videoId != widget.track.videoId &&
        widget.track.isYoutube) {
      _yt.loadVideoById(videoId: widget.track.videoId);
    }
  }

  @override
  void dispose() {
    _yt.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ColoredBox(
      color: Colors.black,
      child: SizedBox(
          height: 200,
          child: YoutubePlayer(controller: _yt, aspectRatio: 16 / 9)));
}
