/// Bottom sheet: translation, contextual translation, dictionary for a selection.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:enjoy_player/core/theme/enjoy_tokens.dart';
import 'package:enjoy_player/core/theme/widgets/sheet_drag_handle.dart';
import 'package:enjoy_player/features/lookup/domain/lookup_request.dart';
import 'package:enjoy_player/features/lookup/presentation/sections/contextual_translation_lookup_section.dart';
import 'package:enjoy_player/features/lookup/presentation/sections/dictionary_lookup_section.dart';
import 'package:enjoy_player/features/lookup/presentation/sections/translation_lookup_section.dart';
import 'package:enjoy_player/l10n/app_localizations.dart';

class DictionaryLookupSheet extends StatelessWidget {
  const DictionaryLookupSheet({required this.request, super.key});

  final LookupRequest request;

  double _sheetHorizontalPadding(EnjoyThemeTokens t) => t.space16 + t.space4;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = EnjoyThemeTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.35,
        maxChildSize: 0.92,
        expand: false,
        builder: (ctx, scrollCtrl) {
          return Column(
            children: [
              const PaddedSheetDragHandle(),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  _sheetHorizontalPadding(t),
                  t.space4,
                  _sheetHorizontalPadding(t),
                  t.space8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.lookupSheetTitle,
                            style: tt.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            request.selectedText,
                            style: tt.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Chip(
                                label: Text(
                                  '${request.sourceLanguage} → ${request.targetLanguage}',
                                  style: tt.labelMedium,
                                ),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.lookupCopy,
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: request.selectedText),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded),
                    ),
                    IconButton(
                      tooltip: l10n.lookupClose,
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.3)),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: EdgeInsets.fromLTRB(
                    _sheetHorizontalPadding(t),
                    t.space12,
                    _sheetHorizontalPadding(t),
                    t.space24,
                  ),
                  children: [
                    TranslationLookupSection(request: request),
                    SizedBox(height: t.space12),
                    ContextualTranslationLookupSection(request: request),
                    SizedBox(height: t.space12),
                    DictionaryLookupSection(request: request),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
