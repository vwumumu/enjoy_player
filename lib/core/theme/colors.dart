/// Semantic color tokens for the player UI (M3-friendly).
/// [AppColors.echoActive] is surfaced on widgets via [EnjoyThemeTokens.echoActive].
library;

import 'package:flutter/material.dart';

abstract final class AppColors {
  static const echoActive = Color(0xFFE65100);
  static const miniBarBlur = Color(0xE6FFFFFF);

  /// Violet seed (matches premium dark accent).
  static const seedViolet = Color(0xFF7C4DFF);

  /// Radial scaffold gradient — inner highlight (top-left).
  static const gradientStart = Color(0xFF1B0F3A);

  /// Radial scaffold gradient — outer floor (bottom-right).
  static const gradientEnd = Color(0xFF0A0814);

  /// Manual dark surfaces (override [ColorScheme.fromSeed] for premium depth).
  static const surface = Color(0xFF0E0B1A);
  static const surfaceContainerLowest = Color(0xFF0A0814);
  static const surfaceContainerLow = Color(0xFF14102A);
  static const surfaceContainer = Color(0xFF1A1535);
  static const surfaceContainerHigh = Color(0xFF231C46);
  static const surfaceContainerHighest = Color(0xFF2C2453);
}
