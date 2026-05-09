import 'package:enjoy_player/core/theme/generative_media_cover.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('hashToNumber', () {
    test('empty string yields zero', () {
      expect(hashToNumber(''), 0);
    });

    test('stable for sample seed', () {
      const s = 'abc123deadbeef';
      expect(hashToNumber(s, 0), hashToNumber(s, 0));
      expect(hashToNumber(s, 4), isNot(hashToNumber(s, 0)));
    });
  });

  group('generativeAccentForSeed', () {
    test('deterministic per seed', () {
      expect(
        generativeAccentForSeed('same').toARGB32(),
        generativeAccentForSeed('same').toARGB32(),
      );
      expect(
        generativeAccentForSeed('a').toARGB32(),
        isNot(generativeAccentForSeed('b').toARGB32()),
      );
    });
  });
}
