import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

const _azureEmptyPronunciationScores = AzurePronunciationAssessmentScores(
  accuracyScore: 0,
  fluencyScore: 0,
  completenessScore: 0,
  pronScore: 0,
  prosodyScore: null,
);

const _azureEmptyWordPronunciation = AzureWordPronunciationAssessment(
  accuracyScore: 0,
  errorType: 'None',
);

const _azureEmptySyllablePronunciation = AzureSyllablePronunciationAssessment(
  accuracyScore: 0,
);

const _azureEmptyPhonemePronunciation = AzurePhonemePronunciationAssessment(
  accuracyScore: 0,
  nBestPhonemes: null,
);

/// Azure may omit tick fields for some word / error types (e.g. omission).
int _azureJsonIntTick(Object? json) {
  if (json == null) return 0;
  if (json is int) return json;
  if (json is num) return json.toInt();
  if (json is String) {
    final i = int.tryParse(json);
    if (i != null) return i;
    final d = double.tryParse(json);
    if (d != null) return d.toInt();
  }
  return 0;
}

double _azureJsonDoubleScore(Object? json) {
  if (json == null) return 0;
  if (json is double) return json;
  if (json is num) return json.toDouble();
  if (json is String) {
    final d = double.tryParse(json);
    if (d != null) return d;
  }
  return 0;
}

double? _azureJsonDoubleScoreOpt(Object? json) {
  if (json == null) return null;
  if (json is double) return json;
  if (json is num) return json.toDouble();
  if (json is String) {
    return double.tryParse(json);
  }
  return null;
}

String _azureJsonString(Object? json) {
  if (json == null) return '';
  if (json is String) return json;
  return json.toString();
}

String _azureJsonErrorType(Object? json) {
  if (json == null) return 'None';
  if (json is! String || json.isEmpty) return 'None';
  return json;
}

List<AzureNBestResult> _azureJsonNBestList(Object? json) {
  if (json is! List<dynamic>) return const [];
  final out = <AzureNBestResult>[];
  for (final e in json) {
    if (e is Map<String, dynamic>) {
      out.add(AzureNBestResult.fromJson(e));
    } else if (e is Map) {
      out.add(AzureNBestResult.fromJson(Map<String, dynamic>.from(e)));
    }
  }
  return out;
}

List<AzureWordAssessment> _azureJsonWordsList(Object? json) {
  if (json is! List<dynamic>) return const [];
  final out = <AzureWordAssessment>[];
  for (final e in json) {
    if (e is Map<String, dynamic>) {
      out.add(AzureWordAssessment.fromJson(e));
    } else if (e is Map) {
      out.add(AzureWordAssessment.fromJson(Map<String, dynamic>.from(e)));
    }
  }
  return out;
}

AzurePronunciationAssessmentScores _azureJsonPronunciationScores(Object? json) {
  if (json is Map<String, dynamic>) {
    return AzurePronunciationAssessmentScores.fromJson(json);
  }
  if (json is Map) {
    return AzurePronunciationAssessmentScores.fromJson(
      Map<String, dynamic>.from(json),
    );
  }
  return _azureEmptyPronunciationScores;
}

AzureWordPronunciationAssessment _azureJsonWordPronunciation(Object? json) {
  if (json is Map<String, dynamic>) {
    return AzureWordPronunciationAssessment.fromJson(json);
  }
  if (json is Map) {
    return AzureWordPronunciationAssessment.fromJson(
      Map<String, dynamic>.from(json),
    );
  }
  return _azureEmptyWordPronunciation;
}

AzureSyllablePronunciationAssessment _azureJsonSyllablePronunciation(
  Object? json,
) {
  if (json is Map<String, dynamic>) {
    return AzureSyllablePronunciationAssessment.fromJson(json);
  }
  if (json is Map) {
    return AzureSyllablePronunciationAssessment.fromJson(
      Map<String, dynamic>.from(json),
    );
  }
  return _azureEmptySyllablePronunciation;
}

AzurePhonemePronunciationAssessment _azureJsonPhonemePronunciation(
  Object? json,
) {
  if (json is Map<String, dynamic>) {
    return AzurePhonemePronunciationAssessment.fromJson(json);
  }
  if (json is Map) {
    return AzurePhonemePronunciationAssessment.fromJson(
      Map<String, dynamic>.from(json),
    );
  }
  return _azureEmptyPhonemePronunciation;
}

/// Root JSON from [SpeechServiceResponse_JsonResult] (Azure Speech SDK).
@JsonSerializable()
final class AzurePronunciationAssessmentResult {
  const AzurePronunciationAssessmentResult({
    required this.recognitionStatus,
    required this.offset,
    required this.duration,
    required this.displayText,
    required this.nBest,
  });

