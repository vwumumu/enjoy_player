/// Root Drift database for Enjoy Player (native SQLite via drift_flutter).
library;

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/medias.dart';
import 'tables/playback_sessions.dart';
import 'tables/settings.dart';
import 'tables/transcripts.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Medias, Transcripts, PlaybackSessions, SettingsKv],
  daos: [MediaDao, TranscriptDao, SessionDao, SettingsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'enjoy_player'));

  @override
  int get schemaVersion => 1;
}

@DriftAccessor(tables: [Medias])
class MediaDao extends DatabaseAccessor<AppDatabase> with _$MediaDaoMixin {
  MediaDao(super.db);

  Future<List<MediaRow>> get all => select(medias).get();

  Stream<List<MediaRow>> watchAll() =>
      (select(medias)..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Future<MediaRow?> getById(String id) =>
      (select(medias)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> insertRow(MediaRow row) => into(medias).insert(
        row,
        mode: InsertMode.insertOrReplace,
      );

  Future<void> deleteId(String id) =>
      (delete(medias)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [Transcripts])
class TranscriptDao extends DatabaseAccessor<AppDatabase>
    with _$TranscriptDaoMixin {
  TranscriptDao(super.db);

  Stream<List<TranscriptRow>> watchForMedia(String mediaId) =>
      (select(transcripts)
            ..where((t) => t.mediaId.equals(mediaId))
            ..orderBy([(t) => OrderingTerm.asc(t.language)]))
          .watch();

  Future<List<TranscriptRow>> listForMedia(String mediaId) =>
      (select(transcripts)..where((t) => t.mediaId.equals(mediaId))).get();

  Future<void> upsert(TranscriptRow row) => into(transcripts).insert(
        row,
        mode: InsertMode.insertOrReplace,
      );

  Future<void> deleteId(String id) =>
      (delete(transcripts)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [PlaybackSessions])
class SessionDao extends DatabaseAccessor<AppDatabase> with _$SessionDaoMixin {
  SessionDao(super.db);

  Future<PlaybackSessionRow?> getForMedia(String mediaId) =>
      (select(playbackSessions)..where((t) => t.mediaId.equals(mediaId)))
          .getSingleOrNull();

  Future<void> upsert(PlaybackSessionRow row) =>
      into(playbackSessions).insert(
        row,
        mode: InsertMode.insertOrReplace,
      );
}

@DriftAccessor(tables: [SettingsKv])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<String?> getValue(String key) async {
    final row =
        await (select(settingsKv)..where((t) => t.key.equals(key)))
            .getSingleOrNull();
    return row?.value;
  }

  Future<void> setValue(String key, String value) => into(settingsKv).insert(
        SettingRow(key: key, value: value),
        mode: InsertMode.insertOrReplace,
      );
}
