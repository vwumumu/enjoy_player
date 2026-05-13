/// Extra bottom clearance for floating notices above shell chrome (transport + nav).
library;

import 'package:flutter/material.dart';

import 'package:enjoy_player/core/theme/enjoy_tokens.dart';

/// Estimated total height of [GlobalTransportBar] (progress strip + control row +
/// padding). Slightly conservative so notices sit fully above the bar.
const double kRootShellTransportSnackClearance = 128;

/// Bottom nav bar content height + system home-indicator inset (Enjoy bottom nav).
double rootShellBottomNavClearance(BuildContext context) {
  final t = EnjoyThemeTokens.of(context);
  return t.bottomNavHeight + MediaQuery.paddingOf(context).bottom;
}

/// Provides bottom clearance for [AppNotice] when the routed subtree lives under
/// [RootShell] (mini transport and/or [EnjoyBottomNav]).
/// Nav clearance is [rootShellBottomNavClearance] (bar height + system bottom inset).
class RootShellBottomInset extends InheritedWidget {
  const RootShellBottomInset({
    required this.bottomClearance,
    required super.child,
    super.key,
  });

  /// Logical pixels to add above system bottom inset (transport + bottom nav).
  final double bottomClearance;

  static RootShellBottomInset? maybeOf(BuildContext context) {
    return context.findAncestorWidgetOfExactType<RootShellBottomInset>();
  }

  static double clearanceOf(BuildContext context) {
    return maybeOf(context)?.bottomClearance ?? 0;
  }

  @override
  bool updateShouldNotify(RootShellBottomInset oldWidget) {
    return bottomClearance != oldWidget.bottomClearance;
  }
}
