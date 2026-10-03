import 'package:flutter_test/flutter_test.dart';
import 'package:sarmaxstream/core/api/api_client.dart';
import 'package:sarmaxstream/features/music/domain/track.dart';

Track _t(String id, {String thumb = 'https://example.com/a.jpg'}) => Track(
    videoId: id, title: 't', artist: 'a', thumbnail: thumb, duration: 'PT3M');

void main() {
  group('ApiClient', () {
    test('rejects non-https base URLs', () {
      expect(() => ApiClient(baseUrl: 'http://example.com'), throwsArgumentError);
      expect(() => ApiClient(baseUrl: 'ftp://example.com'), throwsArgumentError);
      expect(() => ApiClient(baseUrl: 'not a url'), throwsArgumentError);
    });

    test('accepts https and strips trailing slash', () {
      final c = ApiClient(baseUrl: 'https://example.com/');
      expect(c.baseUrl, 'https://example.com');
      expect(c.absolute('/api/x'), 'https://example.com/api/x');
    });
  });

  group('Track', () {
    test('classifies ids', () {
      expect(_t('dz_123').isCatalog, isTrue);
      expect(_t('it_9').isCatalog, isTrue);
      expect(_t('aud_abc').isAudio, isTrue);
      expect(_t('jam_42').isAudio, isTrue);
      expect(_t('dQw4w9WgXcQ').isYoutube, isTrue);
    });

    test('rejects malformed YouTube ids', () {
      expect(_t('null').isYoutube, isFalse);
      expect(_t('').isYoutube, isFalse);
      expect(_t('short').isYoutube, isFalse);
      expect(_t('dQw4w9WgXcQ"><script>').isYoutube, isFalse);
    });

    test('only https thumbnails are used', () {
      expect(_t('x').safeThumbnail, 'https://example.com/a.jpg');
      expect(_t('x', thumb: 'http://example.com/a.jpg').safeThumbnail, isNull);
      expect(_t('x', thumb: 'file:///etc/passwd').safeThumbnail, isNull);
      expect(_t('x', thumb: '').safeThumbnail, isNull);
    });

    test('formatDuration', () {
      expect(formatDuration('PT3M5S'), '3:05');
      expect(formatDuration('PT1H2M3S'), '1:02:03');
      expect(formatDuration('garbage'), '--:--');
    });
  });
}
