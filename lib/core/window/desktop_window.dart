/// Thin helpers for OS-level window operations on desktop platforms only.
library;

import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';

/// Whether the current platform is a desktop (Windows, macOS, Linux).
bool get isDesktop =>
    defaultTargetPlatform == TargetPlatform.windows ||
    defaultTargetPlatform == TargetPlatform.macOS ||
    defaultTargetPlatform == TargetPlatform.linux;

/// Sets the window fullscreen state. No-op on non-desktop platforms.
Future<void> setWindowFullscreen(bool value) async {
  if (!isDesktop) return;
  await windowManager.setFullScreen(value);
}

/// Returns whether the window is currently fullscreen.
/// Always returns `false` on non-desktop platforms.
Future<bool> getWindowFullscreen() async {
  if (!isDesktop) return false;
  return windowManager.isFullScreen();
}
