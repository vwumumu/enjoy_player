import 'package:meta/meta.dart';

/// Parameters for one-shot speech recognition (subscription key auth).
@immutable
final class AzureSpeechTranscriptionParams {
  const AzureSpeechTranscriptionParams({
    required this.audioPath,
    required this.language,
    required this.subscriptionKey,
    required this.region,
  });

  final String audioPath;
  final String language;
  final String subscriptionKey;
  final String region;

  Map<String, Object?> toMap() {
    if (subscriptionKey.trim().isEmpty) {
      throw ArgumentError('subscriptionKey is required');
    }
    if (region.trim().isEmpty) {
      throw ArgumentError('region is required');
    }

    return <String, Object?>{
      'audioPath': audioPath,
      'language': language,
      'subscriptionKey': subscriptionKey,
      'region': region,
    };
  }
}
