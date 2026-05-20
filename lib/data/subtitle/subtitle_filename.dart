/// Filename helpers for subtitle import and sidecar discovery.
library;

import 'package:path/path.dart' as p;

/// Guess BCP-47-ish code from filename (e.g. `movie.en.srt` → `en`).
String languageHintFromSubtitleFileName(String fileName) {
  final base = p.basenameWithoutExtension(fileName).toLowerCase();
  final m = RegExp(
    r'(?:^|[._-])([a-z]{2}(?:-[a-z]{2,4})?)(?:[._-]|$)',
    caseSensitive: false,
  ).firstMatch(base);
  if (m != null) return m.group(1)!;
  return 'und';
}
