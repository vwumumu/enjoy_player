import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:enjoy_player/features/ai/domain/llm_api_spec.dart';
import 'package:enjoy_player/features/ai/domain/speech_byok_kind.dart';

part 'modality_byok_config.freezed.dart';

@freezed
abstract class LlmByokConfig with _$LlmByokConfig {
  const factory LlmByokConfig({
    required LlmApiSpec apiSpec,
    required String baseUrl,
    required String model,
    String? presetId,
  }) = _LlmByokConfig;
}

@freezed
abstract class SpeechByokConfig with _$SpeechByokConfig {
  const factory SpeechByokConfig({
    required SpeechByokKind kind,
    String? baseUrl,
    String? model,
    String? region,
    String? presetId,
  }) = _SpeechByokConfig;
}
