/// Resolves BCP-47 tags for worker AI calls from playback + learner prefs.
library;

String lookupSourceLanguage(String? playbackLanguage) {
  final t = playbackLanguage?.trim();
  if (t == null || t.isEmpty) return 'en';
  return t;
}

String lookupTargetLanguage(String? nativeLanguage) {
  final t = nativeLanguage?.trim();
  if (t == null || t.isEmpty) return 'en';
  return t;
}
