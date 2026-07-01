/// Captures the current video frame for practice posters while echo is active.
library;

import 'dart:typed_data';

import 'package:enjoy_player/core/logging/log.dart';
import 'package:enjoy_player/features/player/application/echo_mode_provider.dart';
import 'package:enjoy_player/features/player/application/player_engine.dart';
import 'package:enjoy_player/features/player/domain/playback_session.dart';

final _log = logNamed('PracticePosterEchoCapture');

/// Returns JPEG/PNG bytes from the open player when echo is active for [mediaId].
///
/// YouTube has no native screenshot surface: its WebView screenshot only
/// captures the HTML chrome, not the composited video frame, which renders
/// as a solid black rectangle. So [PlayerEngine.supportsVideoPosterCapture]
/// is `false` for YouTube and this resolver intentionally returns `null`,
/// letting the caller fall through to the local / network cover thumbnail
/// instead of a black frame.
Future<Uint8List?> capturePracticePosterEchoFrame({
  required PlayerEngine engine,
  required EchoState echo,
  required PlaybackSession? session,
  required String mediaId,
}) async {
  if (!echo.active) return null;
  if (session == null || session.mediaId != mediaId) return null;
  if (session.mediaType != 'video') return null;
  if (!engine.supportsVideoPosterCapture) return null;

  // Let the video stage settle on the current frame before capture.
  await Future<void>.delayed(const Duration(milliseconds: 150));

  try {
    final bytes = await engine.screenshot(format: 'image/jpeg');
    if (bytes != null && bytes.isNotEmpty) return bytes;
  } on Object catch (e, st) {
    _log.fine('Echo poster frame capture failed', e, st);
  }

  return null;
}
