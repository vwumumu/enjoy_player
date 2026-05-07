/// Material 3 theme configuration.
library;

import 'package:flutter/material.dart';

ThemeData buildAppTheme(Brightness brightness) {
  final seed = const Color(0xFF1565C0);
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: brightness),
    useMaterial3: true,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
