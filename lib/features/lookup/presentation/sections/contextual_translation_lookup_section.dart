library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:enjoy_player/core/errors/app_failure.dart';
import 'package:enjoy_player/features/ai/domain/models/contextual_translation_result.dart';
import 'package:enjoy_player/features/lookup/application/lookup_section_providers.dart';
import 'package:enjoy_player/features/lookup/domain/lookup_request.dart';
import 'package:enjoy_player/core/theme/enjoy_tokens.dart';
import 'package:enjoy_player/features/lookup/presentation/widgets/lookup_error_row.dart';
import 'package:enjoy_player/features/lookup/presentation/widgets/lookup_expansion_card.dart';
import 'package:enjoy_player/features/lookup/presentation/widgets/lookup_section_shimmer.dart';
import 'package:enjoy_player/l10n/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ContextualTranslationLookupSection extends ConsumerWidget {
  const ContextualTranslationLookupSection({required this.request, super.key});

  final LookupRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final params = LookupContextualParams(
      text: request.selectedText,
      sourceLanguage: request.sourceLanguage,
      targetLanguage: request.targetLanguage,
      context: request.contextualContext,
    );
    final theme = Theme.of(context);
    final t = EnjoyThemeTokens.of(context);
    final mdStyle = MarkdownStyleSheet.fromTheme(theme).copyWith(
      p: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
      blockSpacing: t.space8,
      h1: theme.textTheme.headlineSmall,
      h2: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.2,
      ),
      h2Padding: EdgeInsets.only(top: t.space8, bottom: t.space4),
      h3: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.2,
      ),
      h3Padding: EdgeInsets.only(top: t.space8, bottom: t.space4),
    );

    return LookupExpansionCard(
      title: l10n.lookupSectionContextualTranslation,
      initiallyExpanded: false,
      leading: const Icon(Icons.article_outlined),
      bodyBuilder: (ctx) {
        final async = ref.watch(lookupSheetContextualProvider(params));
        return async.when(
          data: (ContextualTranslationResult d) {
            if (d.translatedText.trim().isEmpty) {
              return Text(l10n.lookupEmpty, style: theme.textTheme.bodyMedium);
            }
            return MarkdownBody(
              data: d.translatedText,
              selectable: true,
              styleSheet: mdStyle,
            );
          },
          loading: () => const LookupSectionShimmer(),
          error: (e, _) => LookupErrorRow(
            message: e is AppFailure ? e.message : e.toString(),
            onRetry: () =>
                ref.invalidate(lookupSheetContextualProvider(params)),
          ),
        );
      },
    );
  }
}
