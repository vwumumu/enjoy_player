/// Persisted player preferences (maps web `player-settings-store`).
library;

enum RepeatMode { none, single, segment }

class PlayerPreferences {
  const PlayerPreferences({
    required this.volume,
    required this.playbackRate,
    required this.repeatMode,
    this.videoTranscriptSplitWidthPx,
  });

  final double volume;
  final double playbackRate;
  final RepeatMode repeatMode;

  /// Persisted width (px) of the transcript column in side-by-side video layout.
  /// `null` = use default fraction on next open.
  final double? videoTranscriptSplitWidthPx;

  static const PlayerPreferences defaults = PlayerPreferences(
    volume: 1,
    playbackRate: 1,
    repeatMode: RepeatMode.none,
    videoTranscriptSplitWidthPx: null,
  );

  PlayerPreferences copyWith({
    double? volume,
    double? playbackRate,
    RepeatMode? repeatMode,
    double? videoTranscriptSplitWidthPx,
    bool clearVideoTranscriptSplitWidthPx = false,
  }) {
    return PlayerPreferences(
      volume: volume ?? this.volume,
      playbackRate: playbackRate ?? this.playbackRate,
      repeatMode: repeatMode ?? this.repeatMode,
      videoTranscriptSplitWidthPx: clearVideoTranscriptSplitWidthPx
          ? null
          : (videoTranscriptSplitWidthPx ?? this.videoTranscriptSplitWidthPx),
    );
  }
}
