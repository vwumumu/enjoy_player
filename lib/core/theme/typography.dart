/// Typography tokens — Inter Tight for display, Inter for UI.
/// Source Serif 4 for transcript reading (toggled at runtime via TranscriptTypographyTokens).
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Builds the base [TextTheme] using Inter family.
///
/// Display titles use Inter (approximating Inter Tight until the Google Fonts
/// package ships that variant — tracking is manually tightened to match).
TextTheme buildBaseTextTheme(TextTheme base, ColorScheme scheme) {
  // Apply Inter to the full theme, then hand-tune the scale.
  final inter = GoogleFonts.interTextTheme(base).apply(
    bodyColor: scheme.onSurface,
    displayColor: scheme.onSurface,
  );

  return inter.copyWith(
    // ── Display (hero titles) — tight tracking ─────────────────────────
    displayLarge: inter.displayLarge?.copyWith(
      fontSize: 48,
      fontWeight: FontWeight.w600,
      letterSpacing: -1.5,
      height: 1.1,
    ),
    displayMedium: inter.displayMedium?.copyWith(
      fontSize: 36,
      fontWeight: FontWeight.w600,
      letterSpacing: -1.2,
      height: 1.12,
    ),
    displaySmall: inter.displaySmall?.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.8,
      height: 1.15,
    ),

    // ── Headline ──────────────────────────────────────────────────────
    headlineLarge: inter.headlineLarge?.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.6,
      height: 1.18,
    ),
    headlineMedium: inter.headlineMedium?.copyWith(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.4,
      height: 1.2,
    ),
    headlineSmall: inter.headlineSmall?.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      height: 1.25,
    ),

    // ── Title ─────────────────────────────────────────────────────────
    titleLarge: inter.titleLarge?.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.15,
    ),
    titleMedium: inter.titleMedium?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.1,
    ),
    titleSmall: inter.titleSmall?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
    ),

    // ── Body ──────────────────────────────────────────────────────────
    bodyLarge: inter.bodyLarge?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.55,
    ),
    bodyMedium: inter.bodyMedium?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.5,
    ),
    bodySmall: inter.bodySmall?.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.45,
    ),

    // ── Label ─────────────────────────────────────────────────────────
    labelLarge: inter.labelLarge?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    labelMedium: inter.labelMedium?.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
    ),
    labelSmall: inter.labelSmall?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      fontFeatures: const [FontFeature.tabularFigures()],
    ),
  );
}

/// Theme extension carrying Source Serif 4 styles for transcript reading.
///
/// Widgets that render transcript lines read [TranscriptTypographyTokens.of]
/// and use [bodyStyle] / [secondaryStyle] when the user has enabled
/// serif reading mode.
@immutable
class TranscriptTypographyTokens extends ThemeExtension<TranscriptTypographyTokens> {
  const TranscriptTypographyTokens({
    required this.useSerif,
    required this.bodyStyle,
    required this.secondaryStyle,
    required this.timestampStyle,
  });

  final bool useSerif;
  final TextStyle bodyStyle;
  final TextStyle secondaryStyle;
  final TextStyle timestampStyle;

  static TranscriptTypographyTokens of(BuildContext context) {
    return Theme.of(context).extension<TranscriptTypographyTokens>() ??
        _fallback(Theme.of(context).textTheme, Theme.of(context).colorScheme);
  }

  static TranscriptTypographyTokens build({
    required bool useSerif,
    required TextTheme base,
    required ColorScheme scheme,
  }) {
    if (useSerif) {
      final serif = GoogleFonts.sourceSerif4TextTheme(base).apply(
        bodyColor: scheme.onSurface,
      );
      return TranscriptTypographyTokens(
        useSerif: true,
        bodyStyle: (serif.bodyLarge ?? const TextStyle()).copyWith(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          height: 1.65,
          letterSpacing: 0.01,
          color: scheme.onSurface,
        ),
        secondaryStyle: (serif.bodyMedium ?? const TextStyle()).copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.italic,
          height: 1.5,
          color: scheme.onSurfaceVariant,
        ),
        timestampStyle: (base.labelSmall ?? const TextStyle()).copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          fontFeatures: const [FontFeature.tabularFigures()],
          color: scheme.onSurfaceVariant,
        ),
      );
    }
    return _fallback(base, scheme);
  }

  static TranscriptTypographyTokens _fallback(TextTheme base, ColorScheme scheme) {
    return TranscriptTypographyTokens(
      useSerif: false,
      bodyStyle: (base.bodyLarge ?? const TextStyle()).copyWith(
        fontSize: 16,
        height: 1.6,
        color: scheme.onSurface,
      ),
      secondaryStyle: (base.bodySmall ?? const TextStyle()).copyWith(
        fontStyle: FontStyle.italic,
        color: scheme.onSurfaceVariant,
      ),
      timestampStyle: (base.labelSmall ?? const TextStyle()).copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
        color: scheme.onSurfaceVariant,
      ),
    );
  }

  @override
  TranscriptTypographyTokens copyWith({
    bool? useSerif,
    TextStyle? bodyStyle,
    TextStyle? secondaryStyle,
    TextStyle? timestampStyle,
  }) {
    return TranscriptTypographyTokens(
      useSerif: useSerif ?? this.useSerif,
      bodyStyle: bodyStyle ?? this.bodyStyle,
      secondaryStyle: secondaryStyle ?? this.secondaryStyle,
      timestampStyle: timestampStyle ?? this.timestampStyle,
    );
  }

  @override
  TranscriptTypographyTokens lerp(
    covariant ThemeExtension<TranscriptTypographyTokens>? other,
    double t,
  ) {
    if (other is! TranscriptTypographyTokens) return this;
    return TranscriptTypographyTokens(
      useSerif: t < 0.5 ? useSerif : other.useSerif,
      bodyStyle: TextStyle.lerp(bodyStyle, other.bodyStyle, t)!,
      secondaryStyle: TextStyle.lerp(secondaryStyle, other.secondaryStyle, t)!,
      timestampStyle: TextStyle.lerp(timestampStyle, other.timestampStyle, t)!,
    );
  }
}
