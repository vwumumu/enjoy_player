# Contract: Modality Capability Routing

**Feature**: `003-byok-ai` | **Consumer**: `ai_capability_providers.dart` / `*ServiceProvider` | **Version**: 1.0

## Resolution rule

All AI features MUST call `*ServiceProvider` or `*CapabilityProvider` — never vendor HTTP from widgets.

```text
aiModalityConfigsProvider
  → resolve*Capability(ref, config)
    → Enjoy*Capability | Byok*Capability | Unimplemented (local only)
```

## Routing matrix

| Modality | `AIProvider.enjoy` | `AIProvider.byok` |
|----------|-------------------|-------------------|
| LLM | `EnjoyLlmCapability` | `ByokLlmCapability` from `LlmByokConfig` + secret |
| ASR | `EnjoyAsrCapability` | `openAiCompatible` → `ByokAsrOpenAiCapability`; `azureSpeech` → `ByokAsrAzureCapability` |
| TTS | `EnjoyTtsCapability` | OpenAI → `ByokTtsOpenAiCapability`; Azure → `ByokTtsAzureCapability` |
| Assessment | `EnjoyAssessmentCapability` (worker token) | `ByokAssessmentAzureCapability` (subscription key) |

## LLM backend mapping

| `LlmApiSpec` | Client |
|--------------|--------|
| `openAiCompatible` | `ai_sdk_openai` with `baseURL = config.baseUrl` |
| `anthropicCompatible` | `ai_sdk_anthropic` with custom base URL adapter |
| `googleCompatible` | `ai_sdk_google` with custom base URL adapter |

**Network**: Direct HTTPS to user `baseUrl`. Do **not** call Enjoy worker `/byok-proxy`.

## Service inheritance

| Service | Config source |
|---------|---------------|
| `chatServiceProvider` | `llm` |
| `translationServiceProvider` | `llm` (via translation capability → LLM or dedicated — today Enjoy translation API; BYOK uses LLM-backed path per Enjoy web) |
| `dictionaryServiceProvider` | `llm` for BYOK dictionary implementation |
| `contextualTranslationServiceProvider` | `llm` |
| `asrServiceProvider` | `asr` |
| `ttsServiceProvider` | `tts` |
| `assessmentServiceProvider` | `assessment` |

**Note**: For BYOK dictionary/translation, implement capabilities that call `LlmCapability` with Enjoy-equivalent prompts (port from `@enjoy/ai` workers) rather than Enjoy worker HTTP.

## Misconfiguration errors

When `provider == byok` but secret missing or validation fails at runtime:

- Throw typed failure (e.g. `ByokNotConfiguredFailure`) with localized message + action to open AI providers settings.
- Do **not** fall back to Enjoy AI silently.

## Credits

- Enjoy path: existing `CreditsFailure` on 402.
- BYOK path: vendor errors only; no Enjoy credits consumption.

## Caching / invalidation

- `aiModalityConfigsProvider`: `keepAlive: true`; invalidate on settings save.
- In-flight requests: complete with config snapshot at invocation start (spec edge case).

## Playground

`AiPlaygroundScreen` displays active provider label per modality (Enjoy vs BYOK + spec preset) for debugging visibility.
