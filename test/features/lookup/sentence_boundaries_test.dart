import 'package:flutter_test/flutter_test.dart';

import 'package:enjoy_player/features/lookup/application/sentence_boundaries.dart';

void main() {
  group('getSentenceBoundaries', () {
    test('finds English sentence ends', () {
      const t = 'First part. Second part! Third?';
      final b = getSentenceBoundaries(t, 'en');
      expect(b, isNotEmpty);
      expect(b.last, lessThanOrEqualTo(t.length));
    });

    test('finds Chinese fullwidth punctuation', () {
      const t = '第一句。第二句！第三句？';
      final b = getSentenceBoundaries(t, 'zh');
      expect(b, isNotEmpty);
    });
  });
}
