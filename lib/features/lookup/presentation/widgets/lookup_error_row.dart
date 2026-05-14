library;

import 'package:flutter/material.dart';

import 'package:enjoy_player/core/errors/app_failure.dart';
import 'package:enjoy_player/core/theme/enjoy_tokens.dart';
import 'package:enjoy_player/l10n/app_localizations.dart';

/// User-facing text for lookup failures (translation, dictionary, contextual).
String lookupErrorUserMessage(Object error, AppLocalizations l10n) {
  return switch (error) {
    AuthFailure() => l10n.lookupCloudRequiresSignIn,
    AppFailure(:final message) => message,
    _ => error.toString(),
  };
}

class LookupErrorRow extends StatelessWidget {
  const LookupErrorRow({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final t = EnjoyThemeTokens.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(t.radiusMd),
        border: Border.all(color: scheme.error.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: EdgeInsets.all(t.space12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: scheme.error,
                  size: 24,
                ),
                SizedBox(width: t.space8),
                Expanded(
                  child: Text(
                    message,
                    style: tt.bodySmall?.copyWith(
                      color: scheme.onSurface,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: t.space12),
            FilledButton.tonalIcon(
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.symmetric(
                  horizontal: t.space16,
                  vertical: t.space8,
                ),
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text(l10n.lookupErrorRetry),
            ),
          ],
        ),
      ),
    );
  }
}
