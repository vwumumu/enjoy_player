import 'dart:typed_data';

/// Request for pronunciation assessment.
///
/// Provide either [audioPath] (preferred, avoids copying) or [audioBytes] (WAV bytes).
final class AssessmentRequest {
  AssessmentRequest({
    this.audioBytes,
    this.audioPath,
    required this.referenceText,
    required this.language,
    this.durationMs,
  }) {
    final hasBytes = audioBytes?.isNotEmpty ?? false;
    final hasPath = audioPath?.trim().isNotEmpty ?? false;
    if (!hasBytes && !hasPath) {
      throw ArgumentError(
        'Provide non-empty audioBytes or a non-empty audioPath',
      );
    }
  }

  final Uint8List? audioBytes;
  final String? audioPath;
  final String referenceText;
  final String language;
  final int? durationMs;
}
