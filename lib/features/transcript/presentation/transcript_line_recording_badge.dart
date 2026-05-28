/// Mic + count badge for transcript lines with shadow-reading takes.
library;

import 'package:flutter/material.dart';

import 'package:enjoy_player/core/theme/enjoy_tokens.dart';
import 'package:enjoy_player/l10n/app_localizations.dart';

class TranscriptLineRecordingBadge extends StatelessWidget {
  const TranscriptLineRecordingBadge({required this.count, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final tok = EnjoyThemeTokens.of(context);
    final color = tok.echoActive;
    final l10n = AppLocalizations.of(context);
    final label = l10n?.transcriptLineRecordingCount(count) ?? '$count recordings';

    return Semantics(
      label: label,
      child: Tooltip(
        message: label,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mic_rounded, size: 16, color: color),
            SizedBox(width: tok.space4),
            Text(
              '$count',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
