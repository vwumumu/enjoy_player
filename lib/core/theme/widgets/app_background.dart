/// Ambient backdrop — subtle gradient scaffold background, light/dark aware.
///
/// On player screens, [PlayerAmbientBackdrop] should overlay this with the
/// artwork color. On non-player screens this simple gradient provides
/// editorial depth without color noise.
library;

import 'package:flutter/material.dart';

import '../enjoy_tokens.dart';

/// Wraps [child] in a full-screen gradient background respecting the active
/// theme brightness. Replace the old plum radial with a warm neutral linear.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = EnjoyThemeTokens.of(context);
    final brightness = Theme.of(context).brightness;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [t.gradientStart, t.gradientEnd],
          stops: brightness == Brightness.dark
              ? const [0.0, 1.0]
              : const [0.0, 1.0],
        ),
      ),
      child: child,
    );
  }
}

/// Overlays a soft ambient tint from [accentColor] on top of the scaffold
/// background. Used in the expanded player and audio player layout.
class PlayerAmbientBackdrop extends StatelessWidget {
  const PlayerAmbientBackdrop({
    super.key,
    required this.child,
    this.accentColor,
    this.intensity = 0.07,
  });

  final Widget child;

  /// Artwork dominant color. When null, no tint overlay is applied.
  final Color? accentColor;

  /// Opacity of the ambient tint overlay (default 7%).
  final double intensity;

  @override
  Widget build(BuildContext context) {
    if (accentColor == null) return child;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Ambient tint overlay — very subtle
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.5,
                colors: [
                  accentColor!.withValues(alpha: intensity),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
