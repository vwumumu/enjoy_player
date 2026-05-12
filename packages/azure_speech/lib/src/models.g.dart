// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AzurePronunciationAssessmentResult _$AzurePronunciationAssessmentResultFromJson(
  Map<String, dynamic> json,
) => AzurePronunciationAssessmentResult(
  recognitionStatus: _azureJsonString(json['RecognitionStatus']),
  offset: _azureJsonIntTick(json['Offset']),
  duration: _azureJsonIntTick(json['Duration']),
  displayText: _azureJsonString(json['DisplayText']),
  nBest: _azureJsonNBestList(json['NBest']),
);

Map<String, dynamic> _$AzurePronunciationAssessmentResultToJson(
  AzurePronunciationAssessmentResult instance,
) => <String, dynamic>{
  'RecognitionStatus': instance.recognitionStatus,
  'Offset': instance.offset,
  'Duration': instance.duration,
  'DisplayText': instance.displayText,
  'NBest': instance.nBest,
};

AzureNBestResult _$AzureNBestResultFromJson(Map<String, dynamic> json) =>
    AzureNBestResult(
      confidence: _azureJsonDoubleScore(json['Confidence']),
      lexical: _azureJsonString(json['Lexical']),
      itn: _azureJsonString(json['ITN']),
      maskedItn: _azureJsonString(json['MaskedITN']),
      display: _azureJsonString(json['Display']),
      pronunciationAssessment: _azureJsonPronunciationScores(
        json['PronunciationAssessment'],
      ),
      words: _azureJsonWordsList(json['Words']),
    );

Map<String, dynamic> _$AzureNBestResultToJson(AzureNBestResult instance) =>
    <String, dynamic>{
      'Confidence': instance.confidence,
      'Lexical': instance.lexical,
      'ITN': instance.itn,
      'MaskedITN': instance.maskedItn,
      'Display': instance.display,
      'PronunciationAssessment': instance.pronunciationAssessment,
      'Words': instance.words,
    };

AzurePronunciationAssessmentScores _$AzurePronunciationAssessmentScoresFromJson(
  Map<String, dynamic> json,
) => AzurePronunciationAssessmentScores(
  accuracyScore: _azureJsonDoubleScore(json['AccuracyScore']),
  fluencyScore: _azureJsonDoubleScore(json['FluencyScore']),
  completenessScore: _azureJsonDoubleScore(json['CompletenessScore']),
  pronScore: _azureJsonDoubleScore(json['PronScore']),
  prosodyScore: _azureJsonDoubleScoreOpt(json['ProsodyScore']),
);

Map<String, dynamic> _$AzurePronunciationAssessmentScoresToJson(
  AzurePronunciationAssessmentScores instance,
) => <String, dynamic>{
  'AccuracyScore': instance.accuracyScore,
  'FluencyScore': instance.fluencyScore,
  'CompletenessScore': instance.completenessScore,
  'PronScore': instance.pronScore,
  'ProsodyScore': instance.prosodyScore,
};

