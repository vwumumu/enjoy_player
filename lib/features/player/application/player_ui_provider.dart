/// Player chrome: mini vs expanded; playing/buffering flags updated by UI sync widgets.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_ui_provider.g.dart';

enum PlayerChromeMode { mini, expanded }

class PlayerUiState {
  const PlayerUiState({
    required this.mode,
    required this.isPlaying,
    required this.isBuffering,
  });

  final PlayerChromeMode mode;
  final bool isPlaying;
  final bool isBuffering;

  static const initial = PlayerUiState(
    mode: PlayerChromeMode.mini,
    isPlaying: false,
    isBuffering: false,
  );

  PlayerUiState copyWith({
    PlayerChromeMode? mode,
    bool? isPlaying,
    bool? isBuffering,
  }) {
    return PlayerUiState(
      mode: mode ?? this.mode,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
    );
  }
}

@Riverpod(keepAlive: true)
class PlayerUi extends _$PlayerUi {
  @override
  PlayerUiState build() => PlayerUiState.initial;

  void expand() {
    state = state.copyWith(mode: PlayerChromeMode.expanded);
  }

  void collapse() {
    state = state.copyWith(mode: PlayerChromeMode.mini);
  }

  void setPlaying(bool v) {
    state = state.copyWith(isPlaying: v);
  }

  void setBuffering(bool v) {
    state = state.copyWith(isBuffering: v);
  }

  void reset() {
    state = PlayerUiState.initial;
  }
}
