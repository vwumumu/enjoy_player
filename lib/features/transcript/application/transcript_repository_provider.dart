library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/db/app_database_provider.dart';
import '../data/transcript_repository.dart';

part 'transcript_repository_provider.g.dart';

@Riverpod(keepAlive: true)
TranscriptRepository transcriptRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return TranscriptRepository(db);
}
