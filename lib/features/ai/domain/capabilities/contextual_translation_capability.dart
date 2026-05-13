import 'package:enjoy_player/features/ai/domain/models/contextual_translation_result.dart';

abstract class ContextualTranslationCapability {
  Future<ContextualTranslationResult> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    String? context,
  });
}
