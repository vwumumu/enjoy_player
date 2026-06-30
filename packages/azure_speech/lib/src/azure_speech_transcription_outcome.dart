import 'package:meta/meta.dart';

/// Result of a one-shot Azure Speech transcription call.
@immutable
final class AzureSpeechTranscriptionOutcome {
  const AzureSpeechTranscriptionOutcome({required this.text});

  final String text;
}
