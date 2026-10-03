import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/api/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../domain/youtube_video.dart';
import 'youtube_widgets.dart';

class YoutubePage extends StatefulWidget {
  const YoutubePage({super.key});
  @override
  State<YoutubePage> createState() => _YoutubePageState();
}

class _YoutubePageState extends State<YoutubePage> {
  final _search = TextEditingController();
  Timer? _debounce;
  String _query = '';
  late Future<List<YoutubeVideo>> _future = youtubeApi.videos();

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _load() => setState(() => _future = youtubeApi.videos(_query));

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final q = value.trim();
      if (q == _query) return;
      _query = q;
      _load();
    });
  }

  @override
  Widget build(BuildContext context) => CustomScrollView(slivers: [
        const SliverToBoxAdapter(child: AppHeader()),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          sliver: SliverToBoxAdapter(
            child: TextField(
              controller: _search,
              onChanged: _onChanged,
              onSubmitted: (v) {
                _debounce?.cancel();
                _query = v.trim();
                _load();
              },
              textInputAction: TextInputAction.search,
              maxLength: 100,
              buildCounter: (context,
                      {required currentLength, required isFocused, maxLength}) =>
                  null,
              decoration: const InputDecoration(
                  hintText: 'Search YouTube', prefixIcon: Icon(Icons.search)),
            ),
          ),
        ),
        SliverToBoxAdapter(
            child: SectionTitle(_query.isEmpty ? 'Trending' : 'Results')),
        FutureBuilder<List<YoutubeVideo>>(
          future: _future,
          builder: (context, snap) {
            if (snap.hasError) {
              return SliverFillRemaining(
                  hasScrollBody: false, child: ErrorRetry(onRetry: _load));
            }
            final videos = snap.data;
            if (videos == null) {
              return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()));
            }
            if (videos.isEmpty) {
              return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                      child: Text('No videos found',
                          style: TextStyle(color: AppTheme.muted))));
            }
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              sliver: SliverList.separated(
                itemCount: videos.length,
                separatorBuilder: (context, i) => const SizedBox(height: 20),
                itemBuilder: (context, i) => VideoTile(video: videos[i]),
              ),
            );
          },
        ),
      ]);
}
