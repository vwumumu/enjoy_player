/// Prompts for BYOK translation (aligned with Enjoy worker shapes).
library;

import 'package:enjoy_player/core/application/app_language_catalog.dart';

String buildTranslationSystemPrompt({
  required String sourceLanguage,
  required String targetLanguage,
}) {
  final source = workerLanguageBase(sourceLanguage);
  final target = workerLanguageBase(targetLanguage);
  return 'You are a professional translator. Translate text from $source to $target. '
      'Reply with only the translated text — no quotes, labels, or explanation.';
}

String buildTranslationUserPrompt(String text) => text;
