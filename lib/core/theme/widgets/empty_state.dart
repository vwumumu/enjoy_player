/// Editorial empty-state primitive.
///
/// Shows a monochrome icon, a bold title, a muted subtitle, and an optional
/// primary action button — all within a generous centered layout.
library;

import 'package:flutter/material.dart';

import '../enjoy_tokens.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
    this.actionLabel,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? action;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final t = EnjoyThemeTokens.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: t.contentMaxWidth),
        child: Padding(
          padding: EdgeInsets.all(t.space40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 56,
                color: cs.onSurfaceVariant.withValues(alpha: 0.55),
              ),
              SizedBox(height: t.space24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: t.space8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              if (action != null && actionLabel != null) ...[
                SizedBox(height: t.space24),
                FilledButton(
                  onPressed: action,
                  child: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
