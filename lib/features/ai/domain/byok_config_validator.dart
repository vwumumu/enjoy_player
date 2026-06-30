import 'package:enjoy_player/core/validation/byok_url_guard.dart';
import 'package:enjoy_player/features/ai/domain/ai_provider.dart';
import 'package:enjoy_player/features/ai/domain/ai_service_config.dart';
import 'package:enjoy_player/features/ai/domain/modality_kind.dart';
import 'package:enjoy_player/features/ai/domain/speech_byok_kind.dart';

/// Localization key suffixes for validator failures (see `byok-validation.md`).
enum ByokValidationError {
  apiKeyRequired,
  baseUrlRequired,
  baseUrlInvalid,
  modelRequired,
  regionRequired,
  apiSpecRequired,
  azureKindRequired,
}

class ByokValidationResult {
  const ByokValidationResult._(this.errors);

  const ByokValidationResult.valid() : errors = const [];

  final List<ByokValidationError> errors;

  bool get isValid => errors.isEmpty;
}

class ByokConfigValidator {
  const ByokConfigValidator();

  ByokValidationResult validate({
    required ModalityKind modality,
    required AIServiceConfig config,
    required bool hasExistingApiKey,
    String? apiKey,
  }) {
    if (config.provider != AIProvider.byok) {
      return const ByokValidationResult.valid();
    }

    final errors = <ByokValidationError>[];

    final keyProvided = apiKey != null && apiKey.trim().isNotEmpty;
    if (!keyProvided && !hasExistingApiKey) {
      errors.add(ByokValidationError.apiKeyRequired);
    }

    switch (modality) {
      case ModalityKind.llm:
        _validateLlm(config, errors);
      case ModalityKind.asr:
      case ModalityKind.tts:
        _validateSpeech(modality, config, errors);
      case ModalityKind.assessment:
        _validateAssessment(config, errors);
    }

    return ByokValidationResult._(errors);
  }

  void _validateLlm(AIServiceConfig config, List<ByokValidationError> errors) {
    final llm = config.llmByok;
    if (llm == null) {
      errors.add(ByokValidationError.apiSpecRequired);
      return;
    }

    final baseUrl = llm.baseUrl.trim();
    if (baseUrl.isEmpty) {
      errors.add(ByokValidationError.baseUrlRequired);
    } else if (!isByokBaseUrlAllowed(baseUrl)) {
      errors.add(ByokValidationError.baseUrlInvalid);
    }

    if (llm.model.trim().isEmpty) {
      errors.add(ByokValidationError.modelRequired);
    }
  }

  void _validateSpeech(
    ModalityKind modality,
    AIServiceConfig config,
    List<ByokValidationError> errors,
  ) {
    final speech = config.speechByok;
    if (speech == null) {
      errors.add(ByokValidationError.apiSpecRequired);
      return;
    }

    switch (speech.kind) {
      case SpeechByokKind.openAiCompatible:
        final baseUrl = speech.baseUrl?.trim() ?? '';
        if (baseUrl.isEmpty) {
          errors.add(ByokValidationError.baseUrlRequired);
        } else if (!isByokBaseUrlAllowed(baseUrl)) {
          errors.add(ByokValidationError.baseUrlInvalid);
        }
        if ((speech.model?.trim() ?? '').isEmpty) {
          errors.add(ByokValidationError.modelRequired);
        }
      case SpeechByokKind.azureSpeech:
        if ((speech.region?.trim() ?? '').isEmpty) {
          errors.add(ByokValidationError.regionRequired);
        }
    }
  }

  void _validateAssessment(
    AIServiceConfig config,
    List<ByokValidationError> errors,
  ) {
    final speech = config.speechByok;
    if (speech == null || speech.kind != SpeechByokKind.azureSpeech) {
      errors.add(ByokValidationError.azureKindRequired);
      return;
    }
    if ((speech.region?.trim() ?? '').isEmpty) {
      errors.add(ByokValidationError.regionRequired);
    }
  }
}
