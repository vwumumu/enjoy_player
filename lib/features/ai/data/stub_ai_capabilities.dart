import 'package:enjoy_player/features/ai/domain/capabilities/asr_capability.dart';
import 'package:enjoy_player/features/ai/domain/byok_not_configured_failure.dart';
import 'package:enjoy_player/features/ai/domain/capabilities/assessment_capability.dart';
import 'package:enjoy_player/features/ai/domain/capabilities/contextual_translation_capability.dart';
import 'package:enjoy_player/features/ai/domain/capabilities/dictionary_capability.dart';
import 'package:enjoy_player/features/ai/domain/capabilities/llm_capability.dart';
import 'package:enjoy_player/features/ai/domain/capabilities/translation_capability.dart';
import 'package:enjoy_player/features/ai/domain/capabilities/tts_capability.dart';
import 'package:enjoy_player/features/ai/domain/chat_message.dart';
import 'package:enjoy_player/features/ai/domain/models/asr_request.dart';
import 'package:enjoy_player/features/ai/domain/models/asr_result.dart';
import 'package:enjoy_player/features/ai/domain/models/assessment_request.dart';
import 'package:enjoy_player/features/ai/domain/models/assessment_result.dart';
import 'package:enjoy_player/features/ai/domain/models/dictionary_result.dart';
import 'package:enjoy_player/features/ai/domain/models/contextual_translation_result.dart';
import 'package:enjoy_player/features/ai/domain/models/translation_result.dart';
import 'package:enjoy_player/features/ai/domain/models/tts_request.dart';
import 'package:enjoy_player/features/ai/domain/models/tts_result.dart';
import 'package:enjoy_player/features/ai/domain/modality_kind.dart';

/// Local on-device AI is not implemented in the player yet.
final class UnimplementedAsrCapability implements AsrCapability {
  const UnimplementedAsrCapability();

  @override
  Future<AsrResult> transcribe(AsrRequest request) {
    throw UnimplementedError(
      'ASR with local on-device models is not implemented yet.',
    );
  }
}

final class ByokNotConfiguredAsrCapability implements AsrCapability {
  const ByokNotConfiguredAsrCapability();

  @override
  Future<AsrResult> transcribe(AsrRequest request) {
    throw const ByokNotConfiguredFailure(ModalityKind.asr);
  }
}

final class UnimplementedLlmCapability implements LlmCapability {
  const UnimplementedLlmCapability();

  @override
  Future<String> generateChatCompletion({
    required List<ChatMessage> messages,
    double? temperature,
    int? maxTokens,
    Map<String, dynamic>? responseFormat,
  }) {
    throw UnimplementedError(
      'LLM with local on-device models is not implemented yet.',
    );
  }

  @override
  Future<String> generateText({
    String? systemPrompt,
    required String userPrompt,
    double? temperature,
    int? maxTokens,
  }) {
    throw UnimplementedError(
      'LLM with local on-device models is not implemented yet.',
    );
  }
}

final class ByokNotConfiguredLlmCapability implements LlmCapability {
  const ByokNotConfiguredLlmCapability();

  @override
  Future<String> generateChatCompletion({
    required List<ChatMessage> messages,
    double? temperature,
    int? maxTokens,
    Map<String, dynamic>? responseFormat,
  }) {
    throw const ByokNotConfiguredFailure(ModalityKind.llm);
  }

  @override
  Future<String> generateText({
    String? systemPrompt,
    required String userPrompt,
    double? temperature,
    int? maxTokens,
  }) {
    throw const ByokNotConfiguredFailure(ModalityKind.llm);
  }
}

final class UnimplementedTranslationCapability
    implements TranslationCapability {
  const UnimplementedTranslationCapability();

  @override
  Future<TranslationResult> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    bool? forceRefresh,
  }) {
    throw UnimplementedError(
      'Translation with local on-device models is not implemented yet.',
    );
  }
}

final class UnimplementedContextualTranslationCapability
    implements ContextualTranslationCapability {
  const UnimplementedContextualTranslationCapability();

  @override
  Future<ContextualTranslationResult> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    String? context,
  }) {
    throw UnimplementedError(
      'Contextual translation with local on-device models is not implemented yet.',
    );
  }
}

final class UnimplementedDictionaryCapability implements DictionaryCapability {
  const UnimplementedDictionaryCapability();

  @override
  Future<DictionaryResult> lookupDictionary({
    required String word,
    required String sourceLanguage,
    required String targetLanguage,
    bool? forceRefresh,
  }) {
    throw UnimplementedError(
      'Dictionary with local on-device models is not implemented yet.',
    );
  }
}

final class UnimplementedTtsCapability implements TtsCapability {
  const UnimplementedTtsCapability();

  @override
  Future<TtsResult> synthesize(TtsRequest request) {
    throw UnimplementedError(
      'TTS with local on-device models is not implemented yet.',
    );
  }
}

final class ByokNotConfiguredTtsCapability implements TtsCapability {
  const ByokNotConfiguredTtsCapability();

  @override
  Future<TtsResult> synthesize(TtsRequest request) {
    throw const ByokNotConfiguredFailure(ModalityKind.tts);
  }
}

final class UnimplementedAssessmentCapability implements AssessmentCapability {
  const UnimplementedAssessmentCapability();

  @override
  Future<AssessmentResult> assess(AssessmentRequest request) {
    throw UnimplementedError(
      'Assessment with local on-device models is not implemented yet.',
    );
  }
}

final class ByokNotConfiguredAssessmentCapability implements AssessmentCapability {
  const ByokNotConfiguredAssessmentCapability();

  @override
  Future<AssessmentResult> assess(AssessmentRequest request) {
    throw const ByokNotConfiguredFailure(ModalityKind.assessment);
  }
}
