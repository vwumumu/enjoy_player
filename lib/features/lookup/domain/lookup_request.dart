/// Request payload for transcript dictionary / translation lookup sheet.
library;

final class LookupRequest {
  const LookupRequest({
    required this.selectedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    this.contextualContext,
  });

  final String selectedText;
  final String sourceLanguage;
  final String targetLanguage;

  /// Surrounding transcript text for contextual translation (LLM).
  final String? contextualContext;
}
