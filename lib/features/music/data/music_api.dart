import 'dart:convert';
import '../../../core/api/api_client.dart';
import '../../../core/cache/local_store.dart';
import '../domain/track.dart';

class MusicApi {
  MusicApi(this._client, this._store);
  final ApiClient _client;
  final LocalStore _store;

  static const _searchPrefix = 'music_search_';
  static const _resolvePrefix = 'music_resolve_';
  static const _maxQueryLength = 100;
  static const _searchFresh = Duration(minutes: 10);
  static const _searchKeep = Duration(days: 7); // stale results shown offline
  static const _resolveKeep = Duration(days: 30);

  int _ageMs(Map<String, dynamic> cached) =>
      DateTime.now().millisecondsSinceEpoch - (cached['savedAt'] as int? ?? 0);

  /// Removes old cache entries so local storage cannot grow forever.
  Future<void> pruneExpired() async {
    for (final key in _store.keys(_searchPrefix)) {
      final c = _store.json(key);
      if (c == null || _ageMs(c) > _searchKeep.inMilliseconds) {
        await _store.remove(key);
      }
    }
    for (final key in _store.keys(_resolvePrefix)) {
      final c = _store.json(key);
      if (c == null || _ageMs(c) > _resolveKeep.inMilliseconds) {
        await _store.remove(key);
      }
    }
  }

  Future<List<Track>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];
    // Cap the length: it is sent to the server and used in a cache key.
    final q = String.fromCharCodes(trimmed.runes.take(_maxQueryLength));
    final key = '$_searchPrefix${base64Url.encode(utf8.encode(q.toLowerCase()))}';
    final cached = _store.json(key);
    if (cached != null && _ageMs(cached) < _searchFresh.inMilliseconds) {
      return _tracks(cached['tracks']);
    }
    try {
      final data = await _client.postJson(
          '/api/searchMusic', {'query': q, 'mode': 'search', 'maxResults': 25});
      final tracks = _tracks(data['tracks']);
      await _store.putJson(key, {
        'savedAt': DateTime.now().millisecondsSinceEpoch,
        'tracks': tracks.map((e) => e.toJson()).toList()
      });
      return tracks;
    } catch (_) {
      if (cached != null) {
        return _tracks(cached['tracks']);
      }
      rethrow;
    }
  }

  Future<Track> resolve(Track track, {bool skipFree = false}) async {
    if (!track.isCatalog) return track;
    final key = '$_resolvePrefix${track.videoId}';
    final cached = _store.json(key);
    if (!skipFree &&
        cached != null &&
        cached['videoId'] is String &&
        (cached['videoId'] as String).isNotEmpty &&
        _ageMs(cached) < _resolveKeep.inMilliseconds) {
      return track.copyWith(
          videoId: cached['videoId'] as String,
          source: cached['source'] is String ? cached['source'] as String : null,
          catalogId: track.videoId);
    }
    final data = await _client.getJson('/api/resolve', {
      'artist': track.artist,
      'title': track.title,
      'dur': _durationSeconds(track.duration),
      if (skipFree) 'skip': 'free'
    });
    final id = data['videoId'];
    if (id is! String || id.isEmpty) {
      throw const FormatException('Invalid resolve response');
    }
    final source = data['source'] is String ? data['source'] as String : null;
    final resolved =
        track.copyWith(videoId: id, source: source, catalogId: track.videoId);
    // Also cache the fallback result, so a free stream that failed once is not
    // retried first on every play.
    await _store.putJson(key, {
      'savedAt': DateTime.now().millisecondsSinceEpoch,
      'videoId': id,
      'source': source
    });
    return resolved;
  }

  String streamUrl(Track track) => _client
      .absolute('/api/stream?id=${Uri.encodeQueryComponent(track.videoId)}');

  List<Track> _tracks(dynamic value) => (value is List ? value : const [])
      .whereType<Map>()
      .map((e) => Track.fromJson(Map<String, dynamic>.from(e)))
      .where((t) => t.videoId.isNotEmpty)
      .toList();

  int _durationSeconds(String iso) {
    final m = RegExp(r'^PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?$').firstMatch(iso);
    return (int.tryParse(m?.group(1) ?? '') ?? 0) * 3600 +
        (int.tryParse(m?.group(2) ?? '') ?? 0) * 60 +
        (int.tryParse(m?.group(3) ?? '') ?? 0);
  }
}
