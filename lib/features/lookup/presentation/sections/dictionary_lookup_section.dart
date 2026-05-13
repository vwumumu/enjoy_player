library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:enjoy_player/core/errors/app_failure.dart';
import 'package:enjoy_player/features/ai/domain/models/dictionary_result.dart';
import 'package:enjoy_player/features/lookup/application/lookup_section_providers.dart';
import 'package:enjoy_player/features/lookup/domain/lookup_request.dart';
import 'package:enjoy_player/features/lookup/presentation/widgets/lookup_error_row.dart';
import 'package:enjoy_player/features/lookup/presentation/widgets/lookup_expansion_card.dart';
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
      bodyBuilder: (ctx) {
        final async = ref.watch(lookupSheetDictionaryProvider(params));
        return async.when(
          data: (DictionaryResult d) => _DictionaryBody(d: d, l10n: l10n),
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => LookupErrorRow(
            message: e is AppFailure ? e.message : e.toString(),
            onRetry: () => ref.invalidate(lookupSheetDictionaryProvider(params)),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: Text(
                d.word,
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            if (d.ipa != null && d.ipa!.trim().isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                d.ipa!,
                style: tt.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        if (d.lemma != null &&
            d.lemma!.trim().isNotEmpty &&
            d.lemma!.trim() != d.word.trim()) ...[
          const SizedBox(height: 4),
          Text(
            '${l10n.lookupLemma}: ${d.lemma}',
            style: tt.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
        const SizedBox(height: 12),
        for (var i = 0; i < d.senses.length; i++) ...[
          if (i > 0) const Divider(height: 24),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sense.partOfSpeech != null && sense.partOfSpeech!.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Chip(
              label: Text(sense.partOfSpeech!),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        if (sense.definition.trim().isNotEmpty)
          SelectableText(sense.definition, style: tt.bodyMedium),
        if (sense.translation != null && sense.translation!.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          SelectableText(
            sense.translation!,
            style: tt.bodyMedium?.copyWith(color: scheme.primary),
          ),
        ],
        if (sense.examples != null && sense.examples!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            l10n.lookupExamples,
            style: tt.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          for (final ex in sense.examples!)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: SelectableText(
                ex.target != null && ex.target!.trim().isNotEmpty
                    ? '${ex.source} — ${ex.target}'
                    : ex.source,
                style: tt.bodySmall,
              ),
            ),
        ],
        if (sense.notes != null && sense.notes!.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            sense.notes!,
            style: tt.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}
