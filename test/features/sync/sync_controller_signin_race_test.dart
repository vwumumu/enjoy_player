import 'package:drift/native.dart';
import 'package:enjoy_player/data/db/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppDatabase.isDeviceGlobalDatabase', () {
    test('default-constructed database is device-global', () {
      final db = AppDatabase(executor: NativeDatabase.memory());
      addTearDown(db.close);
      expect(db.isDeviceGlobalDatabase, isTrue);
    });

    test('database with a per-user name is not device-global', () {
      final db = AppDatabase(
        executor: NativeDatabase.memory(),
        name: 'enjoy_player_user-42',
      );
      addTearDown(db.close);
      expect(db.isDeviceGlobalDatabase, isFalse);
    });

    test('explicit device-global name reports device-global', () {
      final db = AppDatabase(
        executor: NativeDatabase.memory(),
        name: AppDatabase.deviceGlobalDatabaseName,
      );
      addTearDown(db.close);
      expect(db.isDeviceGlobalDatabase, isTrue);
    });
  });
}
