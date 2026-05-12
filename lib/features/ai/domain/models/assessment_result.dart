import 'package:azure_pronunciation_assessment/azure_pronunciation_assessment.dart';

/// Parsed Azure pronunciation assessment (JSON from Speech SDK).
final class AssessmentResult {
  const AssessmentResult({
    required this.detail,
    required this.rawJson,
  });

  final AzurePronunciationAssessmentResult detail;

  /// Full parsed JSON object (camelCase keys as returned by Dart's [jsonDecode]).
  final Map<String, dynamic> rawJson;
}
