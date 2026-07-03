import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:enjoy_player/core/application/app_preferences_provider.dart';
import 'package:enjoy_player/core/theme/enjoy_tokens.dart';
import 'package:enjoy_player/data/db/app_database.dart';
import 'package:enjoy_player/data/db/app_database_provider.dart';
import 'package:enjoy_player/features/auth/application/auth_controller.dart';
import 'package:enjoy_player/features/auth/application/profile_practice_stats_provider.dart';
import 'package:enjoy_player/features/auth/domain/auth_state.dart';
import 'package:enjoy_player/features/auth/domain/user_profile.dart';
import 'package:enjoy_player/features/auth/presentation/widgets/profile_content.dart';
import 'package:enjoy_player/features/library/domain/learning_statistics.dart';
import 'package:enjoy_player/features/settings/presentation/settings_screen.dart';
import 'package:enjoy_player/features/settings/presentation/widgets/sections/account_hero_section.dart';
import 'package:enjoy_player/features/settings/presentation/widgets/settings_layout_single_column.dart';
import 'package:enjoy_player/features/settings/presentation/widgets/settings_layout_two_pane.dart';
import 'package:enjoy_player/features/settings/presentation/widgets/settings_section_rail_item.dart';
import 'package:enjoy_player/features/shadow_reading/application/recording_input_device_controller.dart';
import 'package:enjoy_player/features/sync/application/pending_rekey_provider.dart';
import 'package:enjoy_player/features/sync/application/sync_providers.dart';
import 'package:enjoy_player/features/sync/data/sync_queue_repository.dart';
import 'package:enjoy_player/l10n/app_localizations.dart';

const _fakeProfile = UserProfile(
  id: 'user-1',
  email: 'reader@example.com',
  name: 'Reader',
);

class _SignedInAuthCtrl extends AuthCtrl {
  @override
  Future<AuthState> build() async => const AuthSignedIn(profile: _fakeProfile);
}

class _FakePrefsCtrl extends AppPreferencesCtrl {
  @override
  Future<AppPreferencesState> build() async => AppPreferencesState.initial;
}

/// Avoids real hardware/FFI microphone enumeration during widget tests.
class _FakeRecordingInputDeviceCtrl extends RecordingInputDeviceCtrl {
  @override
  Future<RecordingInputDeviceState> build() async =>
      const RecordingInputDeviceState(
        devices: [],
        selectedId: null,
        persistedId: null,
      );
}

// (Untyped: Riverpod 3.x's `Override` type isn't part of its public API.)
// ignore: strict_top_level_inference
Widget _themedApp({required overrides, required Widget home}) {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF7B61FF),
    brightness: Brightness.dark,
  );
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        brightness: Brightness.dark,
        extensions: [EnjoyThemeTokens.build(scheme)],
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );
}

/// Two-pane detail pane only builds the *selected* section's body, so a
/// signed-in auth + prefs + stats override is enough — no DB required.
Widget _twoPaneHarness() {
  return _themedApp(
    overrides: [
      authCtrlProvider.overrideWith(_SignedInAuthCtrl.new),
      appPreferencesCtrlProvider.overrideWith(_FakePrefsCtrl.new),
      profilePracticeStatsProvider.overrideWith(
        (ref) async => LearningStatistics.empty(),
      ),
    ],
    home: const SettingsScreen(),
  );
}

/// Single-column renders every section's body eagerly, so it needs the full
/// override set (DB, sync, recording) that [settings_screen_test.dart] uses.
Widget _singleColumnHarness(AppDatabase db) {
  return _themedApp(
    overrides: [
      guestAppDatabaseProvider.overrideWithValue(db),
      appDatabaseProvider.overrideWithValue(db),
      authCtrlProvider.overrideWith(_SignedInAuthCtrl.new),
      appPreferencesCtrlProvider.overrideWith(_FakePrefsCtrl.new),
      profilePracticeStatsProvider.overrideWith(
        (ref) async => LearningStatistics.empty(),
      ),
      recordingInputDeviceCtrlProvider.overrideWith(
        _FakeRecordingInputDeviceCtrl.new,
      ),
      syncQueueSnapshotProvider.overrideWith(
        (ref) => Stream.value(
          const SyncQueueSnapshot(
            retryablePending: 0,
            permanentlyFailed: 0,
            detailRows: [],
          ),
        ),
      ),
      syncLastFullSyncAtProvider.overrideWith((ref) async => null),
      pendingRekeyRowCountProvider.overrideWith((ref) => Stream.value(0)),
    ],
    home: const SettingsScreen(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'Enjoy Player',
      packageName: 'com.enjoy.player.test',
      version: '0.3.1',
      buildNumber: '2',
      buildSignature: 'test',
    );
  });

  testWidgets(
    'the two-pane Account tab renders the profile inline (no navigation, '
    'no AccountHeroSection push-button)',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_twoPaneHarness());
      await tester.pumpAndSettle();

      expect(find.byType(SettingsLayoutTwoPane), findsOneWidget);
      // Account is the default-selected rail item, so its content should
      // already be visible without tapping anything.
      expect(find.byType(ProfileContent), findsOneWidget);
      expect(find.byType(AccountHeroSection), findsNothing);

      // The rest of the hub (rail items) is still on-screen — proof that
      // selecting Account did not navigate away from Settings. The name
      // appears twice (hero card + preferences form pre-fill).
      expect(find.byType(SettingsSectionRailItem), findsWidgets);
      expect(find.text(_fakeProfile.name), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'the single-column (mobile) Account section keeps the hero card, not '
    'the full inline profile',
    (tester) async {
      final db = AppDatabase(executor: NativeDatabase.memory());
      addTearDown(db.close);

      tester.view.physicalSize = const Size(700, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_singleColumnHarness(db));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsLayoutSingleColumn), findsOneWidget);
      expect(find.byType(AccountHeroSection), findsOneWidget);
      expect(find.byType(ProfileContent), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
