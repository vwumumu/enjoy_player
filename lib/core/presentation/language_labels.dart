/// Localized labels for focus/media language tags.
library;

import 'package:enjoy_player/core/application/app_language_catalog.dart';
import 'package:enjoy_player/l10n/app_localizations.dart';

/// User-visible label for a focus or media language BCP-47 tag.
String focusLanguageLabel(AppLocalizations l10n, String tag) {
  if (tagsEqual(tag, kUnknownMediaLanguageTag)) {
    return l10n.mediaLanguageUnknown;
  }
  if (tagsEqual(tag, 'en-US')) return l10n.settingsLanguageOptionEnUs;
  if (tagsEqual(tag, 'en-GB')) return l10n.settingsLanguageOptionEnGb;
  if (tagsEqual(tag, 'ja-JP')) return l10n.settingsLanguageOptionJaJp;
  if (tagsEqual(tag, 'ko-KR')) return l10n.settingsLanguageOptionKoKr;
  if (tagsEqual(tag, 'es-ES')) return l10n.settingsLanguageOptionEsEs;
  if (tagsEqual(tag, 'es-MX')) return l10n.settingsLanguageOptionEsMx;
  if (tagsEqual(tag, 'fr-FR')) return l10n.settingsLanguageOptionFrFr;
  if (tagsEqual(tag, 'fr-CA')) return l10n.settingsLanguageOptionFrCa;
  if (tagsEqual(tag, 'zh-CN')) return l10n.settingsLanguageOptionZhCn;
  return tag;
}

/// Options for focus learning language picker.
List<LanguageChoiceEntry> focusLanguageChoices(AppLocalizations l10n) {
  return kSupportedFocusLanguageTags
      .map(
        (tag) => LanguageChoiceEntry(
          value: tag,
          label: focusLanguageLabel(l10n, tag),
        ),
      )
      .toList(growable: false);
}

/// Options for media content language picker (includes Unknown).
List<LanguageChoiceEntry> mediaLanguageChoices(AppLocalizations l10n) {
  return kSupportedMediaLanguageTags
      .map(
        (tag) => LanguageChoiceEntry(
          value: tag,
          label: focusLanguageLabel(l10n, tag),
        ),
      )
      .toList(growable: false);
}

class LanguageChoiceEntry {
  const LanguageChoiceEntry({required this.value, required this.label});

  final String value;
  final String label;
}
