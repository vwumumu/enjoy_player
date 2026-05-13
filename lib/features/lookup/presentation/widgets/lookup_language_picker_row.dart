/// Source / target language pills + swap for the dictionary lookup sheet.
library;

import 'package:flutter/material.dart';

import 'package:enjoy_player/core/application/app_language_catalog.dart';
import 'package:enjoy_player/core/interaction/enjoy_tappable.dart';
import 'package:enjoy_player/core/theme/enjoy_tokens.dart';
import 'package:enjoy_player/features/settings/presentation/widgets/language_choice_sheet.dart';
import 'package:enjoy_player/l10n/app_localizations.dart';

class LookupLanguagePickerRow extends StatelessWidget {
  const LookupLanguagePickerRow({
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.onSourceChanged,
    required this.onTargetChanged,
    required this.onSwap,
    super.key,
  });

  final String sourceLanguage;
  final String targetLanguage;
  final ValueChanged<String> onSourceChanged;
  final ValueChanged<String> onTargetChanged;
  final VoidCallback onSwap;

  String _label(String tag) =>
      kLookupLanguageLabels[normalizeBcp47Tag(tag)] ?? normalizeBcp47Tag(tag);

  Future<void> _pickSource(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final options = kSupportedNativeLanguageTags
        .map((v) => LanguageChoiceOption(value: v, label: _label(v)))
        .toList(growable: false);
    final picked = await showLanguageChoiceSheet(
      context: context,
      title: l10n.lookupPickSourceTitle,
      options: options,
      selectedValue: sourceLanguage,
    );
    if (picked != null && !tagsEqual(picked, sourceLanguage)) {
      onSourceChanged(picked);
      if (tagsEqual(picked, targetLanguage)) {
        final other = kSupportedNativeLanguageTags.firstWhere(
          (t) => !tagsEqual(t, picked),
          orElse: () => targetLanguage,
        );
        if (!tagsEqual(other, targetLanguage)) onTargetChanged(other);
      }
    }
  }

  Future<void> _pickTarget(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final allowed = kSupportedNativeLanguageTags
        .where((t) => !tagsEqual(t, sourceLanguage))
        .toList(growable: false);
    if (allowed.isEmpty) return;
    final options = allowed
        .map((v) => LanguageChoiceOption(value: v, label: _label(v)))
        .toList(growable: false);
    final picked = await showLanguageChoiceSheet(
      context: context,
      title: l10n.lookupPickTargetTitle,
      options: options,
      selectedValue: targetLanguage,
    );
    if (picked != null && !tagsEqual(picked, targetLanguage)) {
      onTargetChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = EnjoyThemeTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final canSwap = !tagsEqual(sourceLanguage, targetLanguage);
    final targetChoices = kSupportedNativeLanguageTags
        .where((x) => !tagsEqual(x, sourceLanguage))
        .toList(growable: false);

    Widget pill({
      required String semanticsLabel,
      required String text,
      required VoidCallback? onTap,
    }) {
      return EnjoyTappableSurface(
        borderRadius: BorderRadius.circular(t.radiusFull),
        onTap: onTap,
        semanticsLabel: semanticsLabel,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: t.space16,
              vertical: t.space8,
            ),
            child: Center(
              child: Text(
                text,
                style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(t.radiusFull),
            ),
            child: pill(
              semanticsLabel: l10n.lookupSourceLanguage,
              text: _label(sourceLanguage),
              onTap: () => _pickSource(context),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: t.space8),
          child: Tooltip(
            message: l10n.lookupSwapLanguages,
            child: EnjoyTappableSurface(
              borderRadius: BorderRadius.circular(t.radiusMd),
              onTap: canSwap ? onSwap : null,
              semanticsLabel: l10n.lookupSwapLanguages,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: Icon(
                    Icons.swap_horiz_rounded,
                    color: canSwap
                        ? scheme.onSurfaceVariant
                        : scheme.onSurfaceVariant.withValues(alpha: 0.38),
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(t.radiusFull),
            ),
            child: pill(
              semanticsLabel: l10n.lookupTargetLanguage,
              text: _label(targetLanguage),
              onTap: targetChoices.isEmpty ? null : () => _pickTarget(context),
            ),
          ),
        ),
      ],
    );
  }
}
