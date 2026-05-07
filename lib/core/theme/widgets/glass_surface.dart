/// Frosted glass panel (sidebar, transport bar).
library;

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../enjoy_tokens.dart';

class GlassSurface extends StatelessWidget {
  const GlassSurface({
    required this.child,
    this.sigma,
    this.padding,
    super.key,
  });

  final Widget child;
  final double? sigma;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final t = EnjoyThemeTokens.of(context);
    final cs = Theme.of(context).colorScheme;
    final blur = sigma ?? t.miniBarBlurSigma;

    Widget inner = Material(
      color: Colors.transparent,
      child: child,
    );

    if (padding != null) {
      inner = Padding(padding: padding!, child: inner);
    }

    if (blur <= 0) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh.withValues(alpha: 0.92),
          border: Border.all(color: t.glassBorder),
        ),
        child: inner,
      );
    }

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: t.glassTint,
            border: Border.all(color: t.glassBorder),
          ),
          child: inner,
        ),
      ),
    );
  }
}
