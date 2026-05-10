import 'package:enjoy_player/core/utils/remote_thumbnail_url.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isRemoteThumbnailUrl', () {
    test('false for null, empty, file path, file scheme', () {
      expect(isRemoteThumbnailUrl(null), isFalse);
      expect(isRemoteThumbnailUrl(''), isFalse);
      expect(isRemoteThumbnailUrl(r'C:\x\y.jpg'), isFalse);
      expect(isRemoteThumbnailUrl('file:///x/y.jpg'), isFalse);
    });

    test('true for http and https', () {
      expect(isRemoteThumbnailUrl('http://a/b.jpg'), isTrue);
      expect(isRemoteThumbnailUrl('https://cdn/x.png'), isTrue);
    });
  });
}
