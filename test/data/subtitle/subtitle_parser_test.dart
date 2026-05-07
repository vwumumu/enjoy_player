import 'package:enjoy_player/data/subtitle/subtitle_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SrtParser', () {
    test('parses simple cue', () {
      const srt = '''
1
00:00:01,000 --> 00:00:03,500
Hello world

''';
      final lines = const SrtParser().parse(srt);
      expect(lines, hasLength(1));
      expect(lines.first.text, 'Hello world');
      expect(lines.first.startMs, 1000);
      expect(lines.first.durationMs, 2500);
    });
  });

  group('VttParser', () {
    test('parses WEBVTT with cue', () {
      const vtt = '''
WEBVTT

00:00:01.000 --> 00:00:02.000
Hello

''';
      final lines = const VttParser().parse(vtt);
      expect(lines, hasLength(1));
      expect(lines.first.text, 'Hello');
      expect(lines.first.startMs, 1000);
      expect(lines.first.durationMs, 1000);
    });
  });

  test('BOM and CRLF in SRT', () {
    const srt = '\uFEFF1\r\n00:00:00,000 --> 00:00:01,000\r\nA\r\n\r\n';
    final lines = const SrtParser().parse(srt);
    expect(lines.single.text, 'A');
  });
}
