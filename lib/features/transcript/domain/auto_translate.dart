/// Domain models and pure helpers for transcript auto-translate.
library;

import 'package:meta/meta.dart';

import 'package:enjoy_player/core/ids/enjoy_ids.dart';
import 'package:enjoy_player/data/subtitle/transcript_line.dart';

/// Setup / eligibility state for Auto translate (not a media-wide job).
enum AutoTranslateStatus {
  /// AI track not selected / not hydrated.
  idle,

  /// AI secondary is active; lines translate on demand when visible.
  active,

  /// Eligibility or auth/credits block; picker shows a reason.
  blocked,
}

enum AutoTranslateBlockReason {
  signedOut,
  noPrimary,
  sameLanguage,
  credits,
  auth,
  stalePrimary,
}

/// UI-facing state for a media item's Auto translate secondary track.
@immutable
class AutoTranslateUiState {
  const AutoTranslateUiState({
    this.status = AutoTranslateStatus.idle,
    this.blockReason,
    this.aiTranscriptId,
    this.primaryTranscriptId,
    this.targetLanguage,
    this.inFlightIndexes = const {},
    this.failedLineIndexes = const {},
  });

  final AutoTranslateStatus status;
  final AutoTranslateBlockReason? blockReason;
  final String? aiTranscriptId;
  final String? primaryTranscriptId;
  final String? targetLanguage;

  /// Lines currently calling the translation API.
  final Set<int> inFlightIndexes;

  /// Lines that failed (exhausted quiet retries). Not auto-requested again
  /// until the learner explicitly re-translates that line.
  final Set<int> failedLineIndexes;

  bool get isActive => status == AutoTranslateStatus.active;

  bool isLineInFlight(int lineIndex) => inFlightIndexes.contains(lineIndex);

  bool isLineFailed(int lineIndex) => failedLineIndexes.contains(lineIndex);

  AutoTranslateUiState copyWith({
    AutoTranslateStatus? status,
    AutoTranslateBlockReason? blockReason,
    bool clearBlockReason = false,
    String? aiTranscriptId,
    bool clearAiTranscriptId = false,
    String? primaryTranscriptId,
    bool clearPrimaryTranscriptId = false,
    String? targetLanguage,
    bool clearTargetLanguage = false,
    Set<int>? inFlightIndexes,
    Set<int>? failedLineIndexes,
  }) {
    return AutoTranslateUiState(
      status: status ?? this.status,
      blockReason: clearBlockReason ? null : (blockReason ?? this.blockReason),
      aiTranscriptId: clearAiTranscriptId
          ? null
          : (aiTranscriptId ?? this.aiTranscriptId),
      primaryTranscriptId: clearPrimaryTranscriptId
          ? null
          : (primaryTranscriptId ?? this.primaryTranscriptId),
      targetLanguage: clearTargetLanguage
          ? null
          : (targetLanguage ?? this.targetLanguage),
      inFlightIndexes: inFlightIndexes ?? this.inFlightIndexes,
      failedLineIndexes: failedLineIndexes ?? this.failedLineIndexes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutoTranslateUiState &&
          other.status == status &&
          other.blockReason == blockReason &&
          other.aiTranscriptId == aiTranscriptId &&
          other.primaryTranscriptId == primaryTranscriptId &&
          other.targetLanguage == targetLanguage &&
          _setEquals(other.inFlightIndexes, inFlightIndexes) &&
          _setEquals(other.failedLineIndexes, failedLineIndexes);

  @override
  int get hashCode => Object.hash(
    status,
    blockReason,
    aiTranscriptId,
    primaryTranscriptId,
    targetLanguage,
    Object.hashAllUnordered(inFlightIndexes),
    Object.hashAllUnordered(failedLineIndexes),
  );
}

bool _setEquals(Set<int> a, Set<int> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  return a.containsAll(b);
}

/// Deterministic AI translation track id for a media + target language.
String autoTranslateAiTrackId({
  required String targetType,
  required String mediaId,
  required String targetLanguage,
}) =>
    enjoyTranscriptId(
      targetType: targetType,
      targetId: mediaId,
      language: targetLanguage,
      source: 'ai',
    );

/// Returns indexes with empty [text] in [aiLines], excluding [exclude].
List<int> pendingLineIndexes(
  List<TranscriptLine> aiLines, {
  Set<int> exclude = const {},
}) {
  final out = <int>[];
  for (var i = 0; i < aiLines.length; i++) {
    if (exclude.contains(i)) continue;
    if (aiLines[i].text.trim().isEmpty) out.add(i);
  }
  return out;
}

/// Whether [aiLines] no longer matches [primaryLines] timings/count or [primaryId].
bool isAutoTranslateTimelineStale({
  required String? referencePrimaryId,
  required String primaryId,
  required List<TranscriptLine> primaryLines,
  required List<TranscriptLine> aiLines,
}) {
  if (referencePrimaryId != primaryId) return true;
  if (primaryLines.length != aiLines.length) return true;
  for (var i = 0; i < primaryLines.length; i++) {
    if (primaryLines[i].startMs != aiLines[i].startMs ||
        primaryLines[i].durationMs != aiLines[i].durationMs) {
      return true;
    }
  }
  return false;
}

/// Builds a skeleton timeline mirroring primary timings with empty text.
List<TranscriptLine> buildAutoTranslateSkeleton(List<TranscriptLine> primaryLines) {
  return primaryLines
      .map(
        (p) => TranscriptLine(
          text: '',
          startMs: p.startMs,
          durationMs: p.durationMs,
        ),
      )
      .toList();
}

/// Orders pending line indexes by distance from [anchorIndex] (ties: lower first).
List<int> orderPendingLineIndexes({
  required int anchorIndex,
  required List<int> pending,
}) {
  if (pending.isEmpty) return const [];
  final copy = List<int>.from(pending);
  copy.sort((a, b) {
    final da = (a - anchorIndex).abs();
    final db = (b - anchorIndex).abs();
    if (da != db) return da.compareTo(db);
    return a.compareTo(b);
  });
  return copy;
}

/// Max concurrent in-flight translation requests per media.
const kAutoTranslateMaxConcurrency = 2;

/// Attempts per line (initial + one quiet retry) before marking failed.
const kAutoTranslateMaxLineAttempts = 2;

/// Only auto-request / keep waiting work within this many cues of the
/// playback highlight (or estimated scroll window).
const kAutoTranslateViewportWindow = 24;
