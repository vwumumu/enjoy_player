import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:enjoy_player/data/api/byok_secret_store.dart';
import 'package:enjoy_player/data/db/app_database_provider.dart';
import 'package:enjoy_player/features/ai/application/ai_modality_configs.dart';
import 'package:enjoy_player/features/ai/data/ai_modality_config_repository.dart';
import 'package:enjoy_player/features/ai/domain/ai_provider.dart';
import 'package:enjoy_player/features/ai/domain/ai_service_config.dart';
import 'package:enjoy_player/features/ai/domain/byok_config_validator.dart';
import 'package:enjoy_player/features/ai/domain/modality_kind.dart';

part 'ai_modality_config_controller.g.dart';

@Riverpod(keepAlive: true)
AiModalityConfigRepository aiModalityConfigRepository(Ref ref) {
  return AiModalityConfigRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(byokSecretStoreProvider),
    const ByokConfigValidator(),
  );
}

@Riverpod(keepAlive: true)
class AiModalityConfigCtrl extends _$AiModalityConfigCtrl {
  @override
  AiModalityConfigs build() {
    unawaited(Future<void>.microtask(_hydrate));
    return AiModalityConfigs.defaults;
  }

  Future<void> _hydrate() async {
    final repo = ref.read(aiModalityConfigRepositoryProvider);
    state = await repo.load();
  }

  Future<ByokValidationResult> saveModality({
    required ModalityKind modality,
    required AIServiceConfig config,
    String? apiKey,
  }) async {
    final repo = ref.read(aiModalityConfigRepositoryProvider);
    final result = await repo.saveModality(
      modality: modality,
      config: config,
      apiKey: apiKey,
    );
    if (result.isValid) {
      state = await repo.load();
    }
    return result;
  }

  Future<void> removeByok(ModalityKind modality) async {
    final repo = ref.read(aiModalityConfigRepositoryProvider);
    await repo.removeByok(modality);
    state = await repo.load();
  }

  Future<void> setEnjoy(ModalityKind modality) async {
    await saveModality(
      modality: modality,
      config: const AIServiceConfig(provider: AIProvider.enjoy),
    );
  }
}
