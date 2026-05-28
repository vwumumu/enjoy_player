import 'package:enjoy_player/data/subtitle/transcript_line.dart';
import 'package:enjoy_player/features/player/application/echo_mode_provider.dart';
import 'package:enjoy_player/features/player/application/player_interactions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final lines = <TranscriptLine>[
    const TranscriptLine(text: 'line 1', startMs: 0, durationMs: 2000),
    const TranscriptLine(text: 'line 2', startMs: 2000, durationMs: 2000),
    const TranscriptLine(text: 'line 3', startMs: 4000, durationMs: 2000),
    const TranscriptLine(text: 'line 4', startMs: 6000, durationMs: 2000),
  ];

  const echoOnLine2 = EchoState(
    active: true,
    startLineIndex: 1,
    endLineIndex: 1,
    startTimeSeconds: 2,
    endTimeSeconds: 4,
  );

  group('nextLineNavigationIndex', () {
    test('uses playback position when echo is off', () {
      expect(
        nextLineNavigationIndex(
          echo: EchoState.inactive,
          lines: lines,
          currentTimeSeconds: 2.5,
        ),
        2,
      );
    });

    test('follows echo region when playback is on the next cue boundary', () {
      expect(
        nextLineNavigationIndex(
          echo: echoOnLine2,
          lines: lines,
          currentTimeSeconds: 4,
        ),
        2,
      );
    });

    test('follows echo end when playback is still inside the segment', () {
      expect(
        nextLineNavigationIndex(
          echo: echoOnLine2,
          lines: lines,
          currentTimeSeconds: 3,
        ),
        2,
      );
    });

    test('jumps past multi-line echo region', () {
      const multiLineEcho = EchoState(
        active: true,
        startLineIndex: 1,
        endLineIndex: 2,
        startTimeSeconds: 2,
        endTimeSeconds: 6,
      );
      expect(
        nextLineNavigationIndex(
          echo: multiLineEcho,
          lines: lines,
          currentTimeSeconds: 5,
        ),
        3,
      );
    });
  });

  group('prevLineNavigationIndex', () {
    test('uses playback position when echo is off', () {
      expect(
        prevLineNavigationIndex(
          echo: EchoState.inactive,
          lines: lines,
          currentTimeSeconds: 4.5,
        ),
        1,
      );
    });

    test('follows echo region when playback is on the next cue boundary', () {
      expect(
        prevLineNavigationIndex(
          echo: echoOnLine2,
          lines: lines,
          currentTimeSeconds: 4,
        ),
        0,
      );
    });

    test('steps before multi-line echo region', () {
      const multiLineEcho = EchoState(
        active: true,
        startLineIndex: 1,
        endLineIndex: 2,
        startTimeSeconds: 2,
        endTimeSeconds: 6,
      );
      expect(
        prevLineNavigationIndex(
          echo: multiLineEcho,
          lines: lines,
          currentTimeSeconds: 5,
        ),
        0,
      );
    });
  });
}
