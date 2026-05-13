/// Maps global echo line indices to the bounds valid for a given transcript list.
library;

import 'package:enjoy_player/features/player/application/echo_mode_provider.dart';

/// Echo state to use when rendering [lineCount] transcript lines.
///
/// Returns `null` when echo is off, there are no lines, or the echo segment does
/// not intersect this transcript (indices entirely out of range). Otherwise
/// returns [echo] or a clamped copy so `startLineIndex` / `endLineIndex` are
/// always within `[0, lineCount - 1]`.
EchoState? activeEchoForTranscript(EchoState echo, int lineCount) {
  if (!echo.active || lineCount <= 0) return null;

  final last = lineCount - 1;
  if (echo.startLineIndex > last || echo.endLineIndex < 0) return null;

  final start = echo.startLineIndex.clamp(0, last);
  final end = echo.endLineIndex.clamp(0, last);
  if (start > end) return null;

  if (start == echo.startLineIndex && end == echo.endLineIndex) {
    return echo;
  }
  return echo.copyWith(startLineIndex: start, endLineIndex: end);
}
