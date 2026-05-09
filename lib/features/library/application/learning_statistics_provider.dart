/// Fetches `/api/v1/mine/stats` when the user is signed in.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:enjoy_player/data/api/services/stats_api_provider.dart';
import 'package:enjoy_player/features/auth/application/auth_controller.dart';
import 'package:enjoy_player/features/auth/domain/auth_state.dart';
import 'package:enjoy_player/features/library/domain/learning_statistics.dart';

part 'learning_statistics_provider.g.dart';

@riverpod
Future<LearningStatistics?> learningStatistics(Ref ref) async {
  final auth = await ref.watch(authCtrlProvider.future);
  if (auth is! AuthSignedIn) return null;

  final api = ref.watch(statsApiProvider);
  try {
    final json = await api.learningStatistics(
      timezone: DateTime.now().timeZoneName,
    );
    return LearningStatistics.fromJson(json);
  } catch (_) {
    return LearningStatistics.empty();
  }
}
