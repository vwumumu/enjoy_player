import 'package:enjoy_player/features/ai/domain/byok_config_validator.dart';
import 'package:enjoy_player/l10n/app_localizations.dart';

extension ByokValidationErrorL10n on ByokValidationError {
  String message(AppLocalizations l10n) => switch (this) {
    ByokValidationError.apiKeyRequired => l10n.byokValidationApiKeyRequired,
    ByokValidationError.baseUrlRequired => l10n.byokValidationBaseUrlRequired,
    ByokValidationError.baseUrlInvalid => l10n.byokValidationBaseUrlInvalid,
    ByokValidationError.modelRequired => l10n.byokValidationModelRequired,
    ByokValidationError.regionRequired => l10n.byokValidationRegionRequired,
    ByokValidationError.apiSpecRequired => l10n.byokValidationApiSpecRequired,
    ByokValidationError.azureKindRequired =>
      l10n.byokValidationAzureKindRequired,
  };
}

String formatByokValidationErrors(
  AppLocalizations l10n,
  List<ByokValidationError> errors,
) {
  if (errors.isEmpty) return '';
  return errors.map((e) => e.message(l10n)).join('\n');
}
