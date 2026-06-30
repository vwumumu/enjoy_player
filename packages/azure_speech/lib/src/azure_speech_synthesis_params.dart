import 'package:meta/meta.dart';

/// Parameters for Azure Speech text-to-speech (subscription key auth).
@immutable
final class AzureSpeechSynthesisParams {
  const AzureSpeechSynthesisParams({
    required this.text,
    required this.language,
    required this.subscriptionKey,
    required this.region,
    this.voice,
  });

  final String text;
  final String language;
  final String subscriptionKey;
  final String region;
  final String? voice;

  Map<String, Object?> toMap() {
    if (subscriptionKey.trim().isEmpty) {
      throw ArgumentError('subscriptionKey is required');
    }
    if (region.trim().isEmpty) {
      throw ArgumentError('region is required');
    }

    return <String, Object?>{
      'text': text,
      'language': language,
      'subscriptionKey': subscriptionKey,
      'region': region,
      if (voice != null && voice!.trim().isNotEmpty) 'voice': voice,
    };
  }
}
