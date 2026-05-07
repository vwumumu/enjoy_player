/// Reactive subtitle lines for a media id (primary transcript = first row).
library;

import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/db/app_database_provider.dart';
import '../../../data/subtitle/transcript_line.dart';

part 'transcript_lines_provider.g.dart';

@riverpod
Stream<List<TranscriptLine>> transcriptLinesForMedia(
  Ref ref,
  String mediaId,
) {
  final db = ref.watch(appDatabaseProvider);
  return db.transcriptDao.watchForMedia(mediaId).map((rows) {
    if (rows.isEmpty) return <TranscriptLine>[];
    final decoded =
        (jsonDecode(rows.first.linesJson) as List).cast<Map<String, dynamic>>();
    return decoded.map(TranscriptLine.fromJson).toList();
  });
}
