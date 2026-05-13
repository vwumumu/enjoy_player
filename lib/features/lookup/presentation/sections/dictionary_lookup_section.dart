library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:enjoy_player/core/errors/app_failure.dart';
import 'package:enjoy_player/core/theme/colors.dart';
import 'package:enjoy_player/core/theme/enjoy_tokens.dart';
import 'package:enjoy_player/features/ai/domain/models/dictionary_result.dart';
import 'package:enjoy_player/features/lookup/application/lookup_section_providers.dart';
import 'package:enjoy_player/features/lookup/domain/lookup_request.dart';
import 'package:enjoy_player/features/lookup/presentation/widgets/lookup_error_row.dart';
import 'package:enjoy_player/features/lookup/presentation/widgets/lookup_expansion_card.dart';
import 'package:enjoy_player/features/lookup/presentation/widgets/lookup_section_shimmer.dart';
import 'package:enjoy_player/l10n/app_localizations.dart';

class DictionaryLookupSection extends ConsumerWidget {
  const DictionaryLookupSection({required this.request, super.key});

  final LookupRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final params = LookupDictionaryParams(
      word: request.selectedText,
      sourceLanguage: request.sourceLanguage,
      targetLanguage: request.targetLanguage,
    );

    return LookupExpansionCard(
      title: l10n.lookupSectionDictionary,
      initiallyExpanded: false,
      leading: const Icon(Icons.menu_book_outlined),
      bodyBuilder: (ctx) {
        final async = ref.watch(lookupSheetDictionaryProvider(params));
        return async.when(
          data: (DictionaryResult d) => _DictionaryBody(d: d, l10n: l10n),
          loading: () => const LookupSectionShimmer(),
          error: (e, _) => LookupErrorRow(
            message: e is AppFailure ? e.message : e.toString(),
            onRetry: () =>
                ref.invalidate(lookupSheetDictionaryProvider(params)),
          ),
        );
      },
    );
  }
}

class _DictionaryBody extends StatelessWidget {
  const _DictionaryBody({required this.d, required this.l10n});

  final DictionaryResult d;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tt = theme.textTheme;
    final t = EnjoyThemeTokens.of(context);
    final lemmaTrim = d.lemma?.trim();
    final showLemma =
        lemmaTrim != null && lemmaTrim.isNotEmpty && lemmaTrim != d.word.trim();
    final ipaTrim = d.ipa?.trim();
    final hasIpa = ipaTrim != null && ipaTrim.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          d.word,
          style: tt.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.2,
            letterSpacing: -0.25,
          ),
        ),
        if (hasIpa || showLemma) ...[
          SizedBox(height: t.space8),
          Wrap(
            spacing: t.space8,
            runSpacing: t.space8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (hasIpa)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withValues(
                      alpha: 0.65,
                    ),
                    borderRadius: BorderRadius.circular(t.radiusFull),
                    border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: t.space12,
                      vertical: t.space4 + 1,
                    ),
                    child: Text(
                      ipaTrim,
                      style: tt.labelMedium?.copyWith(
                        fontFamily: 'monospace',
                        color: scheme.onSurfaceVariant,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              if (showLemma)
                Text(
                  '${l10n.lookupLemma} · $lemmaTrim',
                  style: tt.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
        SizedBox(height: t.space16),
        for (var i = 0; i < d.senses.length; i++) ...[
          if (i > 0) SizedBox(height: t.space12),
          _SenseTile(sense: d.senses[i], l10n: l10n),
        ],
      ],
    );
  }
}

class _SenseTile extends StatelessWidget {
  const _SenseTile({required this.sense, required this.l10n});

  final DictionarySense sense;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tt = theme.textTheme;
    final t = EnjoyThemeTokens.of(context);
    final pos = sense.partOfSpeech?.trim();
    final isDark = theme.brightness == Brightness.dark;
    final translationColor = isDark ? AppColors.brandOnDark : scheme.primary;

    return Material(
      color: scheme.surfaceContainerHigh.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(t.radiusMd),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(t.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pos != null && pos.isNotEmpty) ...[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(t.radiusFull),
                  border: Border.all(
                    color: scheme.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: t.space12,
                    vertical: t.space4 + 1,
                  ),
                  child: Text(
                    pos,
                    style: tt.labelMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: t.space12),
            ],
            if (sense.definition.trim().isNotEmpty)
              SelectableText(
                sense.definition,
                style: tt.bodyLarge?.copyWith(
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                ),
              ),
            if (sense.translation != null &&
                sense.translation!.trim().isNotEmpty) ...[
              SizedBox(height: t.space8),
              SelectableText(
                sense.translation!,
                style: tt.bodyLarge?.copyWith(
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                  color: translationColor,
                ),
              ),
            ],
            if (sense.examples != null && sense.examples!.isNotEmpty) ...[
              SizedBox(height: t.space12),
              Text(
                l10n.lookupExamples,
                style: tt.labelLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: t.space8),
              for (final ex in sense.examples!)
                Padding(
                  padding: EdgeInsets.only(bottom: t.space8),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLow.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(t.radiusSm),
                      border: Border(
                        left: BorderSide(
                          width: 3,
                          color: scheme.primary.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        t.space12,
                        t.space8,
                        t.space12,
                        t.space8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText(
                            ex.source,
                            style: tt.bodyMedium?.copyWith(height: 1.45),
                          ),
                          if (ex.target != null &&
                              ex.target!.trim().isNotEmpty) ...[
                            SizedBox(height: t.space4),
                            SelectableText(
                              ex.target!,
                              style: tt.bodyMedium?.copyWith(
                                height: 1.4,
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
            ],
            if (sense.notes != null && sense.notes!.trim().isNotEmpty) ...[
              SizedBox(height: t.space8),
              Text(
                sense.notes!,
                style: tt.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
