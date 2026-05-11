/// Active [PlayerEngine] — swapped when opening YouTube vs local/URL media (ADR-0015).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'player_controller.dart';
import 'player_engine.dart';
import 'player_engine_rev.dart';
import 'player_engine_test_double_provider.dart';

final playerEngineProvider = Provider<PlayerEngine>((ref) {
  ref.watch(playerControllerProvider);
  ref.watch(playerEngineRevProvider);
  final testDouble = ref.watch(playerEngineTestDoubleProvider);
  if (testDouble != null) return testDouble;
  return ref.read(playerControllerProvider.notifier).engine;
});
