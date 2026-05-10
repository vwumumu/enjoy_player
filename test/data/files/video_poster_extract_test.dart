import 'package:enjoy_player/data/files/video_poster_extract.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('posterSeekSeconds', () {
    test('unknown duration uses ~6s default', () {
      expect(posterSeekSeconds(null), 6.0);
      expect(posterSeekSeconds(0), 6.0);
    });

    test('short clip stays inside duration', () {
      expect(posterSeekSeconds(2), lessThanOrEqualTo(1.95));
      expect(posterSeekSeconds(2), greaterThan(0));
    });

    test('typical clip uses ~12% capped at 90', () {
      expect(posterSeekSeconds(100), closeTo(12.0, 0.01));
      expect(posterSeekSeconds(800), 90.0);
    });
  });
}
