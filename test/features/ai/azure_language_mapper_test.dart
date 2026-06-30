import 'package:enjoy_player/features/ai/data/azure_language_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mapTranscriptLanguageToAzure maps common codes', () {
    expect(mapTranscriptLanguageToAzure('en'), 'en-US');
    expect(mapTranscriptLanguageToAzure('zh-TW'), 'zh-TW');
    expect(mapTranscriptLanguageToAzure('ja'), 'ja-JP');
    expect(mapTranscriptLanguageToAzure('en-GB'), 'en-GB');
  });

  test(
    'mapTranscriptLanguageToAzure preserves xx-YY when already Azure-like',
    () {
      expect(mapTranscriptLanguageToAzure('de-DE'), 'de-DE');
    },
  );

  test('mapTranscriptLanguageToAzure returns null for invalid codes', () {
    expect(mapTranscriptLanguageToAzure('und'), isNull);
    expect(mapTranscriptLanguageToAzure('mul'), isNull);
    expect(mapTranscriptLanguageToAzure('zxx'), isNull);
    expect(mapTranscriptLanguageToAzure(null), isNull);
    expect(mapTranscriptLanguageToAzure('xx'), isNull);
  });
}
