import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/api/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../domain/media_item.dart';
import 'media_widgets.dart';

class MoviesPage extends StatefulWidget {
  const MoviesPage({super.key});
  @override
  State<MoviesPage> createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
  static const _movieRows = [
    ('Trending this week', 'trending/movie/week'),
    ('Popular', 'movie/popular'),
    ('Top rated', 'movie/top_rated'),
    ('Now playing', 'movie/now_playing'),
    ('Coming soon', 'movie/upcoming'),
  ];
  static const _tvRows = [
    ('Trending this week', 'trending/tv/week'),
    ('Popular', 'tv/popular'),
    ('Top rated', 'tv/top_rated'),
    ('On the air', 'tv/on_the_air'),
  ];

  final _search = TextEditingController();
  Timer? _debounce;
  String _type = 'movie';
  String _query = '';
  Future<List<MediaItem>>? _results;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    final q = value.trim();
    if (q.isEmpty) {
      setState(() {
        _query = '';
        _results = null;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      setState(() {
        _query = q;
        _results = tmdbApi.search(q);
      });
    });
  }

  void _retrySearch() => setState(() => _results = tmdbApi.search(_query));

  @override
  Widget build(BuildContext context) {
    final rows = _type == 'movie' ? _movieRows : _tvRows;
    return CustomScrollView(slivers: [
      const SliverToBoxAdapter(child: AppHeader()),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        sliver: SliverToBoxAdapter(
          child: TextField(
            controller: _search,
            onChanged: _onSearch,
            textInputAction: TextInputAction.search,
            maxLength: 100,
            buildCounter: (context,
                    {required currentLength, required isFocused, maxLength}) =>
                null,
            decoration: const InputDecoration(
                hintText: 'Search movies and shows',
                prefixIcon: Icon(Icons.search)),
          ),
        ),
      ),
      if (_query.isEmpty) ...[
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          sliver: SliverToBoxAdapter(
            child: SegmentedButton<String>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: 'movie', label: Text('Movies')),
                ButtonSegment(value: 'tv', label: Text('TV shows')),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            for (final r in rows)
              MediaRow(
                  key: ValueKey('${_type}_${r.$2}'),
                  title: r.$1,
                  loader: () => tmdbApi.list(r.$2, type: _type)),
            const SizedBox(height: 24),
          ]),
        ),
      ] else
        SliverToBoxAdapter(
          child: FutureBuilder<List<MediaItem>>(
            future: _results,
            builder: (context, snap) {
              if (snap.hasError) {
                return SizedBox(height: 220, child: ErrorRetry(onRetry: _retrySearch));
              }
              final items = snap.data;
              if (items == null) {
                return const SizedBox(
                    height: 220, child: Center(child: CircularProgressIndicator()));
              }
              if (items.isEmpty) {
                return const SizedBox(
                    height: 220,
                    child: Center(
                        child: Text('No results',
                            style: TextStyle(color: AppTheme.muted))));
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 140,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 12,
                    childAspectRatio: .5),
                itemCount: items.length,
                itemBuilder: (context, i) =>
                    PosterCard(item: items[i], width: double.infinity),
              );
            },
          ),
        ),
    ]);
  }
}
