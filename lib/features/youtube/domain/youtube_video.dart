final _youtubeId = RegExp(r'^[A-Za-z0-9_-]{11}$');

class YoutubeVideo {
  const YoutubeVideo({
    required this.id,
    required this.title,
    required this.channel,
    required this.thumbnail,
    required this.duration,
  });

  final String id;
  final String title;
  final String channel;
  final String thumbnail;
  final String duration; // ISO 8601, like PT3M5S

  /// Only https thumbnails are ever loaded.
  String? get safeThumbnail {
    final uri = Uri.tryParse(thumbnail);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) return null;
    return thumbnail;
  }

  /// Returns null unless the id is exactly 11 safe characters.
  static YoutubeVideo? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final id = '${raw['id'] ?? ''}';
    if (!_youtubeId.hasMatch(id)) return null;
    final title = '${raw['title'] ?? ''}'.trim();
    if (title.isEmpty) return null;
    return YoutubeVideo(
      id: id,
      title: title,
      channel: '${raw['channel'] ?? ''}',
      thumbnail: '${raw['thumbnail'] ?? ''}',
      duration: '${raw['duration'] ?? ''}',
    );
  }
}
