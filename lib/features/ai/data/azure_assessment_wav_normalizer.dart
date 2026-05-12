/// Re-encode recordings to WAV that Azure Speech SDK accepts from disk.
///
/// `record` (and some encoders) emit float or non-standard RIFF layouts that
/// can trigger **SPXERR_UNEXPECTED_EOF** with [AudioConfig::FromWavFileInput].
/// Web uses 16 kHz mono 16-bit PCM WAV; we mirror that via FFmpeg.
library;

import 'dart:io';

import 'package:enjoy_player/core/logging/log.dart';
import 'package:enjoy_player/data/files/ffmpeg_media_probe.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

final _log = logNamed('ai.azure_assessment_wav');

String _shellEscape(String path) {
  if (path.contains(' ') || path.contains('"')) {
    return '"${path.replaceAll('"', r'\"')}"';
  }
  return path;
}

/// Runs FFmpeg to write **16 kHz, mono, signed 16-bit PCM** Microsoft WAV.
///
/// Returns `true` when [outputWavPath] exists and has at least 100 bytes.
Future<bool> normalizeWavForAzureAssessment({
  required String inputPath,
  required String outputWavPath,
}) async {
  if (inputPath.trim().isEmpty) return false;

  if (Platform.isWindows) {
    final exe = await FfmpegMediaProbe.resolveFfmpegExecutable();
    if (exe == null) {
      _log.fine('normalizeWav: no ffmpeg on Windows, skipping');
      return false;
    }
    final r = await Process.run(exe, [
      '-y',
      '-i',
      inputPath,
      '-vn',
      '-ac',
      '1',
      '-ar',
      '16000',
      '-sample_fmt',
      's16',
      '-c:a',
      'pcm_s16le',
      outputWavPath,
    ]);
    if (r.exitCode != 0) {
      _log.fine(
        'normalizeWav: ffmpeg failed (exit ${r.exitCode}): '
        '${r.stderr}',
      );
      return false;
    }
  } else {
    final cmd =
        '-y -i ${_shellEscape(inputPath)} -vn -ac 1 -ar 16000 '
        '-sample_fmt s16 -c:a pcm_s16le ${_shellEscape(outputWavPath)}';
    final session = await FFmpegKit.execute(cmd);
    final code = await session.getReturnCode();
    if (!ReturnCode.isSuccess(code)) {
      _log.fine(
        'normalizeWav: FFmpegKit failed: ${await session.getOutput()}',
      );
      return false;
    }
  }

  final out = File(outputWavPath);
  if (!out.existsSync()) return false;
  if (out.lengthSync() < 100) {
    _log.fine('normalizeWav: output too small (${out.lengthSync()} bytes)');
    try {
      await out.delete();
    } catch (_) {}
    return false;
  }
  return true;
}

/// If FFmpeg succeeds, returns a temp `.wav` path the caller must delete.
/// On failure returns `null` (caller should pass the original file to Azure).
Future<String?> tryCreateNormalizedAzureAssessmentWav(String inputPath) async {
  final out = p.join(
    Directory.systemTemp.path,
    'azure_assess_${const Uuid().v4()}.wav',
  );
  final ok = await normalizeWavForAzureAssessment(
    inputPath: inputPath,
    outputWavPath: out,
  );
  if (!ok) {
    try {
      final f = File(out);
      if (f.existsSync()) await f.delete();
    } catch (_) {}
    return null;
  }
  return File(out).absolute.path;
}
