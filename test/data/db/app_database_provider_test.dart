import 'dart:io';

import 'package:drift/native.dart';
import 'package:enjoy_player/data/db/app_database.dart';
import 'package:enjoy_player/data/db/app_database_provider.dart';
import 'package:enjoy_player/features/auth/application/auth_controller.dart';
import 'package:enjoy_player/features/auth/domain/auth_state.dart';
import 'package:enjoy_player/features/auth/domain/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../../support/test_path_provider.dart';

class _SignedInAuthCtrl extends AuthCtrl {
  @override
  Future<AuthState> build() async => const AuthSignedIn(
    profile: UserProfile(id: 'user-42', email: 'u@test.com', name: 'Test'),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory root;

  setUp(() {
    root = Directory.systemTemp.createTempSync('app_database_provider_');
    PathProviderPlatform.instance = TestPathProvider(root.path);
  });

  tearDown(() async {
    await closeAndClearAllAppDatabases();
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  test(
    'deviceGlobalAppDatabaseProvider reuses one AppDatabase per container',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final a = container.read(deviceGlobalAppDatabaseProvider);
      final b = container.read(deviceGlobalAppDatabaseProvider);
      expect(identical(a, b), isTrue);
    },
  );

  test('appDatabaseProvider opens per-user file when signed in', () async {
    final container = ProviderContainer(
      overrides: [authCtrlProvider.overrideWith(_SignedInAuthCtrl.new)],
    );
    addTearDown(container.dispose);
    await container.read(authCtrlProvider.future);

    final global = container.read(deviceGlobalAppDatabaseProvider);
    final app = container.read(appDatabaseProvider);
    expect(identical(app, global), isFalse);
    expect(global.isDeviceGlobalDatabase, isTrue);
    expect(app.isDeviceGlobalDatabase, isFalse);
  });

  test('appDatabaseProvider throws when signed out', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      () => container.read(appDatabaseProvider),
      throwsA(predicate<Object>((e) => e.toString().contains('AuthSignedIn'))),
    );
  });

  test(
    'closeAndClearAllAppDatabases allows a fresh device-global open',
    () async {
      final first = ProviderContainer();
      final old = first.read(deviceGlobalAppDatabaseProvider);
      first.dispose();
      await closeAndClearAllAppDatabases();

      final second = ProviderContainer();
      addTearDown(second.dispose);
      final fresh = second.read(deviceGlobalAppDatabaseProvider);
      expect(identical(fresh, old), isFalse);
    },
  );

  test(
    'device-global singleton survives container dispose without reopening',
    () {
      final first = ProviderContainer();
      final old = first.read(deviceGlobalAppDatabaseProvider);
      first.dispose();

      final second = ProviderContainer();
      addTearDown(second.dispose);
      final reused = second.read(deviceGlobalAppDatabaseProvider);
      expect(identical(reused, old), isTrue);
    },
  );

  test(
    'withDeviceGlobalAppDatabaseForBootstrap does not leak wrappers',
    () async {
      await withDeviceGlobalAppDatabaseForBootstrap((db) async {
        expect(db.isDeviceGlobalDatabase, isTrue);
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(
        container.read(deviceGlobalAppDatabaseProvider),
        isA<AppDatabase>(),
      );
    },
  );

  test('overrideWithValue bypasses singletons', () async {
    await closeAndClearAllAppDatabases();
    final db = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(db.close);

    final container = ProviderContainer(
      overrides: [
        deviceGlobalAppDatabaseProvider.overrideWithValue(db),
        appDatabaseProvider.overrideWithValue(db),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(deviceGlobalAppDatabaseProvider), same(db));
    expect(container.read(appDatabaseProvider), same(db));
  });
}
