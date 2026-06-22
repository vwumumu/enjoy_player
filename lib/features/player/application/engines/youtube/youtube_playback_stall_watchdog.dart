/// Detects YouTube playback that never reaches first frame after page load.
library;

import 'dart:async';

/// Fires [onStall] once if [onLoadStop] is not followed by [onFirstPlaying]
/// within [timeout].
class YoutubePlaybackStallWatchdog {
  YoutubePlaybackStallWatchdog({
    required this.onStall,
    this.timeout = const Duration(seconds: 30),
  });

  final void Function(String videoId) onStall;
  final Duration timeout;

  Timer? _timer;
  String? _pendingVideoId;

  void onLoadStop(String videoId) {
    cancel();
    if (videoId.isEmpty) return;
    _pendingVideoId = videoId;
    _timer = Timer(timeout, () {
      final vid = _pendingVideoId;
      _pendingVideoId = null;
      _timer = null;
      if (vid != null && vid.isNotEmpty) {
        onStall(vid);
      }
    });
  }

  void onFirstPlaying() {
    cancel();
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
    _pendingVideoId = null;
  }
}