AzureWordAssessment _$AzureWordAssessmentFromJson(
  Map<String, dynamic> json,
) => AzureWordAssessment(
  word: _azureJsonString(json['Word']),
  offset: _azureJsonIntTick(json['Offset']),
  duration: _azureJsonIntTick(json['Duration']),
  pronunciationAssessment: _azureJsonWordPronunciation(
    json['PronunciationAssessment'],
  ),
  syllables:
      (json['Syllables'] as List<dynamic>?)
          ?.map(
            (e) => AzureSyllableAssessment.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
  phonemes:
      (json['Phonemes'] as List<dynamic>?)
          ?.map(
            (e) => AzurePhonemeAssessment.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
);

Map<String, dynamic> _$AzureWordAssessmentToJson(
  AzureWordAssessment instance,
) => <String, dynamic>{
  'Word': instance.word,
  'Offset': instance.offset,
  'Duration': instance.duration,
  'PronunciationAssessment': instance.pronunciationAssessment,
  'Syllables': instance.syllables,
  'Phonemes': instance.phonemes,
};

AzureWordPronunciationAssessment _$AzureWordPronunciationAssessmentFromJson(
  Map<String, dynamic> json,
) => AzureWordPronunciationAssessment(
  accuracyScore: _azureJsonDoubleScore(json['AccuracyScore']),
  errorType: _azureJsonErrorType(json['ErrorType']),
);

Map<String, dynamic> _$AzureWordPronunciationAssessmentToJson(
  AzureWordPronunciationAssessment instance,
) => <String, dynamic>{
  'AccuracyScore': instance.accuracyScore,
  'ErrorType': instance.errorType,
};

AzureSyllableAssessment _$AzureSyllableAssessmentFromJson(
  Map<String, dynamic> json,
) => AzureSyllableAssessment(
  syllable: _azureJsonString(json['Syllable']),
  offset: _azureJsonIntTick(json['Offset']),
  duration: _azureJsonIntTick(json['Duration']),
  pronunciationAssessment: _azureJsonSyllablePronunciation(
    json['PronunciationAssessment'],
  ),
  phonemes:
      (json['Phonemes'] as List<dynamic>?)
          ?.map(
            (e) => AzurePhonemeAssessment.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
);

Map<String, dynamic> _$AzureSyllableAssessmentToJson(
  AzureSyllableAssessment instance,
) => <String, dynamic>{
  'Syllable': instance.syllable,
  'Offset': instance.offset,
  'Duration': instance.duration,
  'PronunciationAssessment': instance.pronunciationAssessment,
  'Phonemes': instance.phonemes,
};

AzureSyllablePronunciationAssessment
_$AzureSyllablePronunciationAssessmentFromJson(Map<String, dynamic> json) =>
    AzureSyllablePronunciationAssessment(
      accuracyScore: _azureJsonDoubleScore(json['AccuracyScore']),
    );

Map<String, dynamic> _$AzureSyllablePronunciationAssessmentToJson(
  AzureSyllablePronunciationAssessment instance,
) => <String, dynamic>{'AccuracyScore': instance.accuracyScore};

AzurePhonemeAssessment _$AzurePhonemeAssessmentFromJson(
  Map<String, dynamic> json,
) => AzurePhonemeAssessment(
  phoneme: _azureJsonString(json['Phoneme']),
  offset: _azureJsonIntTick(json['Offset']),
  duration: _azureJsonIntTick(json['Duration']),
  pronunciationAssessment: _azureJsonPhonemePronunciation(
    json['PronunciationAssessment'],
  ),
);

Map<String, dynamic> _$AzurePhonemeAssessmentToJson(
  AzurePhonemeAssessment instance,
) => <String, dynamic>{
  'Phoneme': instance.phoneme,
  'Offset': instance.offset,
  'Duration': instance.duration,
  'PronunciationAssessment': instance.pronunciationAssessment,
};

AzurePhonemePronunciationAssessment
_$AzurePhonemePronunciationAssessmentFromJson(Map<String, dynamic> json) =>
    AzurePhonemePronunciationAssessment(
      accuracyScore: _azureJsonDoubleScore(json['AccuracyScore']),
      nBestPhonemes:
          (json['NBestPhonemes'] as List<dynamic>?)
              ?.map(
                (e) => AzureNBestPhoneme.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
    );

Map<String, dynamic> _$AzurePhonemePronunciationAssessmentToJson(
  AzurePhonemePronunciationAssessment instance,
) => <String, dynamic>{
  'AccuracyScore': instance.accuracyScore,
  'NBestPhonemes': instance.nBestPhonemes,
};

AzureNBestPhoneme _$AzureNBestPhonemeFromJson(Map<String, dynamic> json) =>
    AzureNBestPhoneme(
      phoneme: _azureJsonString(json['Phoneme']),
      score: _azureJsonDoubleScore(json['Score']),
    );

Map<String, dynamic> _$AzureNBestPhonemeToJson(AzureNBestPhoneme instance) =>
    <String, dynamic>{'Phoneme': instance.phoneme, 'Score': instance.score};
