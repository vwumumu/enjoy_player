import 'package:meta/meta.dart';

/// Parameters for a single pronunciation assessment call (token or subscription key).
@immutable
final class AzurePronunciationAssessmentParams {
  const AzurePronunciationAssessmentParams({
    required this.audioPath,
    required this.referenceText,
    required this.language,
    required this.region,
    this.token,
    this.subscriptionKey,
    this.phonemeAlphabet = AzurePhonemeAlphabet.ipa,
    this.granularity = AzurePronunciationGranularity.phoneme,
    this.enableProsody = true,
    this.enableMiscue = true,
    this.nbestPhonemeCount = 1,
  });

  final String audioPath;
  final String referenceText;
  final String language;
  final String region;
  final String? token;
  final String? subscriptionKey;
  final AzurePhonemeAlphabet phonemeAlphabet;
  final AzurePronunciationGranularity granularity;
  final bool enableProsody;
  final bool enableMiscue;
  final int nbestPhonemeCount;

  Map<String, Object?> toMap() {
    final hasToken = token != null && token!.isNotEmpty;
    final hasKey = subscriptionKey != null && subscriptionKey!.isNotEmpty;
    if (hasToken == hasKey) {
      throw ArgumentError(
        'Exactly one of token or subscriptionKey must be provided',
      );
    }

    return <String, Object?>{
      'audioPath': audioPath,
      'referenceText': referenceText,
      'language': language,
      'region': region,
      if (hasKey) 'subscriptionKey': subscriptionKey,
      if (hasToken) 'token': token,
      'phonemeAlphabet': switch (phonemeAlphabet) {
        AzurePhonemeAlphabet.ipa => 'IPA',
        AzurePhonemeAlphabet.sapi => 'SAPI',
      },
      'granularity': switch (granularity) {
        AzurePronunciationGranularity.phoneme => 'Phoneme',
        AzurePronunciationGranularity.word => 'Word',
        AzurePronunciationGranularity.fullText => 'FullText',
      },
      'enableProsody': enableProsody,
      'enableMiscue': enableMiscue,
      'nbestPhonemeCount': nbestPhonemeCount,
    };
  }
}

enum AzurePhonemeAlphabet { ipa, sapi }

enum AzurePronunciationGranularity { phoneme, word, fullText }
