import 'package:flutter/material.dart';

import 'package:enjoy_player/core/theme/enjoy_tokens.dart';

/// Pill-shaped drag affordance for modal bottom sheets (40×4, matches legacy
/// subtitle picker styling).
///
/// Use with [showModalBottomSheet] `showDragHandle: false` and prefer
/// [PaddedSheetDragHandle] for the standard vertical inset above sheet headers.
class SheetDragHandle extends StatelessWidget {
  const SheetDragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

/// [SheetDragHandle] wrapped with the shared vertical padding used on Enjoy
/// sheet chrome (subtitle track picker, pronunciation assessment, …).
class PaddedSheetDragHandle extends StatelessWidget {
  const PaddedSheetDragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final t = EnjoyThemeTokens.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: t.space12),
      child: const Center(child: SheetDragHandle()),
    );
  }
}
