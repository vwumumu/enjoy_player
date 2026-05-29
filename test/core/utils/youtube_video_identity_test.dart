import 'package:enjoy_player/core/utils/youtube_video_identity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('youtubeImportPlaceholderTitle', () {
    test('formats fallback title', () {
      expect(
        youtubeImportPlaceholderTitle('dQw4w9WgXcQ'),
        'YouTube video dQw4w9WgXcQ',
      );
    });
  });

  group('isYoutubeImportPlaceholderTitle', () {
    const vid = 'dQw4w9WgXcQ';

    test('true for fallback title', () {
      expect(
        isYoutubeImportPlaceholderTitle('YouTube video $vid', vid),
        isTrue,
      );
    });

    test('true for bare video id', () {
      expect(isYoutubeImportPlaceholderTitle(vid, vid), isTrue);
    });

    test('true for empty title', () {
      expect(isYoutubeImportPlaceholderTitle('', vid), isTrue);
    });

    test('false for real title', () {
      expect(
        isYoutubeImportPlaceholderTitle('Never Gonna Give You Up', vid),
        isFalse,
      );
    });
  });
}
