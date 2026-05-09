/// Semantic color tokens — neutral warm base, single brand amber accent.
/// Dynamic color from artwork is handled separately in dynamic_color/.
library;

import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Echo & feature accents ──────────────────────────────────────────────
  static const echoActive = Color(0xFFE65100);

  // ── Brand accent — warm amber (reserved for affordances, not chrome) ───
  static const brand = Color(0xFFF5A524);
  static const brandOnDark = Color(0xFFFFD580);

  // ── Dark surface ramp — warm near-black, not violet ───────────────────
  static const surfaceDark = Color(0xFF0B0B10);
  static const surfaceContainerLowestDark = Color(0xFF080810);
  static const surfaceContainerLowDark = Color(0xFF111118);
  static const surfaceContainerDark = Color(0xFF18181F);
  static const surfaceContainerHighDark = Color(0xFF202028);
  static const surfaceContainerHighestDark = Color(0xFF2A2A34);

  // ── Light surface ramp — warm off-white ───────────────────────────────
  static const surfaceLight = Color(0xFFFAFAF7);
  static const surfaceContainerLowestLight = Color(0xFFFFFFFF);
  static const surfaceContainerLowLight = Color(0xFFF4F4F0);
  static const surfaceContainerLight = Color(0xFFEEEEEA);
  static const surfaceContainerHighLight = Color(0xFFE8E8E4);
  static const surfaceContainerHighestLight = Color(0xFFE0E0DC);

  // ── Backdrop gradient for non-player routes ────────────────────────────
  static const gradientStartDark = Color(0xFF111118);
  static const gradientEndDark = Color(0xFF080810);

  static const gradientStartLight = Color(0xFFFAFAF7);
  static const gradientEndLight = Color(0xFFEEEEEA);

  // ── Seed for Material 3 ColorScheme.fromSeed ──────────────────────────
  static const seedAmber = Color(0xFFF5A524);

  // ── Legacy aliases kept for widgets that still reference them ─────────
  /// @deprecated Use surfaceDark
  static const surface = surfaceDark;
  /// @deprecated Use surfaceContainerLowestDark
  static const surfaceContainerLowest = surfaceContainerLowestDark;
  /// @deprecated Use surfaceContainerLowDark
  static const surfaceContainerLow = surfaceContainerLowDark;
  /// @deprecated Use surfaceContainerDark
  static const surfaceContainer = surfaceContainerDark;
  /// @deprecated Use surfaceContainerHighDark
  static const surfaceContainerHigh = surfaceContainerHighDark;
  /// @deprecated Use surfaceContainerHighestDark
  static const surfaceContainerHighest = surfaceContainerHighestDark;

  /// @deprecated Use gradientStartDark
  static const gradientStart = gradientStartDark;
  /// @deprecated Use gradientEndDark
  static const gradientEnd = gradientEndDark;

  /// @deprecated Use seedAmber
  static const seedViolet = seedAmber;
}
