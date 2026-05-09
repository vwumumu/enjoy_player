/// Riverpod wiring for [StatsApi].
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:enjoy_player/data/api/api_client_provider.dart';
import 'package:enjoy_player/data/api/services/stats_api.dart';

part 'stats_api_provider.g.dart';

@Riverpod(keepAlive: true)
StatsApi statsApi(Ref ref) {
  return StatsApi(ref.watch(apiClientProvider));
}
