import 'package:flutter_test/flutter_test.dart';
import 'package:sarmaxstream/features/movies/domain/media_item.dart';
import 'package:sarmaxstream/features/youtube/domain/youtube_video.dart';

void main() {
  group('MediaItem', () {
    test('parses a movie and a show', () {
      final m = MediaItem.tryParse({
        'id': 550,
        'media_type': 'movie',
        'title': 'Fight Club',
        'overview': 'x',
        'poster_path': '/abc.jpg',
        'release_date': '1999-10-15',
        'vote_average': 8.4,
      })!;
      expect(m.title, 'Fight Club');
      expect(m.year, '1999');
      expect(m.isTv, isFalse);
      expect(m.poster, 'https://image.tmdb.org/t/p/w342/abc.jpg');

      final t = MediaItem.tryParse(
          {'id': 1, 'name': 'Show', 'first_air_date': '2020-01-01'},
          fallbackType: 'tv')!;
      expect(t.isTv, isTrue);
      expect(t.title, 'Show');
    });

    test('skips people and malformed entries', () {
      expect(MediaItem.tryParse({'id': 1, 'media_type': 'person', 'name': 'A'}), isNull);
      expect(MediaItem.tryParse({'id': 'x', 'media_type': 'movie', 'title': 'A'}), isNull);
      expect(MediaItem.tryParse({'id': 1, 'media_type': 'movie'}), isNull);
      expect(MediaItem.tryParse('nope'), isNull);
    });

    test('image paths are validated', () {
      expect(tmdbImage('/ok.jpg', 'w500'), 'https://image.tmdb.org/t/p/w500/ok.jpg');
      expect(tmdbImage('http://evil.com/x.jpg', 'w500'), isNull);
      expect(tmdbImage('/a/../b.jpg', 'w500'), isNull);
      expect(tmdbImage(null, 'w500'), isNull);
    });
  });

  group('MediaDetail', () {
    test('prefers the official trailer and checks the id', () {
      final d = MediaDetail.parse({
        'genres': [{'name': 'Drama'}],
        'runtime': 139,
        'videos': {
          'results': [
            {'site': 'YouTube', 'type': 'Teaser', 'key': 'aaaaaaaaaaa'},
            {'site': 'YouTube', 'type': 'Trailer', 'official': false, 'key': 'bbbbbbbbbbb'},
            {'site': 'YouTube', 'type': 'Trailer', 'official': true, 'key': 'ccccccccccc'},
            {'site': 'Vimeo', 'type': 'Trailer', 'key': 'ddddddddddd'},
          ]
        },
      }, 'movie');
      expect(d.trailerId, 'ccccccccccc');
      expect(d.genres, ['Drama']);
      expect(d.runtimeMinutes, 139);
    });

    test('rejects malformed trailer ids', () {
      final d = MediaDetail.parse({
        'videos': {
          'results': [
            {'site': 'YouTube', 'type': 'Trailer', 'key': 'bad"><script>'},
          ]
        },
      }, 'movie');
      expect(d.trailerId, isNull);
    });
  });

  group('YoutubeVideo', () {
    test('accepts only well-formed ids', () {
      expect(
          YoutubeVideo.tryParse({'id': 'dQw4w9WgXcQ', 'title': 'T'}), isNotNull);
      expect(YoutubeVideo.tryParse({'id': 'short', 'title': 'T'}), isNull);
      expect(YoutubeVideo.tryParse({'id': 'dQw4w9WgXcQ', 'title': ''}), isNull);
    });

    test('only https thumbnails are used', () {
      YoutubeVideo v(String t) => YoutubeVideo(
          id: 'dQw4w9WgXcQ', title: 'T', channel: 'C', thumbnail: t, duration: '');
      expect(v('https://i.ytimg.com/a.jpg').safeThumbnail, isNotNull);
      expect(v('http://i.ytimg.com/a.jpg').safeThumbnail, isNull);
      expect(v('').safeThumbnail, isNull);
    });
  });
}
