/// Flutter plugin: Microsoft Azure Cognitive Services Speech SDK (native).
///
/// Currently exposes pronunciation assessment; the surface may grow with
/// additional Speech SDK scenarios.
library;

export 'src/azure_speech_assessment_outcome.dart';
export 'src/azure_speech_exception.dart';
export 'src/azure_speech_params.dart';
export 'src/azure_speech_platform.dart';
export 'src/azure_speech_synthesis_outcome.dart';
export 'src/azure_speech_synthesis_params.dart';
export 'src/azure_speech_transcription_outcome.dart';
export 'src/azure_speech_transcription_params.dart';
export 'src/models.dart';

import 'src/azure_speech_assessment_outcome.dart';
import 'src/azure_speech_params.dart';
import 'src/azure_speech_platform.dart';
import 'src/azure_speech_synthesis_outcome.dart';
import 'src/azure_speech_synthesis_params.dart';
import 'src/azure_speech_transcription_outcome.dart';
import 'src/azure_speech_transcription_params.dart';

/// Entry point for Azure Speech operations from Dart.
final class AzureSpeech {
  AzureSpeech._();

  static final AzureSpeech instance = AzureSpeech._();

  /// One-shot pronunciation assessment from a WAV file (token or subscription key).
  Future<AzureSpeechAssessmentOutcome> assess(
    AzurePronunciationAssessmentParams params,
  ) => AzureSpeechPlatform.instance.assess(params);

  /// One-shot speech recognition from a WAV file (subscription key).
  Future<AzureSpeechTranscriptionOutcome> transcribe(
    AzureSpeechTranscriptionParams params,
  ) => AzureSpeechPlatform.instance.transcribe(params);

  /// Text-to-speech synthesis (subscription key); returns WAV bytes.
  Future<AzureSpeechSynthesisOutcome> synthesize(
    AzureSpeechSynthesisParams params,
  ) => AzureSpeechPlatform.instance.synthesize(params);
}
