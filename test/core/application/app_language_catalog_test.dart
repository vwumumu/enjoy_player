import 'package:enjoy_player/core/application/app_language_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isValidLanguageTag', () {
    test('rejects null, empty, and denylisted primaries', () {
      expect(isValidLanguageTag(null), false);
      expect(isValidLanguageTag(''), false);
      expect(isValidLanguageTag('   '), false);
      expect(isValidLanguageTag('und'), false);
      expect(isValidLanguageTag('UND'), false);
      expect(isValidLanguageTag('und-US'), false);
      expect(isValidLanguageTag('mul'), false);
      expect(isValidLanguageTag('mis'), false);
      expect(isValidLanguageTag('zxx'), false);
    });

    test('accepts en/zh and unknown real primaries', () {
      expect(isValidLanguageTag('en'), true);
      expect(isValidLanguageTag('zh-CN'), true);
      expect(isValidLanguageTag('ja'), true);
    });
  });

  group('canonicalLookupTag', () {
    test('maps en variants to en-US', () {
      expect(canonicalLookupTag('en'), 'en-US');
      expect(canonicalLookupTag('EN'), 'en-US');
      expect(canonicalLookupTag('en-us'), 'en-US');
      expect(canonicalLookupTag('en-US'), 'en-US');
      expect(canonicalLookupTag('en-GB'), 'en-US');
    });

    test('maps zh variants to zh-CN', () {
      expect(canonicalLookupTag('zh'), 'zh-CN');
      expect(canonicalLookupTag('zh-cn'), 'zh-CN');
      expect(canonicalLookupTag('zh-CN'), 'zh-CN');
      expect(canonicalLookupTag('zh-Hans'), 'zh-CN');
    });

    test('returns null for invalid or unsupported', () {
      expect(canonicalLookupTag(null), null);
      expect(canonicalLookupTag('und'), null);
      expect(canonicalLookupTag('ja'), null);
      expect(canonicalLookupTag('fr-FR'), null);
    });
  });

  group('workerLanguageBase', () {
    test('strips region script', () {
      expect(workerLanguageBase('en-US'), 'en');
      expect(workerLanguageBase('zh-CN'), 'zh');
      expect(workerLanguageBase('  EN-us  '), 'en');
    });

    test('empty falls back to en', () {
      expect(workerLanguageBase(''), 'en');
      expect(workerLanguageBase('   '), 'en');
    });
  });

  group('coerceLookupSource', () {
    test('uses default learning when transcript unsupported', () {
      expect(coerceLookupSource('und'), kDefaultLearningLanguageTag);
      expect(coerceLookupSource('ja'), kDefaultLearningLanguageTag);
    });
  });
}
