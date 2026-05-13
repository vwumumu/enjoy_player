library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:enjoy_player/core/errors/app_failure.dart';
import 'package:enjoy_player/features/ai/domain/models/dictionary_result.dart';
import 'package:enjoy_player/features/lookup/application/lookup_section_providers.dart';
import 'package:enjoy_player/features/lookup/domain/lookup_request.dart';
import 'package:enjoy_player/core/theme/enjoy_tokens.dart';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          d.word,
          style: tt.displaySmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        if (d.ipa != null && d.ipa!.trim().isNotEmpty) ...[
          SizedBox(height: t.space8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(t.radiusSm),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: t.space12,
                vertical: t.space4,
              ),
              child: Text(
                d.ipa!,
                style: tt.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
        if (showLemma) ...[
          SizedBox(height: t.space4),
          Text(
            '${l10n.lookupLemma} · $lemmaTrim',
            style: tt.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
        SizedBox(height: t.space12),
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

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(t.radiusSm),
      ),
      child: Padding(
        padding: EdgeInsets.all(t.space12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pos != null && pos.isNotEmpty) ...[
              Chip(
                label: Text(
                  pos,
                  style: tt.labelMedium?.copyWith(color: scheme.primary),
                ),
                side: BorderSide(color: scheme.outline.withValues(alpha: 0.45)),
                backgroundColor: scheme.primary.withValues(alpha: 0.06),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.symmetric(horizontal: t.space8),
              ),
              SizedBox(height: t.space8),
            ],
            if (sense.definition.trim().isNotEmpty)
              SelectableText(sense.definition, style: tt.bodyMedium),
            if (sense.translation != null &&
                sense.translation!.trim().isNotEmpty) ...[
              SizedBox(height: t.space8),
              SelectableText(
                sense.translation!,
                style: tt.bodyMedium?.copyWith(color: scheme.primary),
              ),
            ],
            if (sense.examples != null && sense.examples!.isNotEmpty) ...[
              SizedBox(height: t.space8),
              Text(
                l10n.lookupExamples,
                style: tt.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
              ),
              SizedBox(height: t.space4),
              for (final ex in sense.examples!)
                Padding(
                  padding: EdgeInsets.only(bottom: t.space8),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          width: 3,
                          color: scheme.primary.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                    padding: EdgeInsets.only(left: t.space8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(ex.source, style: tt.bodySmall),
                        if (ex.target != null &&
                            ex.target!.trim().isNotEmpty) ...[
                          SizedBox(height: t.space4),
                          SelectableText(
                            ex.target!,
                            style: tt.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
            if (sense.notes != null && sense.notes!.trim().isNotEmpty) ...[
              SizedBox(height: t.space8),
              Text(
                sense.notes!,
                style: tt.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
