/// Aligns primary transcript cues with a secondary track for bilingual UI.
library;

import 'package:enjoy_player/data/subtitle/transcript_line.dart';
import 'package:enjoy_player/features/player/application/echo_mode_provider.dart';

/// Secondary line whose midpoint falls within [primary]'s range, else nearest.
TranscriptLine? transcriptMatchSecondary(
  TranscriptLine primary,
  List<TranscriptLine> secondary,
) {
  if (secondary.isEmpty) return null;
  final pStart = primary.startSeconds;
  final pEnd = primary.endSeconds;

  for (final s in secondary) {
    final mid = s.startSeconds + (s.endSeconds - s.startSeconds) / 2;
    if (mid >= pStart && mid < pEnd) return s;
  }

  TranscriptLine? best;
  for (final s in secondary) {
    if (s.startSeconds < pEnd) best = s;
  }
  return best;
}

String echoReferencePlainText(List<TranscriptLine> lines, EchoState echo) {
  if (!echo.active) return '';
  final start = echo.startLineIndex;
  final end = echo.endLineIndex;
  if (start < 0 || end < 0 || start > end) return '';
  final parts = <String>[];
  for (var i = start; i <= end && i < lines.length; i++) {
    final plain = lines[i].text.replaceAll(RegExp(r'<[^>]*>'), '').trim();
    if (plain.isNotEmpty) parts.add(plain);
  }
  return parts.join(' ');
}
