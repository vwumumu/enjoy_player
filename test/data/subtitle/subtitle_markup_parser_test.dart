import 'package:enjoy_player/data/subtitle/subtitle_markup_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parseSubtitleMarkup strips font tags and preserves hex colors', () {
    final input =
        '<font color="#ffffff">Hello </font><font color="#00ffff">world</font>';
    final segs = parseSubtitleMarkup(input);
    expect(segs.length, 2);
    expect(segs[0].text, 'Hello ');
    expect(segs[0].colorArgb, 0xFFFFFFFF);
    expect(segs[1].text, 'world');
    expect(segs[1].colorArgb, 0xFF00FFFF);
  });

  test('parseSubtitleMarkup handles nested bold inside font', () {
    final input = '<font color="#ffff00"><b>Bold</b></font>';
    final segs = parseSubtitleMarkup(input);
    expect(segs.single.text, 'Bold');
    expect(segs.single.colorArgb, 0xFFFFFF00);
    expect(segs.single.bold, isTrue);
  });
}
