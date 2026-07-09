import 'package:enjoy_player/features/player/application/engines/youtube/youtube_page_inject.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('kYoutubeMobileWatchInjectScript captions', () {
    test('force-hides YouTube native caption/subtitle DOM via CSS', () {
      expect(
        kYoutubeMobileWatchInjectScript,
        contains('.ytp-caption-window-container'),
      );
      expect(
        kYoutubeMobileWatchInjectScript,
        contains('display:none!important;visibility:hidden!important;'),
      );
    });

    test('disables native <track>-based textTracks on hook and enforce', () {
      expect(
        kYoutubeMobileWatchInjectScript,
        contains('function disableTextTracks(video)'),
      );
      expect(
        kYoutubeMobileWatchInjectScript,
        contains("video.textTracks[i].mode='disabled';"),
      );

      final hookVideoBody = kYoutubeMobileWatchInjectScript.substring(
        kYoutubeMobileWatchInjectScript.indexOf('function hookVideo(video){'),
        kYoutubeMobileWatchInjectScript.indexOf('function syncState(video){'),
      );
      expect(hookVideoBody, contains('disableTextTracks(video);'));

      final enforceBody = kYoutubeMobileWatchInjectScript.substring(
        kYoutubeMobileWatchInjectScript.indexOf('function enforce(){'),
        kYoutubeMobileWatchInjectScript.indexOf('function setup(){'),
      );
      expect(enforceBody, contains('disableTextTracks(v);'));
    });

    test('unloads YouTube captions/cc modules via player API', () {
      expect(
        kYoutubeMobileWatchInjectScript,
        contains('function disableYoutubeCaptions()'),
      );
      expect(
        kYoutubeMobileWatchInjectScript,
        contains("p.unloadModule('captions')"),
      );
      expect(
        kYoutubeMobileWatchInjectScript,
        contains("p.setOption('captions','track',{})"),
      );

      final enforceBody = kYoutubeMobileWatchInjectScript.substring(
        kYoutubeMobileWatchInjectScript.indexOf('function enforce(){'),
        kYoutubeMobileWatchInjectScript.indexOf('function setup(){'),
      );
      expect(enforceBody, contains('hideCaptionDom();'));
      expect(enforceBody, contains('disableYoutubeCaptions();'));
    });
  });
}
