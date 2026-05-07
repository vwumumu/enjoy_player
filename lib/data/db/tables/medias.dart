/// Drift table: local audio/video media rows (mirrors web Dexie `videos`/`audios`).
library;

import 'package:drift/drift.dart';

@DataClassName('MediaRow')
class Medias extends Table {
  @override
  String get tableName => 'media';

  TextColumn get id => text()();
  TextColumn get kind => text()();
  TextColumn get title => text()();
  TextColumn get sourceUri => text()();
  TextColumn get thumbnailPath => text().nullable()();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  TextColumn get language => text().withDefault(const Constant('und'))();
  TextColumn get fileHash => text()();
  IntColumn get fileSize => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
