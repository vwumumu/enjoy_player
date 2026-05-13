library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:enjoy_player/core/errors/app_failure.dart';
import 'package:enjoy_player/features/ai/domain/models/translation_result.dart';
import 'package:enjoy_player/features/lookup/application/lookup_section_providers.dart';
import 'package:enjoy_player/features/lookup/domain/lookup_request.dart';
import 'package:enjoy_player/features/lookup/presentation/widgets/lookup_error_row.dart';
import 'package:enjoy_player/features/lookup/presentation/widgets/lookup_expansion_card.dart';
import 'package:enjoy_player/l10n/app_localizations.dart';

class TranslationLookupSection extends ConsumerWidget {
  const TranslationLookupSection({required this.request, super.key});

  final LookupRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final params = LookupTranslationParams(
      text: request.selectedText,
      sourceLanguage: request.sourceLanguage,
      targetLanguage: request.targetLanguage,
    );
    final theme = Theme.of(context);

    return LookupExpansionCard(
      title: l10n.lookupSectionTranslation,
      initiallyExpanded: true,
      bodyBuilder: (ctx) {
        final async = ref.watch(lookupSheetTranslationProvider(params));
        return async.when(
          data: (TranslationResult d) {
            if (d.translatedText.trim().isEmpty) {
              return Text(l10n.lookupEmpty, style: theme.textTheme.bodyMedium);
            }
            return SelectableText(
              d.translatedText,
              style: theme.textTheme.bodyLarge,
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => LookupErrorRow(
            message: e is AppFailure ? e.message : e.toString(),
            onRetry: () => ref.invalidate(lookupSheetTranslationProvider(params)),
          ),
        );
      },
    );
  }
}
