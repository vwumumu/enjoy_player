/// Bumps when [PlayerController] swaps [PlayerEngine] implementation so consumers re-watch streams.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_engine_rev.g.dart';

@Riverpod(keepAlive: true)
class PlayerEngineRev extends _$PlayerEngineRev {
  @override
  int build() => 0;

  void bump() => state++;
}
