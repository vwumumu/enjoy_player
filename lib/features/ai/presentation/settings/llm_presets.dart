import 'package:enjoy_player/features/ai/domain/llm_api_spec.dart';

final class LlmPreset {
  const LlmPreset({
    required this.id,
    required this.label,
    required this.apiSpec,
    required this.baseUrl,
    required this.model,
  });

  final String id;
  final String label;
  final LlmApiSpec apiSpec;
  final String baseUrl;
  final String model;
}

const llmPresets = <LlmPreset>[
  LlmPreset(
    id: 'openai',
    label: 'OpenAI',
    apiSpec: LlmApiSpec.openAiCompatible,
    baseUrl: 'https://api.openai.com/v1',
    model: 'gpt-4o-mini',
  ),
  LlmPreset(
    id: 'deepseek',
    label: 'DeepSeek',
    apiSpec: LlmApiSpec.openAiCompatible,
    baseUrl: 'https://api.deepseek.com/v1',
    model: 'deepseek-chat',
  ),
  LlmPreset(
    id: 'groq',
    label: 'Groq',
    apiSpec: LlmApiSpec.openAiCompatible,
    baseUrl: 'https://api.groq.com/openai/v1',
    model: 'llama-3.3-70b-versatile',
  ),
  LlmPreset(
    id: 'azureOpenAi',
    label: 'Azure OpenAI',
    apiSpec: LlmApiSpec.openAiCompatible,
    baseUrl: 'https://YOUR-RESOURCE.openai.azure.com/openai/deployments/YOUR-DEPLOYMENT',
    model: 'gpt-4o-mini',
  ),
  LlmPreset(
    id: 'anthropic',
    label: 'Anthropic',
    apiSpec: LlmApiSpec.anthropicCompatible,
    baseUrl: 'https://api.anthropic.com/v1',
    model: 'claude-sonnet-4-20250514',
  ),
  LlmPreset(
    id: 'google',
    label: 'Google Gemini',
    apiSpec: LlmApiSpec.googleCompatible,
    baseUrl: 'https://generativelanguage.googleapis.com/v1beta',
    model: 'gemini-2.0-flash',
  ),
];

List<LlmPreset> presetsForSpec(LlmApiSpec spec) =>
    llmPresets.where((p) => p.apiSpec == spec).toList();

LlmPreset? presetById(String? id) {
  if (id == null || id.isEmpty) return null;
  for (final preset in llmPresets) {
    if (preset.id == id) return preset;
  }
  return null;
}
