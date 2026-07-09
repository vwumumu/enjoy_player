import 'package:enjoy_player/data/subtitle/transcript_line.dart';
import 'package:enjoy_player/features/transcript/domain/auto_translate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pendingLineIndexes finds empty texts only', () {
    const lines = [
      TranscriptLine(text: 'done', startMs: 0, durationMs: 1000),
      TranscriptLine(text: '', startMs: 1000, durationMs: 500),
      TranscriptLine(text: '   ', startMs: 1500, durationMs: 500),
    ];
    expect(pendingLineIndexes(lines), [1, 2]);
  });

  test('pendingLineIndexes excludes exhausted failures', () {
    const lines = [
      TranscriptLine(text: '', startMs: 0, durationMs: 1000),
      TranscriptLine(text: '', startMs: 1000, durationMs: 500),
      TranscriptLine(text: '', startMs: 1500, durationMs: 500),
    ];
    expect(pendingLineIndexes(lines, exclude: {0, 2}), [1]);
  });

  test('ui state tracks in-flight and failed line indexes', () {
    const a = AutoTranslateUiState(
      status: AutoTranslateStatus.active,
      inFlightIndexes: {1},
      failedLineIndexes: {3},
    );
    expect(a.isActive, isTrue);
    expect(a.isLineInFlight(1), isTrue);
    expect(a.isLineInFlight(2), isFalse);
    expect(a.isLineFailed(3), isTrue);
    expect(a.isLineFailed(1), isFalse);

    const b = AutoTranslateUiState(
      status: AutoTranslateStatus.active,
      inFlightIndexes: {1},
      failedLineIndexes: {3},
    );
    expect(a, b);
  });

  test('concurrency and attempt constants stay small', () {
    expect(kAutoTranslateMaxConcurrency, 2);
    expect(kAutoTranslateMaxLineAttempts, 2);
  });

  test('orderPendingLineIndexes prefers lines near anchor', () {
    final ordered = orderPendingLineIndexes(
      anchorIndex: 100,
      pending: [0, 5, 98, 101, 200],
    );
    expect(ordered.first, 101);
    expect(ordered[1], 98);
    expect(ordered.last, 200);
  });
}
