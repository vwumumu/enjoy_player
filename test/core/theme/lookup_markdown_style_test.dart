import 'package:enjoy_player/core/theme/enjoy_tokens.dart';
import 'package:enjoy_player/core/theme/lookup_markdown_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

ThemeData _testTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF7B61FF),
    brightness: Brightness.dark,
  );
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    brightness: Brightness.dark,
    textTheme: Typography.material2021(
      platform: TargetPlatform.android,
    ).white.apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface),
    extensions: [EnjoyThemeTokens.build(scheme)],
  );
}

void main() {
  test('lookup markdown blockquote uses dark surface, not light blue', () {
    final theme = _testTheme();
    final tokens = theme.extension<EnjoyThemeTokens>()!;

    final sheet = buildLookupMarkdownStyleSheet(theme, tokens);
    final blockquote = sheet.blockquoteDecoration! as BoxDecoration;

    expect(blockquote.color, theme.colorScheme.surfaceContainerHigh);
    expect(blockquote.color, isNot(Colors.blue.shade100));
  });
}
