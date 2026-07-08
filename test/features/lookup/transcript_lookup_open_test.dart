import 'package:enjoy_player/features/lookup/application/transcript_lookup_open.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveLookupSourceLanguage', () {
    test('prefers chrome (video) language when usable', () {
      expect(
        resolveLookupSourceLanguage(
          chromeLanguage: 'ko-KR',
          activeTrackLanguage: 'ja-JP',
        ),
        'ko-KR',
      );
    });

    test('falls back to active track when chrome is und', () {
      expect(
        resolveLookupSourceLanguage(
          chromeLanguage: 'und',
          activeTrackLanguage: 'ko',
        ),
        'ko',
      );
    });

    test('falls back to active track when chrome is empty', () {
      expect(
        resolveLookupSourceLanguage(
          chromeLanguage: '',
          activeTrackLanguage: 'ja-JP',
        ),
        'ja-JP',
      );
    });

    test('falls back to active track when chrome is null', () {
      expect(
        resolveLookupSourceLanguage(
          chromeLanguage: null,
          activeTrackLanguage: 'de-DE',
        ),
        'de-DE',
      );
    });

    test('returns null when both are missing or denylisted', () {
      expect(
        resolveLookupSourceLanguage(
          chromeLanguage: null,
          activeTrackLanguage: null,
        ),
        isNull,
      );
      expect(
        resolveLookupSourceLanguage(
          chromeLanguage: 'und',
          activeTrackLanguage: '',
        ),
        isNull,
      );
    });

    test('trims whitespace', () {
      expect(
        resolveLookupSourceLanguage(
          chromeLanguage: '  ko-KR  ',
          activeTrackLanguage: null,
        ),
        'ko-KR',
      );
    });
  });
}