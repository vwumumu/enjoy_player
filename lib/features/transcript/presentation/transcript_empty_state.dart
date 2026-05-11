/// Placeholder when a medium has no transcript cues yet.
library;

import 'package:flutter/material.dart';

import 'package:enjoy_player/core/theme/enjoy_tokens.dart';
import 'package:enjoy_player/l10n/app_localizations.dart';

class TranscriptEmptyState extends StatelessWidget {
  const TranscriptEmptyState({
    required this.onImport,
    this.showImportButton = true,
    super.key,
  });

  final VoidCallback onImport;

  /// When false, only cloud/hint copy (e.g. YouTube — no local file to import).
  final bool showImportButton;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = EnjoyThemeTokens.of(context);
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, viewport) {
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: t.space8,
            vertical: t.space16,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: viewport.maxHeight),
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(
                    alpha: 0.55,
                  ),
                  borderRadius: BorderRadius.circular(t.radiusMd),
                  border: Border.all(
                    color: scheme.outlineVariant.withValues(
                      alpha: 0.35,
                    ),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(t.space24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.subtitles_outlined,
                        size: 40,
                        color: scheme.primary.withValues(alpha: 0.85),
                      ),
                      SizedBox(height: t.space16),
                      Text(
                        l10n.noTranscript,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: t.space8),
                      Text(
                        l10n.noTranscriptHint,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                              height: 1.35,
                            ),
                      ),
                      SizedBox(height: t.space24),
                      if (showImportButton) ...[
                        FilledButton.icon(
                          onPressed: onImport,
                          icon: const Icon(Icons.upload_file_rounded),
                          label: Text(l10n.importSubtitle),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
