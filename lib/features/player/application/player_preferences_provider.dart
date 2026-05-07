/// Persisted volume / speed / repeat (maps web persisted settings).
library;

import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/db/app_database_provider.dart';
import '../domain/player_settings.dart';
import 'player_controller.dart';

part 'player_preferences_provider.g.dart';

const _prefsKey = 'player_preferences_v1';

@Riverpod(keepAlive: true)
class PlayerPreferencesCtrl extends _$PlayerPreferencesCtrl {
  @override
  PlayerPreferences build() {
    Future<void>.microtask(_hydrate);
    return PlayerPreferences.defaults;
  }

  Future<void> _hydrate() async {
    final db = ref.read(appDatabaseProvider);
    final raw = await db.settingsDao.getValue(_prefsKey);
    if (raw == null) return;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final repeatIdx = (map['repeat'] as int?) ?? 0;
      state = PlayerPreferences(
        volume: ((map['volume'] as num?)?.toDouble() ?? 1).clamp(0, 1),
        playbackRate: ((map['rate'] as num?)?.toDouble() ?? 1).clamp(0.25, 2),
        repeatMode: RepeatMode
            .values[repeatIdx.clamp(0, RepeatMode.values.length - 1)],
      );
      await ref.read(playerControllerProvider.notifier).applyPreferences(state);
    } catch (_) {
      /* ignore corrupt prefs */
    }
  }

  Future<void> _persist() async {
    final db = ref.read(appDatabaseProvider);
    await db.settingsDao.setValue(
      _prefsKey,
      jsonEncode({
        'volume': state.volume,
        'rate': state.playbackRate,
        'repeat': state.repeatMode.index,
      }),
    );
  }

  Future<void> setVolume(double v) async {
    state = state.copyWith(volume: v.clamp(0, 1));
    await _persist();
    await ref.read(playerControllerProvider.notifier).applyPreferences(state);
  }

  Future<void> setPlaybackRate(double r) async {
    state = state.copyWith(playbackRate: r.clamp(0.25, 2));
    await _persist();
    await ref.read(playerControllerProvider.notifier).applyPreferences(state);
  }

  Future<void> setRepeatMode(RepeatMode m) async {
    state = state.copyWith(repeatMode: m);
    await _persist();
  }
}
