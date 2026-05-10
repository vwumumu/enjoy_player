/// Extract a single JPEG poster frame from a local video for library thumbnails.
library;

import 'dart:io';

import 'package:enjoy_player/core/logging/log.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'ffmpeg_media_probe.dart';

final _log = logNamed('VideoPosterExtract');

/// Ensures `media_thumbs/` under app documents exists and returns
/// `…/media_thumbs/<contentHashHex>.jpg`.
Future<String> videoThumbnailPathForContentHash(String contentHashHex) async {
  final docs = await getApplicationDocumentsDirectory();
  final dir = Directory(p.join(docs.path, 'media_thumbs'));
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  return p.join(dir.path, '$contentHashHex.jpg');
}

/// Writes one JPEG frame (~1s) from [mediaSourceUri] (`file:` or path) to [outputJpegPath].
///
/// Windows: subprocess via [FfmpegMediaProbe.resolveFfmpegExecutable].
/// Other platforms: [FFmpegKit.execute] (bundled libs on mobile).
///
/// Returns `true` when [outputJpegPath] exists and is non-empty after the run.
Future<bool> writeVideoPosterJpeg({
  required String mediaSourceUri,
  required String outputJpegPath,
}) async {
  final input = FfmpegMediaProbe.mediaInputForFfmpeg(mediaSourceUri);
  if (input.isEmpty) {
    _log.fine('video poster: empty media input');
    return false;
  }

  final parent = Directory(p.dirname(outputJpegPath));
  if (!await parent.exists()) {
    await parent.create(recursive: true);
  }

  try {
    if (Platform.isWindows) {
      final exe = await FfmpegMediaProbe.resolveFfmpegExecutable();
      if (exe == null) {
        _log.fine('video poster: no ffmpeg on Windows');
        return false;
      }
      final r = await Process.run(exe, [
        '-y',
        '-hide_banner',
        '-ss',
        '1',
        '-i',
        input,
        '-frames:v',
        '1',
        '-q:v',
        '3',
        outputJpegPath,
      ]);
      if (r.exitCode != 0) {
        _log.fine('video poster ffmpeg failed: ${r.stderr}');
        return false;
      }
    } else {
      final cmd =
          '-y -hide_banner -ss 1 -i ${_shellEscape(input)} '
          '-frames:v 1 -q:v 3 ${_shellEscape(outputJpegPath)}';
      final session = await FFmpegKit.execute(cmd);
      final code = await session.getReturnCode();
      if (!ReturnCode.isSuccess(code)) {
        _log.fine(
          'video poster FFmpegKit failed: ${await session.getOutput()}',
        );
        return false;
      }
    }

    final f = File(outputJpegPath);
    if (!await f.exists() || await f.length() == 0) {
      _log.fine('video poster: missing or empty output file');
      return false;
    }
    return true;
  } on Object catch (e, st) {
    _log.fine('video poster extract error', e, st);
    return false;
  }
}

String _shellEscape(String path) {
  if (path.contains(' ') || path.contains('"')) {
    return '"${path.replaceAll('"', r'\"')}"';
  }
  return path;
}
