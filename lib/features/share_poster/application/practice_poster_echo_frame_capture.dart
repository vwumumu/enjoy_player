/// Captures the current video frame for practice posters while echo is active.
library;

import 'dart:typed_data';

import 'package:enjoy_player/core/logging/log.dart';
import 'package:enjoy_player/features/player/application/echo_mode_provider.dart';
import 'package:enjoy_player/features/player/application/engines/youtube/youtube_player_engine.dart';
import 'package:enjoy_player/features/player/application/player_engine.dart';
import 'package:enjoy_player/features/player/domain/playback_session.dart';

final _log = logNamed('PracticePosterEchoCapture');

/// Returns JPEG/PNG bytes from the open player when echo is active for [mediaId].
Future<Uint8List?> capturePracticePosterEchoFrame({
  required PlayerEngine engine,
  required EchoState echo,
  required PlaybackSession? session,
  required String mediaId,
}) async {
  if (!echo.active) return null;
  if (session == null || session.mediaId != mediaId) return null;
  if (session.mediaType != 'video') return null;

  // Let the video stage settle on the current frame before capture.
  await Future<void>.delayed(const Duration(milliseconds: 150));

  try {
    if (engine.supportsVideoPosterCapture) {
      final bytes = await engine.screenshot(format: 'image/jpeg');
      if (bytes != null && bytes.isNotEmpty) return bytes;
    }

    if (engine is YoutubePlayerEngine) {
      final bytes = await engine.captureWebViewScreenshot();
      if (bytes != null && bytes.isNotEmpty) return bytes;
    }
  } on Object catch (e, st) {
    _log.fine('Echo poster frame capture failed', e, st);
  }

  return null;
}
