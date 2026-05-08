/// Dedicated [media_kit.Player] for shadow-reading take previews (ADR-0003 scope).
///
/// Separate from [PlayerController]'s engine so lesson playback is not replaced.
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart' as mk;

import 'package:enjoy_player/core/logging/log.dart';

final _log = logNamed('recordingPreview');

/// Wraps a single `media_kit` player for local WAV (or other) preview files.
class RecordingPreviewPlayer {
  RecordingPreviewPlayer() : _player = mk.Player();

  final mk.Player _player;
  bool _disposed = false;

  /// Plays [path] from disk; stops any current preview first.
  Future<void> play(String path) async {
    if (_disposed) {
      throw StateError('RecordingPreviewPlayer disposed');
    }
    if (kIsWeb) {
      throw UnsupportedError(
        'Shadow recording playback is not available on web.',
      );
    }
    final file = File(path);
    if (!await file.exists()) {
      throw StateError('Recording file missing: $path');
    }
    final uri = Uri.file(file.absolute.path).toString();
    try {
      await stop();
      await _player.open(mk.Media(uri));
      await _player.play();
    } catch (e, st) {
      _log.warning('preview playback failed', e, st);
      rethrow;
    }
  }

  Future<void> stop() async {
    if (_disposed) return;
    await _player.stop();
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _player.dispose();
  }
}
