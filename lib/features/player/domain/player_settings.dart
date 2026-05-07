/// Persisted player preferences (maps web `player-settings-store`).
library;

enum RepeatMode { none, single, segment }

class PlayerPreferences {
  const PlayerPreferences({
    required this.volume,
    required this.playbackRate,
    required this.repeatMode,
  });

  final double volume;
  final double playbackRate;
  final RepeatMode repeatMode;

  static const PlayerPreferences defaults = PlayerPreferences(
    volume: 1,
    playbackRate: 1,
    repeatMode: RepeatMode.none,
  );

  PlayerPreferences copyWith({
    double? volume,
    double? playbackRate,
    RepeatMode? repeatMode,
  }) {
    return PlayerPreferences(
      volume: volume ?? this.volume,
      playbackRate: playbackRate ?? this.playbackRate,
      repeatMode: repeatMode ?? this.repeatMode,
    );
  }
}
