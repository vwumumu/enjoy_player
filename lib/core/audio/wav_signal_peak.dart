/// Best-effort peak scan inside a RIFF WAVE `data` chunk (diagnostics / silence check).
library;

import 'dart:io';
import 'dart:typed_data';

/// Parsed `fmt ` chunk fields we need for scanning.
final class WavFmtLayout {
  const WavFmtLayout({
    required this.audioFormat,
    required this.numChannels,
    required this.sampleRate,
    required this.bitsPerSample,
    required this.blockAlign,
  });

  /// 1 = PCM integer, 3 = IEEE float (common for Windows MF captures).
  final int audioFormat;
  final int numChannels;
  final int sampleRate;
  final int bitsPerSample;
  final int blockAlign;
}

/// Peak amplitude in the `data` chunk (0–1 full-scale).
final class WavPeakScan {
  const WavPeakScan({
    required this.fmt,
    required this.dataBytes,
    required this.peakNormalized,
  });

  final WavFmtLayout fmt;
  final int dataBytes;

  /// Max absolute sample as a fraction of full scale (PCM16: /32768, float: 0–1).
  final double peakNormalized;
}

bool _fourCc(Uint8List bytes, int offset, String ascii) {
  if (offset + 4 > bytes.length) return false;
  for (var i = 0; i < 4; i++) {
    if (bytes[offset + i] != ascii.codeUnitAt(i)) return false;
  }
  return true;
}

int _u16(Uint8List b, int o) => b[o] | (b[o + 1] << 8);
int _u32(Uint8List b, int o) =>
    b[o] | (b[o + 1] << 8) | (b[o + 2] << 16) | (b[o + 3] << 24);

/// Reads up to [maxReadBytes] from disk (whole file if smaller) and scans `data`.
Future<WavPeakScan?> scanWavDataPeakFromFile(
  String path, {
  int maxReadBytes = 32 * 1024 * 1024,
}) async {
  final f = File(path);
  if (!await f.exists()) return null;
  final len = await f.length();
  if (len < 44) return null;
  final n = len > maxReadBytes ? maxReadBytes : len;
  final builder = BytesBuilder(copy: false);
  await for (final chunk in f.openRead(0, n)) {
    builder.add(chunk);
  }
  return scanWavDataPeakFromBytes(builder.toBytes());
}

/// Same as [scanWavDataPeakFromFile] but for an in-memory prefix / full file.
WavPeakScan? scanWavDataPeakFromBytes(Uint8List bytes) {
  if (bytes.length < 44) return null;
  if (!_fourCc(bytes, 0, 'RIFF') || !_fourCc(bytes, 8, 'WAVE')) return null;

  WavFmtLayout? fmt;
  int? dataStart;
  int? dataSize;

  var offset = 12;
  while (offset + 8 <= bytes.length) {
    final chunkId = String.fromCharCodes(bytes.sublist(offset, offset + 4));
    final chunkSize = _u32(bytes, offset + 4);
    final chunkData = offset + 8;
    final afterChunk = chunkData + chunkSize;
    if (afterChunk > bytes.length) break;

    if (chunkId == 'fmt ') {
      if (chunkSize < 16) return null;
      fmt = WavFmtLayout(
        audioFormat: _u16(bytes, chunkData),
        numChannels: _u16(bytes, chunkData + 2),
        sampleRate: _u32(bytes, chunkData + 4),
        bitsPerSample: _u16(bytes, chunkData + 14),
        blockAlign: _u16(bytes, chunkData + 12),
      );
    } else if (chunkId == 'data') {
      dataStart = chunkData;
      dataSize = chunkSize;
      break;
    }

    final padded = chunkSize + (chunkSize.isOdd ? 1 : 0);
    offset += 8 + padded;
  }

  final f = fmt;
  final ds = dataStart;
  final dz = dataSize;
  if (f == null || ds == null || dz == null || dz <= 0) return null;

  final end = (ds + dz).clamp(0, bytes.length);
  final data = bytes.sublist(ds, end);

  switch (f.audioFormat) {
    case 1: // PCM integer
      if (f.bitsPerSample == 16 && f.blockAlign == 2 * f.numChannels) {
        var peak = 0.0;
        final frames = data.length ~/ f.blockAlign;
        for (var i = 0; i < frames; i++) {
          final off = i * f.blockAlign;
          for (var ch = 0; ch < f.numChannels; ch++) {
            final s = data[off + 2 * ch] | (data[off + 2 * ch + 1] << 8);
            final v = (s > 32767 ? s - 65536 : s).toDouble().abs();
            if (v > peak) peak = v;
          }
        }
        return WavPeakScan(
          fmt: f,
          dataBytes: dz,
          peakNormalized: peak / 32768.0,
        );
      }
      if (f.bitsPerSample == 32 && f.blockAlign == 4 * f.numChannels) {
        final bd = ByteData.sublistView(data);
        var peak = 0.0;
        final frames = data.length ~/ f.blockAlign;
        for (var i = 0; i < frames; i++) {
          final off = i * f.blockAlign;
          for (var ch = 0; ch < f.numChannels; ch++) {
            final v = bd.getInt32(off + 4 * ch, Endian.little).toDouble().abs();
            if (v > peak) peak = v;
          }
        }
        return WavPeakScan(
          fmt: f,
          dataBytes: dz,
          peakNormalized: peak / 2147483648.0,
        );
      }
      return null;
    case 3: // IEEE float
      if (f.bitsPerSample == 32 && f.blockAlign == 4 * f.numChannels) {
        final bd = ByteData.sublistView(data);
        var peak = 0.0;
        final frames = data.length ~/ f.blockAlign;
        for (var i = 0; i < frames; i++) {
          final off = i * f.blockAlign;
          for (var ch = 0; ch < f.numChannels; ch++) {
            final v = bd.getFloat32(off + 4 * ch, Endian.little).abs();
            if (v > peak) peak = v;
          }
        }
        return WavPeakScan(
          fmt: f,
          dataBytes: dz,
          peakNormalized: peak.clamp(0.0, 1.0),
        );
      }
      return null;
    default:
      return null;
  }
}

/// ~16-bit LSB — below this after normalization we treat FFmpeg output as silent.
const kWavSilencePeakNorm = 0.001;
