/// Drift table: persisted playback + echo state per media item.
library;

import 'package:drift/drift.dart';

import 'medias.dart';

@DataClassName('PlaybackSessionRow')
class PlaybackSessions extends Table {
  @override
  String get tableName => 'playback_sessions';

  TextColumn get mediaId =>
      text().references(Medias, #id, onDelete: KeyAction.cascade)();
  IntColumn get positionMs => integer().withDefault(const Constant(0))();
  IntColumn get currentSegmentIndex =>
      integer().withDefault(const Constant(-1))();
  BoolColumn get echoActive => boolean().withDefault(const Constant(false))();
  IntColumn get echoStartLine =>
      integer().withDefault(const Constant(-1))();
  IntColumn get echoEndLine => integer().withDefault(const Constant(-1))();
  IntColumn get echoStartMs => integer().withDefault(const Constant(-1))();
  IntColumn get echoEndMs => integer().withDefault(const Constant(-1))();
  DateTimeColumn get lastActiveAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {mediaId};
}
