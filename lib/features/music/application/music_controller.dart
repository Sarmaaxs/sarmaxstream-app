import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/music_api.dart';
import '../data/music_audio_handler.dart';
import '../domain/track.dart';

class MusicController extends ChangeNotifier {
  MusicController(this.api, this.audio) {
    audio.onNext = () => unawaited(next());
    audio.onPrevious = () => unawaited(previous());
    audio.onCompleted = _completed;
    _playingSub = audio.playingStream.listen((p) {
      if (resolving) return;
      if (playing != p) {
        playing = p;
        notifyListeners();
      }
    });
  }

  final MusicApi api;
  final MusicAudioHandler audio;
  Timer? _debounce;
  StreamSubscription<bool>? _playingSub;

  List<Track> results = const [];
  List<Track> queue = const [];
  int index = -1;
  Track? current;
  Track? youtubeOnly; // set when a song can only be played through YouTube
  String query = '';
  String? error;
  bool loading = false;
  bool resolving = false;
  bool playing = false;

  bool _loaded = false; // true while the current song's audio is loaded in the player
  int _token = 0; // changes on every new play request, so a slow old one can never win
  int _searchToken = 0; // same idea for searches
  int _autoSkips = 0;

  /// True when play/pause can safely act on the loaded song.
  bool get canToggle => _loaded && !resolving;

  bool isActive(Track t) =>
      current != null &&
      (current!.videoId == t.videoId || current!.catalogId == t.videoId);

  void searchChanged(String value) {
    query = value;
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      _searchToken++; // drop any search that is still in flight
      results = const [];
      error = null;
      loading = false;
      notifyListeners();
      return;
    }
    _debounce =
        Timer(const Duration(milliseconds: 420), () => search(value.trim()));
  }

  Future<void> search(String value) async {
    final token = ++_searchToken;
    loading = true;
    error = null;
    notifyListeners();
    try {
      final found = await api.search(value);
      if (token != _searchToken) return;
      results = found;
    } catch (_) {
      if (token != _searchToken) return;
      error =
          'Search is unavailable right now. Check your connection and try again.';
    }
    loading = false;
    notifyListeners();
  }

  Future<void> playTrack(Track track) async {
    queue = List<Track>.of(results);
    var i = queue.indexWhere((e) => e.videoId == track.videoId);
    if (i < 0) {
      queue = [track, ...queue];
      i = 0;
    }
    _autoSkips = 0;
    await _playIndex(i);
  }

  Future<void> _playIndex(int i, {bool auto = false}) async {
    if (i < 0 || i >= queue.length) return;
    final token = ++_token;
    index = i;
    final track = queue[i];
    current = track;
    error = null;
    youtubeOnly = null;
    resolving = true;
    playing = false;
    _loaded = false;
    notifyListeners();
    // Silence the previous song right away, and never let it resume while the new one loads.
    unawaited(audio.pause());
    try {
      var resolved = track;
      if (track.isCatalog) resolved = await api.resolve(track);
      if (token != _token) return;
      await _playResolved(resolved, i, token);
    } catch (_) {
      if (token != _token) return;
      await _fallback(track, i, token, auto);
    }
  }

  /// Plays a resolved track: free audio stream, or YouTube's own player.
  /// Anything else (e.g. a malformed id from the server) is rejected.
  Future<void> _playResolved(Track resolved, int i, int token) async {
    if (resolved.isAudio) {
      await _start(resolved, i, token);
    } else if (resolved.isYoutube) {
      _youtubeOnly(resolved);
    } else {
      throw const FormatException('Unplayable track');
    }
  }

  Future<void> _start(Track resolved, int i, int token) async {
    await audio.setCurrentSource(resolved, api.streamUrl(resolved));
    if (token != _token) return;
    if (i < queue.length) queue[i] = resolved;
    current = resolved;
    playing = true;
    resolving = false;
    _loaded = true;
    notifyListeners();
  }

  void _youtubeOnly(Track t) {
    // No error banner: the page shows the official YouTube player for this song instead.
    youtubeOnly = t;
    resolving = false;
    playing = false;
    _loaded = false;
    notifyListeners();
  }

  // The free stream failed: look the same song up on YouTube instead.
  Future<void> _fallback(Track track, int i, int token, bool auto) async {
    try {
      final fb = await api.resolve(track, skipFree: true);
      if (token != _token) return;
      await _playResolved(fb, i, token);
    } catch (_) {
      if (token != _token) return;
      error = 'This song could not be played. Try another one.';
      resolving = false;
      playing = false;
      _loaded = false;
      notifyListeners();
      // When advancing automatically, try the following song, at most 3 times in a row.
      if (auto && _autoSkips < 3 && index + 1 < queue.length) {
        _autoSkips++;
        await _playIndex(index + 1, auto: true);
      }
    }
  }

  void _completed() {
    if (index + 1 < queue.length) {
      unawaited(_playIndex(index + 1, auto: true));
    } else {
      // End of the queue: rewind so pressing play starts the song again.
      playing = false;
      unawaited(audio.pause());
      unawaited(audio.seek(Duration.zero));
      notifyListeners();
    }
  }

  Future<void> togglePlay() async {
    if (resolving || youtubeOnly != null || current == null) return;
    if (!_loaded) {
      // The song failed to load earlier: pressing play tries it again.
      await _playIndex(index);
      return;
    }
    if (audio.isPlaying) {
      await audio.pause();
    } else {
      await audio.play();
    }
  }

  Future<void> next() async {
    if (index + 1 >= queue.length) return;
    _autoSkips = 0;
    await _playIndex(index + 1);
  }

  Future<void> previous() async {
    if (_loaded && (audio.position > const Duration(seconds: 3) || index <= 0)) {
      await audio.seek(Duration.zero);
      return;
    }
    if (index <= 0) return;
    _autoSkips = 0;
    await _playIndex(index - 1);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _playingSub?.cancel();
    audio.onNext = null;
    audio.onPrevious = null;
    audio.onCompleted = null;
    super.dispose();
  }
}
