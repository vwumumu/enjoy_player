/// Bottom sheet: translation, contextual translation, dictionary for a selection.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:enjoy_player/core/notices/app_notice.dart';
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

  Future<void> _copySelection(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    await Clipboard.setData(ClipboardData(text: widget.request.selectedText));
    if (!context.mounted) return;
    AppNotice.success(context, l10n.lookupCopySuccess);
  }

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
          return LayoutBuilder(
            builder: (context, constraints) {
              final maxBodyWidth = math.min(
                constraints.maxWidth,
                t.contentMaxWidth + 2 * hPad,
              );
              final bodyWidth = math.min(constraints.maxWidth, maxBodyWidth);

              Widget constrainBody(Widget child) {
                return Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(width: bodyWidth, child: child),
                );
              }

              return Column(
                children: [
                  const PaddedSheetDragHandle(),
                  constrainBody(
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
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          IconButton(
                            style: IconButton.styleFrom(
                              minimumSize: const Size(48, 48),
                              fixedSize: const Size(48, 48),
                              foregroundColor: scheme.onSurfaceVariant,
                            ),
                            tooltip: l10n.lookupClose,
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: scheme.outlineVariant.withValues(alpha: 0.18),
                  ),
                  constrainBody(
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        hPad,
                        t.space12,
                        hPad,
                        t.space12,
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(t.radiusLg),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              scheme.surfaceContainerHigh.withValues(
                                alpha: 0.55,
                              ),
                              scheme.surfaceContainerLow.withValues(
                                alpha: 0.98,
                              ),
                            ],
                          ),
                          border: Border.all(
                            color: scheme.outlineVariant.withValues(
                              alpha: 0.22,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.28),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(t.space16),
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
                                        height: 1.15,
                                        letterSpacing: -0.35,
                                      ),
                                      maxLines: 4,
                                    ),
                                  ),
                                  SizedBox(width: t.space4),
                                  IconButton.filledTonal(
                                    style: IconButton.styleFrom(
                                      minimumSize: const Size(48, 48),
                                      fixedSize: const Size(48, 48),
                                    ),
                                    tooltip: l10n.lookupCopy,
                                    onPressed: () => _copySelection(context),
                                    icon: const Icon(
                                      Icons.copy_rounded,
                                      size: 22,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: t.space16),
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
                      ),
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
                        Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: t.contentMaxWidth,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TranslationLookupSection(
                                  request: _effectiveRequest,
                                ),
                                SizedBox(height: t.space12),
                                ContextualTranslationLookupSection(
                                  request: _effectiveRequest,
                                ),
                                SizedBox(height: t.space12),
                                DictionaryLookupSection(
                                  request: _effectiveRequest,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
