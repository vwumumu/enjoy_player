/// Drift table: key/value settings (JSON-encoded values).
library;

import 'package:drift/drift.dart';

@DataClassName('SettingRow')
class SettingsKv extends Table {
  @override
  String get tableName => 'settings';

  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
