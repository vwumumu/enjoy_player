import 'package:enjoy_player/core/application/app_language_catalog.dart';
import 'package:enjoy_player/features/ai/domain/capabilities/llm_capability.dart';
import 'package:enjoy_player/features/ai/domain/capabilities/translation_capability.dart';
import 'package:enjoy_player/features/ai/domain/models/translation_result.dart';
import 'package:enjoy_player/features/ai/domain/prompts/translation_prompt.dart';

final class ByokTranslationCapability implements TranslationCapability {
  ByokTranslationCapability(this._llm);

  final LlmCapability _llm;

  @override
  Future<TranslationResult> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    bool? forceRefresh,
  }) async {
    final translated = await _llm.generateText(
      systemPrompt: buildTranslationSystemPrompt(
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      ),
      userPrompt: buildTranslationUserPrompt(text),
      temperature: 0.3,
      maxTokens: 2048,
    );

    return TranslationResult(
      translatedText: translated.trim(),
      sourceLanguage: workerLanguageBase(sourceLanguage),
      targetLanguage: workerLanguageBase(targetLanguage),
    );
  }
}
