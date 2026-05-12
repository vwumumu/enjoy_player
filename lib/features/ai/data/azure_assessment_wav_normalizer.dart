/// Re-encode recordings to WAV that Azure Speech SDK accepts from disk.
///
/// `record` (and some encoders) emit float or non-standard RIFF layouts that
/// can trigger **SPXERR_UNEXPECTED_EOF** with [AudioConfig::FromWavFileInput].
/// Web uses 16 kHz mono 16-bit PCM WAV; we mirror that via FFmpeg.
library;

import 'dart:io';

import 'package:enjoy_player/core/audio/wav_signal_peak.dart';
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

Future<bool> _runFfmpegWindows({
  required String exe,
  required String inputPath,
  required String outputWavPath,
  required String audioFilter,
}) async {
  final r = await Process.run(exe, [
    '-nostdin',
    '-hide_banner',
    '-loglevel',
    'error',
    '-y',
    '-i',
    inputPath,
    '-vn',
    '-af',
    audioFilter,
    '-c:a',
    'pcm_s16le',
    outputWavPath,
  ]);
  if (r.exitCode != 0) {
    _log.fine(
      'normalizeWav: ffmpeg failed (exit ${r.exitCode}) filter="$audioFilter": '
      '${r.stderr}',
    );
    return false;
  }
  return true;
}

Future<bool> _runFfmpegKit({
  required String inputPath,
  required String outputWavPath,
  required String audioFilter,
}) async {
  final cmd =
      '-nostdin -hide_banner -loglevel error -y -i ${_shellEscape(inputPath)} '
      '-vn -af $audioFilter -c:a pcm_s16le ${_shellEscape(outputWavPath)}';
  final session = await FFmpegKit.execute(cmd);
  final code = await session.getReturnCode();
  if (!ReturnCode.isSuccess(code)) {
    _log.fine(
      'normalizeWav: FFmpegKit failed filter="$audioFilter": '
      '${await session.getOutput()}',
    );
    return false;
  }
  return true;
}

Future<void> _deleteIfExists(String path) async {
  try {
    final f = File(path);
    if (f.existsSync()) await f.delete();
  } on Object catch (_) {}
}

/// Runs FFmpeg to write **16 kHz, mono, signed 16-bit PCM** Microsoft WAV.
///
/// Returns `true` when [outputWavPath] exists, has at least 100 bytes, and
/// passes a **non-silent** peak check (guards against empty FFmpeg decode).
Future<bool> normalizeWavForAzureAssessment({
  required String inputPath,
  required String outputWavPath,
}) async {
  if (inputPath.trim().isEmpty) return false;

  final inScan = await scanWavDataPeakFromFile(inputPath);
  if (inScan != null) {
    _log.fine(
      'normalizeWav: input fmt=${inScan.fmt.audioFormat} ch=${inScan.fmt.numChannels} '
      '${inScan.fmt.sampleRate}Hz ${inScan.fmt.bitsPerSample}bit '
      'peak≈${inScan.peakNormalized.toStringAsFixed(5)}',
    );
  }

  const filterPrimary =
      'aresample=16000:resampler=swr,aformat=sample_fmts=s16:channel_layouts=mono';
  const filterLegacy = 'aresample=16000,aformat=sample_fmts=s16:channel_layouts=mono';

  Future<bool> encode(String filter) async {
    await _deleteIfExists(outputWavPath);
    if (Platform.isWindows) {
      final exe = await FfmpegMediaProbe.resolveFfmpegExecutable();
      if (exe == null) {
        _log.fine('normalizeWav: no ffmpeg on Windows, skipping');
        return false;
      }
      final ok = await _runFfmpegWindows(
        exe: exe,
        inputPath: inputPath,
        outputWavPath: outputWavPath,
        audioFilter: filter,
      );
      if (!ok) return false;
    } else {
      final ok = await _runFfmpegKit(
        inputPath: inputPath,
        outputWavPath: outputWavPath,
        audioFilter: filter,
      );
      if (!ok) return false;
    }

    final out = File(outputWavPath);
    if (!out.existsSync()) return false;
    if (out.lengthSync() < 100) {
      _log.fine('normalizeWav: output too small (${out.lengthSync()} bytes)');
      await _deleteIfExists(outputWavPath);
      return false;
    }

    final outScan = await scanWavDataPeakFromFile(outputWavPath);
    if (outScan == null) {
      _log.fine('normalizeWav: could not parse output WAV for peak check');
      return true;
    }
    if (outScan.peakNormalized < kWavSilencePeakNorm) {
      _log.warning(
        'normalizeWav: FFmpeg output appears silent '
        '(peak≈${outScan.peakNormalized.toStringAsFixed(6)} filter="$filter")',
      );
      await _deleteIfExists(outputWavPath);
      return false;
    }
    _log.fine(
      'normalizeWav: output ok peak≈${outScan.peakNormalized.toStringAsFixed(5)} '
      'bytes=${out.lengthSync()}',
    );
    return true;
  }

  if (await encode(filterPrimary)) return true;
  if (await encode(filterLegacy)) return true;

  await _deleteIfExists(outputWavPath);
  if (Platform.isWindows) {
    final exe = await FfmpegMediaProbe.resolveFfmpegExecutable();
    if (exe == null) return false;
    final r = await Process.run(exe, [
      '-nostdin',
      '-hide_banner',
      '-loglevel',
      'error',
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
        'normalizeWav: legacy ffmpeg failed (exit ${r.exitCode}): ${r.stderr}',
      );
      return false;
    }
  } else {
    final cmd =
        '-nostdin -hide_banner -loglevel error -y -i ${_shellEscape(inputPath)} '
        '-vn -ac 1 -ar 16000 -sample_fmt s16 -c:a pcm_s16le '
        '${_shellEscape(outputWavPath)}';
    final session = await FFmpegKit.execute(cmd);
    final code = await session.getReturnCode();
    if (!ReturnCode.isSuccess(code)) {
      _log.fine(
        'normalizeWav: legacy FFmpegKit failed: ${await session.getOutput()}',
      );
      return false;
    }
  }

  final out = File(outputWavPath);
  if (!out.existsSync() || out.lengthSync() < 100) {
    await _deleteIfExists(outputWavPath);
    return false;
  }
  final outScan = await scanWavDataPeakFromFile(outputWavPath);
  if (outScan != null && outScan.peakNormalized < kWavSilencePeakNorm) {
    _log.warning(
      'normalizeWav: legacy FFmpeg output still silent '
      '(peak≈${outScan.peakNormalized.toStringAsFixed(6)})',
    );
    await _deleteIfExists(outputWavPath);
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
