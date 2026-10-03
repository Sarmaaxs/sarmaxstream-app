class Track {
  const Track(
      {required this.videoId,
      required this.title,
      required this.artist,
      required this.thumbnail,
      required this.duration,
      this.source,
      this.verified = false,
      this.catalogId});
  final String videoId;
  final String title;
  final String artist;
  final String thumbnail;
  final String duration;
  final String? source;
  final bool verified;
  final String? catalogId;

  static final _catalogPattern = RegExp(r'^(dz|it)_\d+$');
  static final _youtubePattern = RegExp(r'^[A-Za-z0-9_-]{11}$');

  bool get isCatalog => _catalogPattern.hasMatch(videoId);
  bool get isAudio => videoId.startsWith('aud_') || videoId.startsWith('jam_');

  /// A real YouTube video id (exactly 11 safe characters). Anything else is
  /// never handed to the embedded YouTube player.
  bool get isYoutube => !isCatalog && !isAudio && _youtubePattern.hasMatch(videoId);

  /// Artwork URL, or null unless it is a well-formed https URL.
  String? get safeThumbnail {
    final uri = Uri.tryParse(thumbnail);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) return null;
    return thumbnail;
  }

  Track copyWith({String? videoId, String? source, String? catalogId}) => Track(
      videoId: videoId ?? this.videoId,
      title: title,
      artist: artist,
      thumbnail: thumbnail,
      duration: duration,
      source: source ?? this.source,
      verified: verified,
      catalogId: catalogId ?? this.catalogId);

  Map<String, dynamic> toJson() => {
        'videoId': videoId,
        'title': title,
        'artist': artist,
        'thumbnail': thumbnail,
        'duration': duration,
        'source': source,
        'verified': verified,
        'catalogId': catalogId
      };

  factory Track.fromJson(Map<String, dynamic> json) => Track(
      videoId: '${json['videoId'] ?? ''}',
      title: '${json['title'] ?? 'Unknown track'}',
      artist: '${json['artist'] ?? 'Unknown artist'}',
      thumbnail: '${json['thumbnail'] ?? ''}',
      duration: '${json['duration'] ?? ''}',
      source: json['source'] is String ? json['source'] as String : null,
      verified: json['verified'] == true,
      catalogId: json['catalogId'] is String ? json['catalogId'] as String : null);
}

String formatDuration(String iso) {
  final m = RegExp(r'^PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?$').firstMatch(iso);
  if (m == null) return '--:--';
  final seconds = (int.tryParse(m.group(1) ?? '') ?? 0) * 3600 +
      (int.tryParse(m.group(2) ?? '') ?? 0) * 60 +
      (int.tryParse(m.group(3) ?? '') ?? 0);
  final d = Duration(seconds: seconds);
  return d.inHours > 0
      ? '${d.inHours}:${(d.inMinutes % 60).toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}'
      : '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
}
