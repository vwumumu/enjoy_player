/// Per-line shadow-reading recording counts for transcript UI.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:enjoy_player/data/db/app_database_provider.dart';
import 'package:enjoy_player/data/db/media_target_resolver.dart';
import 'package:enjoy_player/features/sync/application/recordings_for_target_provider.dart';
import 'package:enjoy_player/features/transcript/application/transcript_lines_provider.dart';
import 'package:enjoy_player/features/transcript/domain/transcript_recording_counts.dart';

part 'transcript_line_recording_counts_provider.g.dart';

@riverpod
Future<String?> dexieTargetTypeForMedia(Ref ref, String mediaId) {
  final db = ref.watch(appDatabaseProvider);
  return dexieTargetTypeForId(db, mediaId);
}

/// Map of transcript line index → overlapping recording count for [mediaId].
@riverpod
Map<int, int> transcriptLineRecordingCounts(Ref ref, String mediaId) {
  if (mediaId.isEmpty) return const {};

  final lines = ref.watch(transcriptLinesForMediaProvider(mediaId)).value ??
      const [];
  if (lines.isEmpty) return const {};

  final tt = ref.watch(dexieTargetTypeForMediaProvider(mediaId)).value;
  if (tt == null) return const {};

  final recordings =
      ref
          .watch(
            recordingsForTargetProvider((targetType: tt, targetId: mediaId)),
          )
          .value ??
      const [];

  return countRecordingsPerLineIndex(lines, recordings);
}
