/// Overlap between shadow-reading recordings and transcript cue windows.
library;

import 'dart:math' as math;

import 'package:enjoy_player/data/db/app_database.dart';
import 'package:enjoy_player/data/subtitle/transcript_line.dart';

/// Whether [recording]'s reference window overlaps [line]'s cue window (ms).
///
/// Same rule as web transcript lines and echo-region queries:
/// `max(startA, startB) < min(endA, endB)`.
bool recordingOverlapsLine(RecordingRow recording, TranscriptLine line) {
  final recStart = recording.referenceStart;
  final recEnd = recording.referenceStart + recording.referenceDuration;
  final lineStart = line.startMs;
  final lineEnd = line.startMs + line.durationMs;
  return math.max(recStart, lineStart) < math.min(recEnd, lineEnd);
}

/// Count overlapping recordings per transcript line index (0-based).
Map<int, int> countRecordingsPerLineIndex(
  List<TranscriptLine> lines,
  List<RecordingRow> recordings,
) {
  if (lines.isEmpty || recordings.isEmpty) return const {};

  final counts = <int, int>{};
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    var count = 0;
    for (final r in recordings) {
      if (recordingOverlapsLine(r, line)) count++;
    }
    if (count > 0) counts[i] = count;
  }
  return counts;
}
