/// Practice poster aggregate model and pure resolution helpers.
library;

import 'package:enjoy_player/data/db/app_database.dart';
import 'package:enjoy_player/data/subtitle/transcript_line.dart';
import 'package:enjoy_player/features/transcript/domain/transcript_recording_counts.dart';

/// Fixed logical poster size (9:16) — export uses [PracticePosterExport.pixelRatio].
const double practicePosterLogicalWidth = 360;
const double practicePosterLogicalHeight = 640;

const String practicePosterDownloadUrl = 'https://player.enjoy.bot';

/// One practiced line on the poster quote block.
class PracticePosterQuoteLine {
  const PracticePosterQuoteLine({
    required this.text,
    this.trailingEllipsis = false,
  });

  final String text;
  final bool trailingEllipsis;

  String get displayText => trailingEllipsis ? '$text...' : text;
}

/// Up to two hero sentences for the poster.
class PracticePosterQuote {
  const PracticePosterQuote({required this.lines});

  final List<PracticePosterQuoteLine> lines;

  bool get isEmpty => lines.isEmpty;
  bool get hasMultiple => lines.length > 1;
}

/// Aggregated inputs for rendering a practice poster.
class PracticePosterData {
  const PracticePosterData({
    required this.title,
    required this.coverSeed,
    required this.isVideo,
    this.localThumbnailPath,
    this.networkThumbnailUrl,
    this.quote,
    required this.takes,
    required this.sentencesPracticed,
    required this.spokenDurationMs,
  });

  final String title;
  final String coverSeed;
  final bool isVideo;
  final String? localThumbnailPath;
  final String? networkThumbnailUrl;
  final PracticePosterQuote? quote;
  final int takes;
  final int sentencesPracticed;
  final int spokenDurationMs;

  bool get hasPractice => takes > 0;
}

/// Computes poster stats from local recordings and transcript lines.
({int takes, int sentencesPracticed, int spokenDurationMs}) computePracticePosterStats({
  required List<RecordingRow> recordings,
  required List<TranscriptLine> lines,
}) {
  if (recordings.isEmpty) {
    return (takes: 0, sentencesPracticed: 0, spokenDurationMs: 0);
  }

  final takes = recordings.length;
  final spokenDurationMs = recordings.fold<int>(
    0,
    (sum, r) => sum + r.duration,
  );

  final perLine = countRecordingsPerLineIndex(lines, recordings);
  final sentencesPracticed = perLine.length;

  return (
    takes: takes,
    sentencesPracticed: sentencesPracticed,
    spokenDurationMs: spokenDurationMs,
  );
}

final RegExp _sentenceEndPattern = RegExp(
  r'''[.!?。！？…]["'\”\」\』]?\s*$''',
);

/// Subtitle cues are often mid-sentence fragments — treat as incomplete unless
/// they end with recognizable sentence punctuation.
bool isLikelyIncompleteSentence(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return false;
  return !_sentenceEndPattern.hasMatch(trimmed);
}

PracticePosterQuoteLine _quoteLineFromText(String text) {
  final trimmed = text.trim();
  return PracticePosterQuoteLine(
    text: trimmed,
    trailingEllipsis: isLikelyIncompleteSentence(trimmed),
  );
}

List<int> _rankedPracticedLineIndices(
  Map<int, int> perLine,
  List<TranscriptLine> lines,
) {
  final indices = perLine.keys.toList()
    ..sort((a, b) {
      final countCmp = perLine[b]!.compareTo(perLine[a]!);
      if (countCmp != 0) return countCmp;
      return lines[b].text.trim().length.compareTo(lines[a].text.trim().length);
    });
  return indices;
}

/// Hero quote: top two most-practiced transcript lines (with `...` when
/// incomplete), then longest [referenceText] fallback.
PracticePosterQuote? resolvePracticePosterQuote({
  required List<TranscriptLine> lines,
  required List<RecordingRow> recordings,
}) {
  if (recordings.isEmpty) return null;

  if (lines.isNotEmpty) {
    final perLine = countRecordingsPerLineIndex(lines, recordings);
    if (perLine.isNotEmpty) {
      final ranked = _rankedPracticedLineIndices(perLine, lines);
      final quoteLines = <PracticePosterQuoteLine>[];
      for (final index in ranked.take(2)) {
        final text = lines[index].text.trim();
        if (text.isEmpty) continue;
        quoteLines.add(_quoteLineFromText(text));
      }
      if (quoteLines.isNotEmpty) {
        return PracticePosterQuote(lines: quoteLines);
      }
    }
  }

  String? longestRef;
  var longestLen = 0;
  for (final r in recordings) {
    final t = r.referenceText.trim();
    if (t.isEmpty) continue;
    if (t.length > longestLen) {
      longestLen = t.length;
      longestRef = t;
    }
  }
  if (longestRef == null) return null;
  return PracticePosterQuote(lines: [_quoteLineFromText(longestRef)]);
}

/// @deprecated Use [resolvePracticePosterQuote].
String? resolvePracticePosterHeroText({
  required List<TranscriptLine> lines,
  required List<RecordingRow> recordings,
}) {
  final quote = resolvePracticePosterQuote(
    lines: lines,
    recordings: recordings,
  );
  if (quote == null || quote.lines.isEmpty) return null;
  return quote.lines.first.displayText;
}
