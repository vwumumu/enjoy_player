/// Radial gradient backdrop (premium plum / violet wash).
library;

import 'package:flutter/material.dart';

import '../enjoy_tokens.dart';

/// Paints the global scaffold background used by [RootShell].
class AppBackground extends StatelessWidget {
  const AppBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = EnjoyThemeTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.85, -0.9),
          radius: 1.35,
          colors: [
            t.gradientStart,
            t.gradientEnd,
          ],
          stops: const [0.0, 1.0],
        ),
      ),
      child: child,
    );
  }
}
