import '../../../core/api/api_client.dart';
import '../domain/media_item.dart';

class _Hit {
  _Hit(this.data) : at = DateTime.now();
  final Map<String, dynamic> data;
  final DateTime at;
}

/// Movie and TV information, fetched through the SarmaxStream server.
/// The app never holds a key for it.
class TmdbApi {
  TmdbApi(this._client);
  final ApiClient _client;
  final Map<String, _Hit> _cache = {};
  static const _ttl = Duration(minutes: 10);

  Future<Map<String, dynamic>> _get(String path,
      [Map<String, dynamic> params = const {}]) async {
    final key =
        '$path?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    final hit = _cache[key];
    if (hit != null && DateTime.now().difference(hit.at) < _ttl) {
      return hit.data;
    }
    final data = await _client.getJson('/api/tmdb', {'path': path, ...params});
    if (_cache.length > 80) _cache.remove(_cache.keys.first);
    _cache[key] = _Hit(data);
    return data;
  }

  Future<List<MediaItem>> list(String path,
      {String? type, Map<String, dynamic> params = const {}}) async {
    final data = await _get(path, params);
    final results = data['results'];
    return (results is List ? results : const [])
        .map((e) => MediaItem.tryParse(e, fallbackType: type))
        .whereType<MediaItem>()
        .toList();
  }

  Future<List<MediaItem>> search(String query) {
    final q = String.fromCharCodes(query.trim().runes.take(100));
    if (q.isEmpty) return Future.value(const []);
    return list('search/multi', params: {'query': q});
  }

  Future<MediaDetail> detail(String type, int id) async {
    final data = await _get(
        '$type/$id', const {'append_to_response': 'videos,similar,credits'});
    return MediaDetail.parse(data, type);
  }
}
