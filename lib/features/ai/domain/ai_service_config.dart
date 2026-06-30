import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:enjoy_player/features/ai/domain/ai_provider.dart';
import 'package:enjoy_player/features/ai/domain/byok_vendor.dart';
import 'package:enjoy_player/features/ai/domain/modality_byok_config.dart';

part 'ai_service_config.freezed.dart';

/// Legacy BYOK shape (dev builds only). Secrets must not be persisted in Drift.
@freezed
abstract class BYOKConfig with _$BYOKConfig {
  const factory BYOKConfig({
    required BYOKVendor vendor,
    required String apiKey,
    String? endpoint,
    String? region,
    String? model,
  }) = _BYOKConfig;
}

@freezed
abstract class AIServiceConfig with _$AIServiceConfig {
  const factory AIServiceConfig({
    required AIProvider provider,
    @Deprecated('Use llmByok / speechByok; secrets live in ByokSecretStore')
    BYOKConfig? byok,
    LlmByokConfig? llmByok,
    SpeechByokConfig? speechByok,
    String? localModelId,
  }) = _AIServiceConfig;
}
