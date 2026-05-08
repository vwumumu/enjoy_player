/// Placeholder UI for shadow-reading practice below the echo segment (web parity).
library;

import 'package:flutter/material.dart';

import 'package:enjoy_player/core/theme/enjoy_tokens.dart';

import 'package:enjoy_player/l10n/app_localizations.dart';

class ShadowReadingZonePlaceholder extends StatelessWidget {
  const ShadowReadingZonePlaceholder({
    required this.referenceSnippet,
    super.key,
  });

  /// Joined plain text for the current echo range (for visual context only).
  final String referenceSnippet;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final tok = EnjoyThemeTokens.of(context);
    final bodyStyle = Theme.of(context).textTheme.bodySmall;
    final titleStyle = Theme.of(context).textTheme.titleSmall;

    return Padding(
      padding: EdgeInsets.only(top: tok.space8, bottom: tok.space8),
      child: Material(
        color: Color.lerp(
          tok.echoActive.withValues(alpha: 0.28),
          scheme.surfaceContainerHighest,
          0.35,
        ),
        borderRadius: BorderRadius.circular(tok.radiusMd),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: tok.space16, vertical: tok.space12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.shadowReadingTitle, style: titleStyle),
              SizedBox(height: tok.space8),
              Text(
                l10n.shadowReadingHint,
                style: bodyStyle?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
              if (referenceSnippet.isNotEmpty) ...[
                SizedBox(height: tok.space12),
                Text(
                  l10n.shadowReadingReferenceSnippet,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: tok.space4),
                Text(
                  referenceSnippet,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: bodyStyle?.copyWith(color: scheme.onSurface),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
