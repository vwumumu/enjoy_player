/// Design tokens: spacing, radii, motion, breakpoints, and accents (ThemeExtension).
library;

import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'colors.dart';

/// Premium modern-minimal tokens; use [EnjoyThemeTokens.of] from widgets.
@immutable
class EnjoyThemeTokens extends ThemeExtension<EnjoyThemeTokens> {
  const EnjoyThemeTokens({
    required this.space4,
    required this.space8,
    required this.space12,
    required this.space16,
    required this.space20,
    required this.space24,
    required this.space32,
    required this.space40,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.radiusXl,
    required this.radiusFull,
    required this.elevationBar,
    required this.elevationSurface,
    required this.breakpointRail,
    required this.breakpointTranscriptSideBySide,
    required this.motionFast,
    required this.motionStandard,
    required this.echoActive,
    required this.ccBadge,
    required this.transcriptLinePadding,
    required this.contentMaxWidth,
    required this.miniBarBlurSigma,
    required this.sidebarWidth,
    required this.sidebarBrandHeight,
    required this.transportHeight,
    required this.heroTitleLetterSpacing,
    required this.glassTint,
    required this.glassBorder,
    required this.gradientStart,
    required this.gradientEnd,
  });

  final double space4;
  final double space8;
  final double space12;
  final double space16;
  final double space20;
  final double space24;
  final double space32;
  final double space40;

  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double radiusXl;
  final double radiusFull;

  final double elevationBar;
  final double elevationSurface;

  /// Width at which shell shows extended sidebar (non-player routes).
  final double breakpointRail;

  /// Width at which video + transcript use side-by-side layout.
  final double breakpointTranscriptSideBySide;

  final Duration motionFast;
  final Duration motionStandard;

  final Color echoActive;
  final Color ccBadge;

  final EdgeInsets transcriptLinePadding;
  final double contentMaxWidth;

  /// Backdrop blur sigma for mini player / transport (0 = disabled).
  final double miniBarBlurSigma;

  /// Primary navigation sidebar width (desktop).
  final double sidebarWidth;

  /// Top brand row height inside sidebar.
  final double sidebarBrandHeight;

  /// Bottom transport: slim slider + control row.
  final double transportHeight;

  /// Negative tracking for hero display titles.
  final double heroTitleLetterSpacing;

  /// Tint over blurred glass surfaces.
  final Color glassTint;

  /// Hairline border on glass panels.
  final Color glassBorder;

  final Color gradientStart;
  final Color gradientEnd;

  static EnjoyThemeTokens of(BuildContext context) {
    return Theme.of(context).extension<EnjoyThemeTokens>() ??
        EnjoyThemeTokens.light(Theme.of(context).colorScheme);
  }

  /// Default light-token values aligned with [ColorScheme].
  factory EnjoyThemeTokens.light(ColorScheme scheme) {
    return EnjoyThemeTokens(
      space4: 4,
      space8: 8,
      space12: 12,
      space16: 16,
      space20: 20,
      space24: 24,
      space32: 32,
      space40: 40,
      radiusSm: 8,
      radiusMd: 12,
      radiusLg: 16,
      radiusXl: 20,
      radiusFull: 999,
      elevationBar: 2,
      elevationSurface: 1,
      breakpointRail: 900,
      breakpointTranscriptSideBySide: 720,
      motionFast: const Duration(milliseconds: 180),
      motionStandard: const Duration(milliseconds: 260),
      echoActive: AppColors.echoActive,
      ccBadge: scheme.primary,
      transcriptLinePadding: const EdgeInsets.all(12),
      contentMaxWidth: 720,
      miniBarBlurSigma: 12,
      sidebarWidth: 248,
      sidebarBrandHeight: 56,
      transportHeight: 88,
      heroTitleLetterSpacing: -1,
      glassTint: scheme.surface.withValues(alpha: 0.52),
      glassBorder: scheme.outlineVariant.withValues(alpha: 0.22),
      gradientStart: AppColors.gradientStart,
      gradientEnd: AppColors.gradientEnd,
    );
  }

  /// Dark uses same rhythm; echo accent stays consistent for brand recognition.
  factory EnjoyThemeTokens.dark(ColorScheme scheme) {
    return EnjoyThemeTokens.light(scheme).copyWith(
      ccBadge: scheme.primary,
      miniBarBlurSigma: 16,
      glassTint: scheme.surface.withValues(alpha: 0.42),
      glassBorder: scheme.outlineVariant.withValues(alpha: 0.28),
    );
  }

