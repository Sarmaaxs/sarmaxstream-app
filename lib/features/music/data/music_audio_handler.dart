import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../domain/track.dart';

/// Plays ONE song at a time. The controller owns the queue and tells this
/// handler what to play, so every queue entry is resolved before it is played.
class MusicAudioHandler extends BaseAudioHandler with SeekHandler {
  MusicAudioHandler() {
    _player.playbackEventStream.map(_transform).pipe(playbackState);
    // processingStateStream only emits when the state really CHANGES, so
    // pausing a finished song can never fire "completed" a second time
    // (which would wrongly skip a track).
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        onCompleted?.call();
      }
    });
  }

  final AudioPlayer _player = AudioPlayer();

  void Function()? onNext;
  void Function()? onPrevious;
  void Function()? onCompleted;

  bool get isPlaying => _player.playing;
  Stream<bool> get playingStream => _player.playingStream;
  Duration get position => _player.position;

  PlaybackState _transform(PlaybackEvent event) => PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          _player.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: _player.playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
      );

  Future<void> setCurrentSource(Track track, String url) async {
    final uri = Uri.parse(url);
    // Never stream audio over plain http.
    if (uri.scheme != 'https') {
      throw const FormatException('Refusing non-https audio source');
    }
    final art = track.safeThumbnail;
    final item = MediaItem(
      id: track.videoId,
      title: track.title,
      artist: track.artist,
      artUri: art == null ? null : Uri.tryParse(art),
      duration: _parseDuration(track.duration),
    );
    mediaItem.add(item);
    await _player.setAudioSource(AudioSource.uri(uri, tag: item));
    // IMPORTANT: play() only completes when the song ends, so never await it.
    unawaited(_player.play());
  }

  Duration? _parseDuration(String iso) {
    final s = RegExp(r'^PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?$').firstMatch(iso);
    if (s == null) return null;
    return Duration(
      hours: int.tryParse(s.group(1) ?? '') ?? 0,
      minutes: int.tryParse(s.group(2) ?? '') ?? 0,
      seconds: int.tryParse(s.group(3) ?? '') ?? 0,
    );
  }

  @override
  Future<void> play() async {
    unawaited(_player.play());
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    onNext?.call();
  }

  @override
  Future<void> skipToPrevious() async {
    onPrevious?.call();
  }
}
