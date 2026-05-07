/// Persist imported subtitles for a media item.
library;

import 'dart:convert';

import 'package:cross_file/cross_file.dart';
import 'package:uuid/uuid.dart';

import '../../../data/db/app_database.dart';
import '../../../data/subtitle/subtitle_parser.dart';

class TranscriptRepository {
  TranscriptRepository(this._db);

  // ignore: prefer_const_constructors
  static final Uuid _uuid = Uuid();

  final AppDatabase _db;

  Future<void> importSubtitle({
    required String mediaId,
    required XFile file,
  }) async {
    final text = await file.readAsString();
    final lines =
        const SubtitleParserFacade().parseWithHint(text, fileName: file.name);
    final json = jsonEncode(lines.map((e) => e.toJson()).toList());
    final id = _uuid.v4();
    final now = DateTime.now();
    await _db.transcriptDao.upsert(
      TranscriptRow(
        id: id,
        mediaId: mediaId,
        language: 'und',
        source: 'import',
        linesJson: json,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }
}
