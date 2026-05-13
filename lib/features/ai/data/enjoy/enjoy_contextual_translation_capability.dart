import 'package:enjoy_player/features/ai/domain/capabilities/contextual_translation_capability.dart';
import 'package:enjoy_player/features/ai/domain/capabilities/llm_capability.dart';
import 'package:enjoy_player/features/ai/domain/models/contextual_translation_result.dart';
import 'package:enjoy_player/features/ai/domain/prompts/contextual_translation_prompt.dart';

void _keepSourceLanguage(String _) {}

final class EnjoyContextualTranslationCapability
    implements ContextualTranslationCapability {
  EnjoyContextualTranslationCapability(this._llm);

  final LlmCapability _llm;

  @override
  Future<ContextualTranslationResult> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    String? context,
  }) async {
    _keepSourceLanguage(sourceLanguage);
    final systemPrompt = getContextualTranslationSystemPrompt(targetLanguage);
    final userPrompt = buildContextualTranslationUserPrompt(
      text: text,
      context: context,
    );
    final raw = await _llm.generateText(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      temperature: 0.3,
      maxTokens: 1024,
    );
    return ContextualTranslationResult(translatedText: raw.trim());
  }
}
