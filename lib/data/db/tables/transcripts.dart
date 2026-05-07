/// Drift table: transcript payloads linked to media (JSON lines).
library;

import 'package:drift/drift.dart';

import 'medias.dart';

@DataClassName('TranscriptRow')
class Transcripts extends Table {
  @override
  String get tableName => 'transcripts';

  TextColumn get id => text()();
  TextColumn get mediaId =>
      text().references(Medias, #id, onDelete: KeyAction.cascade)();
  TextColumn get language => text()();
  TextColumn get source => text()();
  TextColumn get linesJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