  @JsonKey(name: 'RecognitionStatus', fromJson: _azureJsonString)
  final String recognitionStatus;

  @JsonKey(name: 'Offset', fromJson: _azureJsonIntTick)
  final int offset;

  @JsonKey(name: 'Duration', fromJson: _azureJsonIntTick)
  final int duration;

  @JsonKey(name: 'DisplayText', fromJson: _azureJsonString)
  final String displayText;

  @JsonKey(name: 'NBest', fromJson: _azureJsonNBestList)
  final List<AzureNBestResult> nBest;

  factory AzurePronunciationAssessmentResult.fromJson(
    Map<String, dynamic> json,
  ) => _$AzurePronunciationAssessmentResultFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AzurePronunciationAssessmentResultToJson(this);

  /// Convenience: first hypothesis scores (null if [nBest] empty).
  AzurePronunciationAssessmentScores? get primaryScores =>
      nBest.isEmpty ? null : nBest.first.pronunciationAssessment;
}

@JsonSerializable()
final class AzureNBestResult {
  const AzureNBestResult({
    required this.confidence,
    required this.lexical,
    required this.itn,
    required this.maskedItn,
    required this.display,
    required this.pronunciationAssessment,
    required this.words,
  });

  @JsonKey(name: 'Confidence', fromJson: _azureJsonDoubleScore)
  final double confidence;

  @JsonKey(name: 'Lexical', fromJson: _azureJsonString)
  final String lexical;

  @JsonKey(name: 'ITN', fromJson: _azureJsonString)
  final String itn;

  @JsonKey(name: 'MaskedITN', fromJson: _azureJsonString)
  final String maskedItn;

  @JsonKey(name: 'Display', fromJson: _azureJsonString)
  final String display;

  @JsonKey(
    name: 'PronunciationAssessment',
    fromJson: _azureJsonPronunciationScores,
  )
  final AzurePronunciationAssessmentScores pronunciationAssessment;

  @JsonKey(name: 'Words', fromJson: _azureJsonWordsList)
  final List<AzureWordAssessment> words;

  factory AzureNBestResult.fromJson(Map<String, dynamic> json) =>
      _$AzureNBestResultFromJson(json);

  Map<String, dynamic> toJson() => _$AzureNBestResultToJson(this);
}

@JsonSerializable()
final class AzurePronunciationAssessmentScores {
  const AzurePronunciationAssessmentScores({
    required this.accuracyScore,
    required this.fluencyScore,
    required this.completenessScore,
    required this.pronScore,
    this.prosodyScore,
  });

  @JsonKey(name: 'AccuracyScore', fromJson: _azureJsonDoubleScore)
  final double accuracyScore;

  @JsonKey(name: 'FluencyScore', fromJson: _azureJsonDoubleScore)
  final double fluencyScore;

  @JsonKey(name: 'CompletenessScore', fromJson: _azureJsonDoubleScore)
  final double completenessScore;

  @JsonKey(name: 'PronScore', fromJson: _azureJsonDoubleScore)
  final double pronScore;

  @JsonKey(name: 'ProsodyScore', fromJson: _azureJsonDoubleScoreOpt)
  final double? prosodyScore;

  factory AzurePronunciationAssessmentScores.fromJson(
    Map<String, dynamic> json,
  ) => _$AzurePronunciationAssessmentScoresFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AzurePronunciationAssessmentScoresToJson(this);
}

@JsonSerializable()
final class AzureWordAssessment {
  const AzureWordAssessment({
    required this.word,
    required this.offset,
    required this.duration,
    required this.pronunciationAssessment,
    this.syllables,
    this.phonemes,
  });

  @JsonKey(name: 'Word', fromJson: _azureJsonString)
  final String word;

  @JsonKey(name: 'Offset', fromJson: _azureJsonIntTick)
  final int offset;

  @JsonKey(name: 'Duration', fromJson: _azureJsonIntTick)
  final int duration;

  @JsonKey(
    name: 'PronunciationAssessment',
    fromJson: _azureJsonWordPronunciation,
  )
  final AzureWordPronunciationAssessment pronunciationAssessment;

  @JsonKey(name: 'Syllables')
  final List<AzureSyllableAssessment>? syllables;

  @JsonKey(name: 'Phonemes')
  final List<AzurePhonemeAssessment>? phonemes;

  factory AzureWordAssessment.fromJson(Map<String, dynamic> json) =>
      _$AzureWordAssessmentFromJson(json);

