/// Discover adjacent `.srt` / `.vtt` sidecar files for local media.
library;

import 'dart:io';

import 'package:path/path.dart' as p;

/// Returns sidecar subtitle files in the same directory as [mediaUri].
///
/// Matches `movie.srt`, `movie.vtt`, `movie.en.srt`, etc. for `movie.mp4`.
List<File> discoverSidecarSubtitleFiles(String mediaUri) {
  Uri uri;
  try {
    uri = Uri.parse(mediaUri);
  } on Object {
    return const [];
  }
  if (uri.scheme != 'file') return const [];

  final mediaFile = File.fromUri(uri);
  if (!mediaFile.existsSync()) return const [];

  final dir = mediaFile.parent;
  if (!dir.existsSync()) return const [];

  final baseName = p.basenameWithoutExtension(mediaFile.path).toLowerCase();
  final results = <File>[];

  for (final entity in dir.listSync(followLinks: false)) {
    if (entity is! File) continue;
    final ext = p.extension(entity.path).toLowerCase();
    if (ext != '.srt' && ext != '.vtt') continue;
    final fileBase = p.basenameWithoutExtension(entity.path).toLowerCase();
    if (fileBase == baseName || fileBase.startsWith('$baseName.')) {
      results.add(entity);
    }
  }

  results.sort((a, b) => a.path.compareTo(b.path));
  return results;
}
