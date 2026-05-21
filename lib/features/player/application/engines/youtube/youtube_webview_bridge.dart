/// JS snippets and URL helpers for [YouTubePlayerEngine].
library;

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class YoutubeWebViewBridge {
  YoutubeWebViewBridge._();

  static WebUri watchUri(String videoId) =>
      WebUri('https://m.youtube.com/watch?v=$videoId');

  static Future<void> play(InAppWebViewController? web) async {
    await web?.evaluateJavascript(
      source: '''
        (function(){
          var p=document.querySelector('.html5-video-player');
          var v=p?p.querySelector('video'):null;
          if(!v) v=document.querySelector('video');
          if(v) v.play();
        })();
      ''',
    );
  }

  static Future<void> pause(InAppWebViewController? web) async {
    await web?.evaluateJavascript(
      source: '''
        (function(){
          var p=document.querySelector('.html5-video-player');
          var v=p?p.querySelector('video'):null;
          if(!v) v=document.querySelector('video');
          if(v) v.pause();
        })();
      ''',
    );
  }

  static Future<void> pauseVideoElement(InAppWebViewController? web) async {
    await web?.evaluateJavascript(
      source: '''
        (function(){
          var p=document.querySelector('.html5-video-player');
          var v=p?p.querySelector('video'):null;
          if(!v) v=document.querySelector('video');
          if(v) v.pause();
        })();
      ''',
    );
  }

  static Future<void> seekToSeconds(
    InAppWebViewController? web,
    double seconds,
  ) async {
    await web?.evaluateJavascript(
      source:
          '''
        (function(){
          var p=document.querySelector('.html5-video-player');
          var v=p?p.querySelector('video'):null;
          if(!v) v=document.querySelector('video');
          if(v) v.currentTime=$seconds;
        })();
      ''',
    );
  }

  static Future<void> stop(InAppWebViewController? web) async {
    await web?.evaluateJavascript(
      source: '''
        (function(){
          var p=document.querySelector('.html5-video-player');
          var v=p?p.querySelector('video'):null;
          if(!v) v=document.querySelector('video');
          if(v){v.pause();v.currentTime=0;}
        })();
      ''',
    );
  }

  static Future<void> setPlaybackRate(
    InAppWebViewController? web,
    double speed,
  ) async {
    await web?.evaluateJavascript(
      source:
          '''
        (function(){
          var p=document.querySelector('.html5-video-player');
          var v=p?p.querySelector('video'):null;
          if(!v) v=document.querySelector('video');
          if(v) v.playbackRate=$speed;
        })();
      ''',
    );
  }

  static Future<void> setVolume(
    InAppWebViewController? web,
    double volume,
  ) async {
    await web?.evaluateJavascript(
      source:
          '''
        (function(){
          var p=document.querySelector('.html5-video-player');
          var v=p?p.querySelector('video'):null;
          if(!v) v=document.querySelector('video');
          if(v) v.volume=$volume;
        })();
      ''',
    );
  }

  static Future<void> loadWatchPage(
    InAppWebViewController? web,
    String videoId,
  ) async {
    await web?.loadUrl(urlRequest: URLRequest(url: watchUri(videoId)));
  }

  /// Re-applies `playsinline` on the active `<video>` (iOS WKWebView safety net).
  static Future<void> forceInlinePlayback(InAppWebViewController? web) async {
    await web?.evaluateJavascript(
      source: '''
        (function(){
          var p=document.querySelector('.html5-video-player');
          var v=p?p.querySelector('video'):null;
          if(!v) v=document.querySelector('video');
          if(!v) return;
          v.setAttribute('playsinline','');
          v.setAttribute('webkit-playsinline','');
          v.playsInline=true;
          if(typeof v.webkitSetPresentationMode==='function'){
            try{v.webkitSetPresentationMode('inline');}catch(e){}
          }
        })();
      ''',
    );
  }
}
