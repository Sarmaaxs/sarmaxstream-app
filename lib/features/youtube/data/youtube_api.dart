import '../../../core/api/api_client.dart';
import '../domain/youtube_video.dart';

class YoutubeApi {
  YoutubeApi(this._client);
  final ApiClient _client;
  final Map<String, ({DateTime at, List<YoutubeVideo> videos})> _cache = {};
  static const _ttl = Duration(minutes: 10);

  /// Trending videos when [query] is empty, otherwise search results.
  Future<List<YoutubeVideo>> videos([String query = '']) async {
    final q = String.fromCharCodes(query.trim().runes.take(100));
    final hit = _cache[q.toLowerCase()];
    if (hit != null && DateTime.now().difference(hit.at) < _ttl) {
      return hit.videos;
    }
    final data =
        await _client.getJson('/api/youtube', q.isEmpty ? null : {'q': q});
    final raw = data['videos'];
    final videos = (raw is List ? raw : const [])
        .map(YoutubeVideo.tryParse)
        .whereType<YoutubeVideo>()
        .toList();
    if (_cache.length > 40) _cache.remove(_cache.keys.first);
    _cache[q.toLowerCase()] = (at: DateTime.now(), videos: videos);
    return videos;
  }
}
