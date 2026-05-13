/// Resolves BCP-47 tags for transcript lookup + worker AI calls.
library;

import 'package:enjoy_player/core/application/app_language_catalog.dart';

/// Source language from transcript track, or [learningTag] when invalid/unsupported.
String resolveLookupSource(
  String? transcriptLanguage, {
  required String learningTag,
}) {
  return canonicalLookupTag(transcriptLanguage) ??
      normalizeBcp47Tag(learningTag);
}

/// Native / UI target: canonical supported tag, or coerced when equal to learning / invalid.
String resolveLookupTarget(
  String? nativeLanguage, {
  required String learningTag,
}) {
  final c = canonicalLookupTag(nativeLanguage);
  if (c != null && !tagsEqual(c, learningTag)) return c;
  return coerceNativeIfEqualsLearning(nativeLanguage, learningTag);
}