  Map<String, dynamic> toJson() => _$AzureWordAssessmentToJson(this);
}

@JsonSerializable()
final class AzureWordPronunciationAssessment {
  const AzureWordPronunciationAssessment({
    required this.accuracyScore,
    required this.errorType,
  });

  @JsonKey(name: 'AccuracyScore', fromJson: _azureJsonDoubleScore)
  final double accuracyScore;

  @JsonKey(name: 'ErrorType', fromJson: _azureJsonErrorType)
  final String errorType;

  factory AzureWordPronunciationAssessment.fromJson(
    Map<String, dynamic> json,
  ) => _$AzureWordPronunciationAssessmentFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AzureWordPronunciationAssessmentToJson(this);
}

@JsonSerializable()
final class AzureSyllableAssessment {
  const AzureSyllableAssessment({
    required this.syllable,
    required this.offset,
    required this.duration,
    required this.pronunciationAssessment,
    this.phonemes,
  });

  @JsonKey(name: 'Syllable', fromJson: _azureJsonString)
  final String syllable;

  @JsonKey(name: 'Offset', fromJson: _azureJsonIntTick)
  final int offset;

  @JsonKey(name: 'Duration', fromJson: _azureJsonIntTick)
  final int duration;

  @JsonKey(
    name: 'PronunciationAssessment',
    fromJson: _azureJsonSyllablePronunciation,
  )
  final AzureSyllablePronunciationAssessment pronunciationAssessment;

  @JsonKey(name: 'Phonemes')
  final List<AzurePhonemeAssessment>? phonemes;

  factory AzureSyllableAssessment.fromJson(Map<String, dynamic> json) =>
      _$AzureSyllableAssessmentFromJson(json);

  Map<String, dynamic> toJson() => _$AzureSyllableAssessmentToJson(this);
}

@JsonSerializable()
final class AzureSyllablePronunciationAssessment {
  const AzureSyllablePronunciationAssessment({required this.accuracyScore});

  @JsonKey(name: 'AccuracyScore', fromJson: _azureJsonDoubleScore)
  final double accuracyScore;

  factory AzureSyllablePronunciationAssessment.fromJson(
    Map<String, dynamic> json,
  ) => _$AzureSyllablePronunciationAssessmentFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AzureSyllablePronunciationAssessmentToJson(this);
}

@JsonSerializable()
final class AzurePhonemeAssessment {
  const AzurePhonemeAssessment({
    required this.phoneme,
    required this.offset,
    required this.duration,
    required this.pronunciationAssessment,
  });

  @JsonKey(name: 'Phoneme', fromJson: _azureJsonString)
  final String phoneme;

  @JsonKey(name: 'Offset', fromJson: _azureJsonIntTick)
  final int offset;

  @JsonKey(name: 'Duration', fromJson: _azureJsonIntTick)
  final int duration;

  @JsonKey(
    name: 'PronunciationAssessment',
    fromJson: _azureJsonPhonemePronunciation,
  )
  final AzurePhonemePronunciationAssessment pronunciationAssessment;

  factory AzurePhonemeAssessment.fromJson(Map<String, dynamic> json) =>
      _$AzurePhonemeAssessmentFromJson(json);

  Map<String, dynamic> toJson() => _$AzurePhonemeAssessmentToJson(this);
}

@JsonSerializable()
final class AzurePhonemePronunciationAssessment {
  const AzurePhonemePronunciationAssessment({
    required this.accuracyScore,
    this.nBestPhonemes,
  });

  @JsonKey(name: 'AccuracyScore', fromJson: _azureJsonDoubleScore)
  final double accuracyScore;

  @JsonKey(name: 'NBestPhonemes')
  final List<AzureNBestPhoneme>? nBestPhonemes;

  factory AzurePhonemePronunciationAssessment.fromJson(
    Map<String, dynamic> json,
  ) => _$AzurePhonemePronunciationAssessmentFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AzurePhonemePronunciationAssessmentToJson(this);
}

@JsonSerializable()
final class AzureNBestPhoneme {
  const AzureNBestPhoneme({required this.phoneme, required this.score});

  @JsonKey(name: 'Phoneme', fromJson: _azureJsonString)
  final String phoneme;

  @JsonKey(name: 'Score', fromJson: _azureJsonDoubleScore)
  final double score;

  factory AzureNBestPhoneme.fromJson(Map<String, dynamic> json) =>
      _$AzureNBestPhonemeFromJson(json);

  Map<String, dynamic> toJson() => _$AzureNBestPhonemeToJson(this);
}
