/// Bottom sheet: translation, contextual translation, dictionary for a selection.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:enjoy_player/core/theme/enjoy_tokens.dart';
import 'package:enjoy_player/core/theme/widgets/sheet_drag_handle.dart';
import 'package:enjoy_player/features/lookup/domain/lookup_request.dart';
import 'package:enjoy_player/features/lookup/presentation/sections/contextual_translation_lookup_section.dart';
import 'package:enjoy_player/features/lookup/presentation/sections/dictionary_lookup_section.dart';
import 'package:enjoy_player/features/lookup/presentation/sections/translation_lookup_section.dart';
import 'package:enjoy_player/features/lookup/presentation/widgets/lookup_language_picker_row.dart';
import 'package:enjoy_player/l10n/app_localizations.dart';

class DictionaryLookupSheet extends ConsumerStatefulWidget {
  const DictionaryLookupSheet({required this.request, super.key});

  final LookupRequest request;

  @override
  ConsumerState<DictionaryLookupSheet> createState() =>
      _DictionaryLookupSheetState();
}

class _DictionaryLookupSheetState extends ConsumerState<DictionaryLookupSheet> {
  late String _sourceLanguage;
  late String _targetLanguage;

  @override
  void initState() {
    super.initState();
    _sourceLanguage = widget.request.sourceLanguage;
    _targetLanguage = widget.request.targetLanguage;
  }

  double _sheetHorizontalPadding(EnjoyThemeTokens t) => t.space16 + t.space4;

  LookupRequest get _effectiveRequest => LookupRequest(
    selectedText: widget.request.selectedText,
    sourceLanguage: _sourceLanguage,
    targetLanguage: _targetLanguage,
    contextualContext: widget.request.contextualContext,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = EnjoyThemeTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final hPad = _sheetHorizontalPadding(t);

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
                  hPad,
                  t.space4,
                  hPad,
                  t.space8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        l10n.lookupSheetTitle,
                        style: tt.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      style: IconButton.styleFrom(
                        minimumSize: const Size(48, 48),
                        fixedSize: const Size(48, 48),
                      ),
                      tooltip: l10n.lookupClose,
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: scheme.outlineVariant.withValues(alpha: 0.18),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  hPad,
                  t.space12,
                  hPad,
                  t.space8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SelectableText(
                            widget.request.selectedText,
                            style: tt.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 3,
                          ),
                        ),
                        IconButton(
                          style: IconButton.styleFrom(
                            minimumSize: const Size(48, 48),
                            fixedSize: const Size(48, 48),
                          ),
                          tooltip: l10n.lookupCopy,
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(text: widget.request.selectedText),
                            );
                          },
                          icon: const Icon(Icons.copy_rounded),
                        ),
                      ],
                    ),
                    SizedBox(height: t.space8),
                    LookupLanguagePickerRow(
                      sourceLanguage: _sourceLanguage,
                      targetLanguage: _targetLanguage,
                      onSourceChanged: (v) =>
                          setState(() => _sourceLanguage = v),
                      onTargetChanged: (v) =>
                          setState(() => _targetLanguage = v),
                      onSwap: () {
                        setState(() {
                          final s = _sourceLanguage;
                          _sourceLanguage = _targetLanguage;
                          _targetLanguage = s;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: scheme.outlineVariant.withValues(alpha: 0.18),
              ),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: EdgeInsets.fromLTRB(
                    hPad,
                    t.space12,
                    hPad,
                    t.space24,
                  ),
                  children: [
                    TranslationLookupSection(request: _effectiveRequest),
                    SizedBox(height: t.space12),
                    ContextualTranslationLookupSection(
                      request: _effectiveRequest,
                    ),
                    SizedBox(height: t.space12),
                    DictionaryLookupSection(request: _effectiveRequest),
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
