/// AI modality with independent provider configuration.
enum ModalityKind {
  llm,
  asr,
  tts,
  assessment,
}

extension ModalityKindJson on ModalityKind {
  String toJsonKey() => name;

  static ModalityKind? fromJsonKey(String? raw) => switch (raw) {
        'llm' => ModalityKind.llm,
        'asr' => ModalityKind.asr,
        'tts' => ModalityKind.tts,
        'assessment' => ModalityKind.assessment,
        _ => null,
      };
}
