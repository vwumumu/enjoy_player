/// Editorial page header — large title, optional supporting line, trailing
/// action — mirrors Apple Music / Apple Podcasts heading style.
library;

import 'package:flutter/material.dart';

import '../enjoy_tokens.dart';

class EditorialHeader extends StatelessWidget {
  const EditorialHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final t = EnjoyThemeTokens.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: padding ??
          EdgeInsets.fromLTRB(t.space24, t.space24, t.space24, t.space16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (subtitle != null) ...[
                  Text(
                    subtitle!.toUpperCase(),
                    style: tt.labelSmall?.copyWith(
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w600,
                      color: cs.primary,
                    ),
                  ),
                  SizedBox(height: t.space4),
                ],
                Text(
                  title,
                  style: tt.displaySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: t.space16),
            trailing!,
          ],
        ],
      ),
    );
  }
}
