final _youtubeId = RegExp(r'^[A-Za-z0-9_-]{11}$');
final _imagePath = RegExp(r'^/[A-Za-z0-9_.\-]+$');

/// Builds an https image URL, or null if the path looks wrong.
String? tmdbImage(String? path, String size) {
  if (path == null || !_imagePath.hasMatch(path)) return null;
  return 'https://image.tmdb.org/t/p/$size$path';
}

/// A movie or a TV show in a list.
class MediaItem {
  const MediaItem({
    required this.id,
    required this.mediaType,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    this.rating = 0,
    this.year,
  });

  final int id;
  final String mediaType; // 'movie' or 'tv'
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double rating;
  final String? year;

  bool get isTv => mediaType == 'tv';
  String? get poster => tmdbImage(posterPath, 'w342');
  String? get backdrop => tmdbImage(backdropPath, 'w780');

  /// Returns null for people, malformed entries, or anything that is not a
  /// movie or a show.
  static MediaItem? tryParse(Object? raw, {String? fallbackType}) {
    if (raw is! Map) return null;
    final type = '${raw['media_type'] ?? fallbackType ?? ''}';
    if (type != 'movie' && type != 'tv') return null;
    final id = raw['id'];
    if (id is! int) return null;
    final title = '${raw['title'] ?? raw['name'] ?? ''}'.trim();
    if (title.isEmpty) return null;
    final date = '${raw['release_date'] ?? raw['first_air_date'] ?? ''}';
    final vote = raw['vote_average'];
    return MediaItem(
      id: id,
      mediaType: type,
      title: title,
      overview: '${raw['overview'] ?? ''}'.trim(),
      posterPath:
          raw['poster_path'] is String ? raw['poster_path'] as String : null,
      backdropPath: raw['backdrop_path'] is String
          ? raw['backdrop_path'] as String
          : null,
      rating: vote is num ? vote.toDouble() : 0,
      year: date.length >= 4 ? date.substring(0, 4) : null,
    );
  }
}

class CastMember {
  const CastMember({required this.name, required this.role, this.photoPath});
  final String name;
  final String role;
  final String? photoPath;
  String? get photo => tmdbImage(photoPath, 'w185');
}

/// Extra information shown on a title's page.
class MediaDetail {
  const MediaDetail({
    required this.genres,
    required this.cast,
    required this.similar,
    this.tagline = '',
    this.runtimeMinutes,
    this.seasons,
    this.trailerId,
  });

  final List<String> genres;
  final List<CastMember> cast;
  final List<MediaItem> similar;
  final String tagline;
  final int? runtimeMinutes;
  final int? seasons;

  /// A well-formed YouTube video id for the trailer, if there is one.
  final String? trailerId;

  static MediaDetail parse(Map<String, dynamic> raw, String type) {
    List<Map> maps(Object? v) =>
        (v is List ? v : const []).whereType<Map>().toList();

    final genres = maps(raw['genres'])
        .map((g) => '${g['name'] ?? ''}')
        .where((g) => g.isNotEmpty)
        .toList();

    final credits = raw['credits'];
    final cast = maps(credits is Map ? credits['cast'] : null)
        .where((c) => '${c['name'] ?? ''}'.isNotEmpty)
        .take(14)
        .map((c) => CastMember(
            name: '${c['name']}',
            role: '${c['character'] ?? ''}',
            photoPath: c['profile_path'] is String
                ? c['profile_path'] as String
                : null))
        .toList();

    final sim = raw['similar'];
    final similar = (sim is Map && sim['results'] is List
            ? sim['results'] as List
            : const [])
        .map((e) => MediaItem.tryParse(e, fallbackType: type))
        .whereType<MediaItem>()
        .take(20)
        .toList();

    final vids = raw['videos'];
    final clips = maps(vids is Map ? vids['results'] : null)
        .where((v) =>
            v['site'] == 'YouTube' && _youtubeId.hasMatch('${v['key']}'))
        .toList();
    Map? pick;
    for (final test in <bool Function(Map)>[
      (v) => v['type'] == 'Trailer' && v['official'] == true,
      (v) => v['type'] == 'Trailer',
      (v) => v['type'] == 'Teaser',
    ]) {
      final hit = clips.where(test);
      if (hit.isNotEmpty) {
        pick = hit.first;
        break;
      }
    }

    int? runtime;
    final rt = raw['runtime'];
    final ert = raw['episode_run_time'];
    if (rt is int && rt > 0) {
      runtime = rt;
    } else if (ert is List && ert.isNotEmpty && ert.first is int) {
      runtime = ert.first as int;
    }

    return MediaDetail(
      genres: genres,
      cast: cast,
      similar: similar,
      tagline: '${raw['tagline'] ?? ''}'.trim(),
      runtimeMinutes: runtime,
      seasons:
          raw['number_of_seasons'] is int ? raw['number_of_seasons'] as int : null,
      trailerId: pick == null ? null : '${pick['key']}',
    );
  }
}
