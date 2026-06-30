/// Prompts for BYOK dictionary lookup (JSON response).
library;

import 'package:enjoy_player/core/application/app_language_catalog.dart';

String buildDictionarySystemPrompt({
  required String sourceLanguage,
  required String targetLanguage,
}) {
  final source = workerLanguageBase(sourceLanguage);
  final target = workerLanguageBase(targetLanguage);
  return 'You are a bilingual dictionary for language learners. '
      'The learner\'s language is $target and the headword language is $source. '
      'Return ONLY valid JSON (no markdown fences) with this shape:\n'
      '{"word":"string","lemma":"string or null","ipa":"string or null",'
      '"senses":[{"definition":"string","translation":"string",'
      '"partOfSpeech":"string or null","notes":"string or null",'
      '"examples":[{"source":"string","target":"string"}]}]}';
}

String buildDictionaryUserPrompt(String word) =>
    'Look up the word or phrase: $word';
