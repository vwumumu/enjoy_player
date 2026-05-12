/// Polls the HTML5 `<video>` element for position / duration / play state.
library;

import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class YoutubeStatePoller {
  YoutubeStatePoller._();

  static const String _pollScript = '''
          (function(){
            var p=document.querySelector('.html5-video-player');
            var v=p?p.querySelector('video'):document.querySelector('video');
            if(!v) return null;
            if(p && p.classList.contains('ad-showing')) return null;
            var s=v.paused?0:(v.ended?2:1);
            return JSON.stringify({
              t:v.currentTime||0,
              d:(v.duration && isFinite(v.duration))?v.duration:0,
              s:s
            });
          })();
        ''';

  static Future<void> poll({
    required bool disposed,
    required InAppWebViewController? web,
    required void Function({
      required Duration position,
      Duration? newDuration,
      required bool jsPaused,
      required bool jsEnded,
    })
    onResult,
  }) async {
    if (disposed || web == null) return;
    try {
      final result = await web.evaluateJavascript(source: _pollScript);
      if (result == null) return;
      final Map<String, dynamic> json;
      try {
        json = jsonDecode(result.toString()) as Map<String, dynamic>;
      } on Object {
        return;
      }

      final seconds = (json['t'] as num?)?.toDouble() ?? 0;
      final position = Duration(milliseconds: (seconds * 1000).round());

      final jsState = (json['s'] as num?)?.toInt() ?? 1;
      final jsPaused = jsState == 0;
      final jsEnded = jsState == 2;

      Duration? newDuration;
      final dur = (json['d'] as num?)?.toDouble() ?? 0;
      if (dur > 0 && dur.isFinite) {
        newDuration = Duration(milliseconds: (dur * 1000).round());
      }

      onResult(
        position: position,
        newDuration: newDuration,
        jsPaused: jsPaused,
        jsEnded: jsEnded,
      );
    } on Object {
      // WebView may be disposed — ignore.
    }
  }
}
