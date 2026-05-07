/// Material 3 theme configuration with premium modern-minimal tuning.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';
import 'enjoy_tokens.dart';

ThemeData buildAppTheme(Brightness brightness) {
  final baseScheme = ColorScheme.fromSeed(
    seedColor: AppColors.seedViolet,
    brightness: brightness,
  );

  final colorScheme =
      brightness == Brightness.dark ? _premiumDarkScheme(baseScheme) : baseScheme;

  final tokens = brightness == Brightness.light
      ? EnjoyThemeTokens.light(colorScheme)
      : EnjoyThemeTokens.dark(colorScheme);

  final baseTheme = ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    brightness: brightness,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  final inter = GoogleFonts.interTextTheme(baseTheme.textTheme).apply(
    bodyColor: colorScheme.onSurface,
    displayColor: colorScheme.onSurface,
  );

  final textTheme = inter.copyWith(
    displayMedium: inter.displayMedium?.copyWith(
      fontSize: 40,
      fontWeight: FontWeight.w600,
      letterSpacing: tokens.heroTitleLetterSpacing,
      height: 1.15,
    ),
    headlineLarge: inter.headlineLarge?.copyWith(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
      height: 1.2,
    ),
    headlineMedium: inter.headlineMedium?.copyWith(
      fontSize: 26,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.4,
      height: 1.22,
    ),
    headlineSmall: inter.headlineSmall?.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
    ),
    labelMedium: inter.labelMedium?.copyWith(letterSpacing: 0.2),
    labelSmall: inter.labelSmall?.copyWith(
      letterSpacing: 0.15,
      fontFeatures: const [FontFeature.tabularFigures()],
    ),
  );

  final navigationBarTheme = NavigationBarThemeData(
    height: 72,
    backgroundColor: colorScheme.surface.withValues(alpha: 0.72),
    indicatorColor: colorScheme.secondaryContainer,
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      final selected = states.contains(WidgetState.selected);
      return textTheme.labelMedium?.copyWith(
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        letterSpacing: 0.2,
      );
    }),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      final selected = states.contains(WidgetState.selected);
      return IconThemeData(
        size: 24,
        color:
            selected ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant,
      );
    }),
  );

  final railTheme = NavigationRailThemeData(
    backgroundColor: colorScheme.surfaceContainerLow,
    indicatorColor: colorScheme.secondaryContainer,
    selectedIconTheme: IconThemeData(color: colorScheme.onSecondaryContainer),
    unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
    selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurface,
    ),
    unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
    ),
    minWidth: 88,
    minExtendedWidth: 200,
  );

  final inactiveSlider =
      colorScheme.onSurface.withValues(alpha: brightness == Brightness.dark ? 0.12 : 0.18);

  final sliderTheme = SliderThemeData(
    trackHeight: 2,
    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
    overlayShape: SliderComponentShape.noOverlay,
    activeTrackColor: colorScheme.primary,
    inactiveTrackColor: inactiveSlider,
    thumbColor: colorScheme.primary,
    overlayColor: colorScheme.primary.withValues(alpha: 0.12),
  );

  final snackBarTheme = SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(tokens.radiusMd),
    ),
    backgroundColor: colorScheme.inverseSurface,
    contentTextStyle: textTheme.bodyMedium?.copyWith(
      color: colorScheme.onInverseSurface,
    ),
    actionTextColor: colorScheme.inversePrimary,
  );

  final bottomSheetTheme = BottomSheetThemeData(
    backgroundColor: colorScheme.surfaceContainerHigh,
    surfaceTintColor: Colors.transparent,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(tokens.radiusLg)),
    ),
    dragHandleColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
    dragHandleSize: const Size(40, 4),
    showDragHandle: false,
  );

  final cardTheme = CardThemeData(
    elevation: tokens.elevationSurface,
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(tokens.radiusLg),
      side: BorderSide(
        color: colorScheme.outlineVariant.withValues(alpha: 0.18),
      ),
    ),
    color: colorScheme.surfaceContainerLow.withValues(alpha: 0.6),
  );

  final listTileTheme = ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(
      horizontal: tokens.space16,
      vertical: tokens.space4,
    ),
    iconColor: colorScheme.onSurfaceVariant,
    titleTextStyle: textTheme.titleMedium,
    subtitleTextStyle: textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    ),
    minVerticalPadding: tokens.space12,
  );

  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    brightness: brightness,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    extensions: <ThemeExtension<dynamic>>[tokens],
    textTheme: textTheme,
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
    ),
    cardTheme: cardTheme,
    listTileTheme: listTileTheme,
    navigationBarTheme: navigationBarTheme,
    navigationRailTheme: railTheme,
    sliderTheme: sliderTheme,
    snackBarTheme: snackBarTheme,
    bottomSheetTheme: bottomSheetTheme,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space24,
          vertical: tokens.space12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusSm),
        ),
        textStyle: textTheme.labelLarge?.copyWith(letterSpacing: 0.2),
      ),
    ),
    iconTheme: IconThemeData(
      color: colorScheme.onSurfaceVariant,
      size: 24,
    ),
    dividerTheme: DividerThemeData(
      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
      thickness: 1,
      space: 1,
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusLg),
      ),
      backgroundColor: colorScheme.surfaceContainerHigh,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: colorScheme.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusSm),
      ),
      elevation: 3,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.fuchsia: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}

/// Deep plum surfaces + slightly brighter inverse primary for chips on inverse surface.
ColorScheme _premiumDarkScheme(ColorScheme base) {
  return base.copyWith(
    surface: AppColors.surface,
    surfaceDim: AppColors.surfaceContainerLowest,
    surfaceBright: AppColors.surfaceContainerHighest,
    surfaceContainerLowest: AppColors.surfaceContainerLowest,
    surfaceContainerLow: AppColors.surfaceContainerLow,
    surfaceContainer: AppColors.surfaceContainer,
    surfaceContainerHigh: AppColors.surfaceContainerHigh,
    surfaceContainerHighest: AppColors.surfaceContainerHighest,
    inversePrimary: Color.lerp(base.inversePrimary, const Color(0xFFE8DEF8), 0.35)!,
  );
}
