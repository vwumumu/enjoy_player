/// Throttled is optional; exposes player position for transcript highlight + slider.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'player_controller.dart';

part 'display_position_provider.g.dart';

@riverpod
Stream<Duration> displayPosition(Ref ref) {
  final ctrl = ref.watch(playerControllerProvider.notifier);
  return ctrl.player.stream.position;
}
