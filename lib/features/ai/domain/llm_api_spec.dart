/// HTTP protocol shape for LLM BYOK (user-supplied base URL + key + model).
enum LlmApiSpec { openAiCompatible, anthropicCompatible, googleCompatible }

extension LlmApiSpecJson on LlmApiSpec {
  String toJsonKey() => switch (this) {
    LlmApiSpec.openAiCompatible => 'openAiCompatible',
    LlmApiSpec.anthropicCompatible => 'anthropicCompatible',
    LlmApiSpec.googleCompatible => 'googleCompatible',
  };

  static LlmApiSpec? fromJsonKey(String? raw) => switch (raw) {
    'openAiCompatible' => LlmApiSpec.openAiCompatible,
    'anthropicCompatible' => LlmApiSpec.anthropicCompatible,
    'googleCompatible' => LlmApiSpec.googleCompatible,
    _ => null,
  };
}