  @override
  EnjoyThemeTokens copyWith({
    double? space4,
    double? space8,
    double? space12,
    double? space16,
    double? space20,
    double? space24,
    double? space32,
    double? space40,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? radiusXl,
    double? radiusFull,
    double? elevationBar,
    double? elevationSurface,
    double? breakpointRail,
    double? breakpointTranscriptSideBySide,
    Duration? motionFast,
    Duration? motionStandard,
    Color? echoActive,
    Color? ccBadge,
    EdgeInsets? transcriptLinePadding,
    double? contentMaxWidth,
    double? miniBarBlurSigma,
    double? sidebarWidth,
    double? sidebarBrandHeight,
    double? transportHeight,
    double? heroTitleLetterSpacing,
    Color? glassTint,
    Color? glassBorder,
    Color? gradientStart,
    Color? gradientEnd,
  }) {
    return EnjoyThemeTokens(
      space4: space4 ?? this.space4,
      space8: space8 ?? this.space8,
      space12: space12 ?? this.space12,
      space16: space16 ?? this.space16,
      space20: space20 ?? this.space20,
      space24: space24 ?? this.space24,
      space32: space32 ?? this.space32,
      space40: space40 ?? this.space40,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      radiusXl: radiusXl ?? this.radiusXl,
      radiusFull: radiusFull ?? this.radiusFull,
      elevationBar: elevationBar ?? this.elevationBar,
      elevationSurface: elevationSurface ?? this.elevationSurface,
      breakpointRail: breakpointRail ?? this.breakpointRail,
      breakpointTranscriptSideBySide:
          breakpointTranscriptSideBySide ?? this.breakpointTranscriptSideBySide,
      motionFast: motionFast ?? this.motionFast,
      motionStandard: motionStandard ?? this.motionStandard,
      echoActive: echoActive ?? this.echoActive,
      ccBadge: ccBadge ?? this.ccBadge,
      transcriptLinePadding: transcriptLinePadding ?? this.transcriptLinePadding,
      contentMaxWidth: contentMaxWidth ?? this.contentMaxWidth,
      miniBarBlurSigma: miniBarBlurSigma ?? this.miniBarBlurSigma,
      sidebarWidth: sidebarWidth ?? this.sidebarWidth,
      sidebarBrandHeight: sidebarBrandHeight ?? this.sidebarBrandHeight,
      transportHeight: transportHeight ?? this.transportHeight,
      heroTitleLetterSpacing:
          heroTitleLetterSpacing ?? this.heroTitleLetterSpacing,
      glassTint: glassTint ?? this.glassTint,
      glassBorder: glassBorder ?? this.glassBorder,
      gradientStart: gradientStart ?? this.gradientStart,
      gradientEnd: gradientEnd ?? this.gradientEnd,
    );
  }

  @override
  ThemeExtension<EnjoyThemeTokens> lerp(
    covariant ThemeExtension<EnjoyThemeTokens>? other,
    double t,
  ) {
    if (other is! EnjoyThemeTokens) return this;
    if (t == 0) return this;
    if (t == 1) return other;
    return EnjoyThemeTokens(
      space4: lerpDouble(space4, other.space4, t)!,
      space8: lerpDouble(space8, other.space8, t)!,
      space12: lerpDouble(space12, other.space12, t)!,
      space16: lerpDouble(space16, other.space16, t)!,
      space20: lerpDouble(space20, other.space20, t)!,
      space24: lerpDouble(space24, other.space24, t)!,
      space32: lerpDouble(space32, other.space32, t)!,
      space40: lerpDouble(space40, other.space40, t)!,
      radiusSm: lerpDouble(radiusSm, other.radiusSm, t)!,
      radiusMd: lerpDouble(radiusMd, other.radiusMd, t)!,
      radiusLg: lerpDouble(radiusLg, other.radiusLg, t)!,
      radiusXl: lerpDouble(radiusXl, other.radiusXl, t)!,
      radiusFull: lerpDouble(radiusFull, other.radiusFull, t)!,
      elevationBar: lerpDouble(elevationBar, other.elevationBar, t)!,
      elevationSurface: lerpDouble(elevationSurface, other.elevationSurface, t)!,
      breakpointRail: lerpDouble(breakpointRail, other.breakpointRail, t)!,
      breakpointTranscriptSideBySide: lerpDouble(
        breakpointTranscriptSideBySide,
        other.breakpointTranscriptSideBySide,
        t,
      )!,
      motionFast: Duration(
        milliseconds: lerpDouble(
          motionFast.inMilliseconds.toDouble(),
          other.motionFast.inMilliseconds.toDouble(),
          t,
        )!.round(),
      ),
      motionStandard: Duration(
        milliseconds: lerpDouble(
          motionStandard.inMilliseconds.toDouble(),
          other.motionStandard.inMilliseconds.toDouble(),
          t,
        )!.round(),
      ),
      echoActive: Color.lerp(echoActive, other.echoActive, t)!,
      ccBadge: Color.lerp(ccBadge, other.ccBadge, t)!,
      transcriptLinePadding: EdgeInsets.lerp(
        transcriptLinePadding,
        other.transcriptLinePadding,
        t,
      )!,
      contentMaxWidth: lerpDouble(contentMaxWidth, other.contentMaxWidth, t)!,
      miniBarBlurSigma: lerpDouble(
        miniBarBlurSigma,
        other.miniBarBlurSigma,
        t,
      )!,
      sidebarWidth: lerpDouble(sidebarWidth, other.sidebarWidth, t)!,
      sidebarBrandHeight:
          lerpDouble(sidebarBrandHeight, other.sidebarBrandHeight, t)!,
      transportHeight: lerpDouble(transportHeight, other.transportHeight, t)!,
      heroTitleLetterSpacing: lerpDouble(
        heroTitleLetterSpacing,
        other.heroTitleLetterSpacing,
        t,
      )!,
      glassTint: Color.lerp(glassTint, other.glassTint, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      gradientStart: Color.lerp(gradientStart, other.gradientStart, t)!,
      gradientEnd: Color.lerp(gradientEnd, other.gradientEnd, t)!,
    );
  }
}
