/// Injected on each YouTube mobile watch [onLoadStop] to hide chrome and hook events.
library;

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const String kYoutubeMobileWatchInjectScript = r'''
(function(){
  var v=null;       // current hooked <video>
  var player=null;  // .html5-video-player container
  var mids=[];      // elements between player and <video>
  var chain=[];     // ancestors from player up to <html>
  var curVid=(new URL(location.href)).searchParams.get('v')||'';

  // --- Ad tracking ---
  var wasAd=false;        // was ad showing last cycle?
  var savedTime=0;        // last known main-video position
  var reloading=false;    // are we in the middle of a reload?

  // --- Utility ---
  function isAd(){
    return player && player.classList.contains('ad-showing');
  }

  // --- Attach event hooks to a <video> element ---
  function hookVideo(video){
    var events=['play','playing','pause','ended',
                'waiting','canplay','error','loadedmetadata'];
    events.forEach(function(e){
      video.addEventListener(e,function(){
        if(isAd()){
          if(e==='play'||e==='playing'){
            window.flutter_inappwebview.callHandler('onVideoEvent','playing');
          }else if(e==='pause'){
            window.flutter_inappwebview.callHandler('onVideoEvent','pause');
          }
          return;
        }
        if(e==='play'||e==='playing'){video.muted=false;video.volume=1;}
        var args=[e];
        if(e==='loadedmetadata') args.push(video.duration||0);
        window.flutter_inappwebview.callHandler(
          'onVideoEvent',args[0],args.length>1?args[1]:null);
      });
    });
  }

  // --- Sync current video state to Dart ---
  function syncState(video){
    if(!video||isAd()) return;
    if(video.readyState>=1){
      window.flutter_inappwebview.callHandler(
        'onVideoEvent','loadedmetadata',video.duration||0);
    }
    if(!video.paused && !video.ended){
      window.flutter_inappwebview.callHandler('onVideoEvent','playing');
    }else if(video.ended){
      window.flutter_inappwebview.callHandler('onVideoEvent','ended');
    }else{
      window.flutter_inappwebview.callHandler('onVideoEvent','pause');
    }
  }

  // --- Rebuild mids array for current video ---
  function rebuildMids(){
    mids=[];
    if(!v||!player) return;
    var tmp=v.parentElement;
    while(tmp && tmp!==player){mids.push(tmp);tmp=tmp.parentElement;}
  }

  // --- Enforce layout + detect video swap + ad transition ---
  function enforce(){
    if(reloading) return;

    var adNow=isAd();
    if(!adNow && v && isFinite(v.currentTime) && v.currentTime>0){
      savedTime=v.currentTime;
    }

    if(!wasAd && adNow){
      wasAd=true;
    } else if(wasAd && !adNow){
      wasAd=false;
      reloading=true;
      window.flutter_inappwebview.callHandler('onAdReload',savedTime);
      window.flutter_inappwebview.callHandler('onVideoEvent','waiting');
      var url='https://m.youtube.com/watch?v='+curVid+(Math.floor(savedTime)>0?'&t='+Math.floor(savedTime)+'s':'');
      location.href=url;
      return;
    }

    var currentV=document.querySelector('video');
    if(currentV && currentV!==v){
      v=currentV;
      hookVideo(v);
      rebuildMids();
      v.muted=false; v.volume=1;
      v.autoplay=false;
      v.removeAttribute('autoplay');
      v.loop=false;
      setTimeout(function(){syncState(v);},200);
    }
    if(!v) return;

    var de=document.documentElement;
    de.style.setProperty('overflow','hidden','important');
    de.style.setProperty('background','#000','important');
    var b=document.body;
    b.style.setProperty('margin','0','important');
    b.style.setProperty('padding','0','important');
    b.style.setProperty('overflow','hidden','important');
    b.style.setProperty('background','#000','important');

    if(player){
      player.style.setProperty('position','fixed','important');
      player.style.setProperty('top','0','important');
      player.style.setProperty('left','0','important');
      player.style.setProperty('width','100vw','important');
      player.style.setProperty('height','100vh','important');
      player.style.setProperty('z-index','999999','important');
      player.style.setProperty('overflow','hidden','important');
      player.style.setProperty('background','#000','important');
      player.style.setProperty('margin','0','important');
      player.style.setProperty('padding','0','important');
      player.style.setProperty('transform','none','important');
      player.style.setProperty('display','block','important');
      player.style.setProperty('visibility','visible','important');
      player.style.setProperty('opacity','1','important');
    }

    mids.forEach(function(el){
      el.style.setProperty('width','100%','important');
      el.style.setProperty('height','100%','important');
      el.style.setProperty('display','block','important');
      el.style.setProperty('visibility','visible','important');
      el.style.setProperty('opacity','1','important');
      el.style.setProperty('position','absolute','important');
      el.style.setProperty('top','0','important');
      el.style.setProperty('left','0','important');
      el.style.setProperty('overflow','hidden','important');
      el.style.setProperty('max-height','none','important');
      el.style.setProperty('max-width','none','important');
      el.style.setProperty('min-height','0','important');
      el.style.setProperty('margin','0','important');
      el.style.setProperty('padding','0','important');
      el.style.setProperty('transform','none','important');
      el.style.setProperty('background','#000','important');
    });

    v.style.setProperty('width','100%','important');
    v.style.setProperty('height','100%','important');
    v.style.setProperty('position','absolute','important');
    v.style.setProperty('top','0','important');
    v.style.setProperty('left','0','important');
    v.style.setProperty('display','block','important');
    v.style.setProperty('visibility','visible','important');
    v.style.setProperty('object-fit','contain','important');
    v.style.setProperty('margin','0','important');
    v.style.setProperty('padding','0','important');
    v.style.setProperty('transform','none','important');
    v.style.setProperty('background','#000','important');

    for(var i=0;i<chain.length;i++){
      var parent=chain[i].parentElement;
      if(!parent) continue;
      Array.from(parent.children).forEach(function(sib){
        if(sib===chain[i]) return;
        var tag=sib.tagName;
        if(tag==='STYLE'||tag==='SCRIPT'||tag==='LINK'
           ||tag==='META'||tag==='HEAD') return;
        sib.style.setProperty('display','none','important');
      });
    }
  }

  function setup(){
    v=document.querySelector('video');
    if(!v){setTimeout(setup,300);return;}

    player=v.closest('.html5-video-player')||v.parentElement;
    rebuildMids();

    chain=[];
    var tmp=player;
    while(tmp){chain.push(tmp);tmp=tmp.parentElement;}

    enforce();
    setInterval(enforce,300);

    v.muted=false; v.volume=1;
    v.autoplay=false;
    v.removeAttribute('autoplay');
    v.loop=false;

    hookVideo(v);

    var origPush=history.pushState.bind(history);
    var origReplace=history.replaceState.bind(history);
    history.pushState=function(s,t,u){
      if(u && typeof u==='string' && u.indexOf('/watch')>=0){
        try{
          var nv=(new URL(u,location.href)).searchParams.get('v');
          if(nv && nv!==curVid) return;
        }catch(e){}
      }
      origPush(s,t,u);
    };
    history.replaceState=function(s,t,u){
      if(u && typeof u==='string' && u.indexOf('/watch')>=0){
        try{
          var nv=(new URL(u,location.href)).searchParams.get('v');
          if(nv && nv!==curVid) return;
        }catch(e){}
      }
      origReplace(s,t,u);
    };

    syncState(v);
  }
  setup();
})();
''';

Future<void> injectYoutubeMobileWatchPage(InAppWebViewController controller) {
  return controller.evaluateJavascript(source: kYoutubeMobileWatchInjectScript);
}
