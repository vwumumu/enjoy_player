import 'package:enjoy_player/features/ai/domain/byok_not_configured_failure.dart';
import 'package:enjoy_player/features/ai/domain/modality_kind.dart';
import 'package:enjoy_player/l10n/app_localizations.dart';

/// Settings route for BYOK configuration.
const aiProvidersSettingsPath = '/settings/ai-providers';

bool isByokNotConfiguredFailure(Object error) =>
    error is ByokNotConfiguredFailure;

String formatByokNotConfiguredMessage(
  ByokNotConfiguredFailure failure,
  AppLocalizations l10n,
) {
  final modalityLabel = _modalityLabel(l10n, failure.modality);
  return l10n.byokNotConfiguredMessage(modalityLabel);
}

String formatByokNotConfiguredWithSettingsHint(
  ByokNotConfiguredFailure failure,
  AppLocalizations l10n,
) {
  return '${formatByokNotConfiguredMessage(failure, l10n)}\n'
      '${l10n.byokNotConfiguredOpenSettings}';
}

String _modalityLabel(AppLocalizations l10n, ModalityKind modality) {
  return switch (modality) {
    ModalityKind.llm => l10n.settingsAiProvidersModalityLlm,
    ModalityKind.asr => l10n.settingsAiProvidersModalityAsr,
    ModalityKind.tts => l10n.settingsAiProvidersModalityTts,
    ModalityKind.assessment => l10n.settingsAiProvidersModalityAssessment,
  };
}
