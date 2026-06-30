/// ASR / TTS / assessment BYOK sub-protocol.
enum SpeechByokKind {
  openAiCompatible,
  azureSpeech,
}

extension SpeechByokKindJson on SpeechByokKind {
  String toJsonKey() => switch (this) {
        SpeechByokKind.openAiCompatible => 'openAiCompatible',
        SpeechByokKind.azureSpeech => 'azureSpeech',
      };

  static SpeechByokKind? fromJsonKey(String? raw) => switch (raw) {
        'openAiCompatible' => SpeechByokKind.openAiCompatible,
        'azureSpeech' => SpeechByokKind.azureSpeech,
        _ => null,
      };
}
