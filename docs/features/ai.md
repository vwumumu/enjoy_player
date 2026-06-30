# AI capabilities (Enjoy worker + BYOK)

Enjoy Player calls the Enjoy / worker HTTP surface for cloud-backed AI, and supports **Bring Your Own Key (BYOK)** per modality so learners can use their own LLM and speech credentials. See [ADR-0033](../decisions/0033-byok-ai-provider-settings.md).

## Implemented (Enjoy provider)

| Modality | Worker route | Flutter entry |
|----------|----------------|---------------|
| ASR | `POST /audio/transcriptions` | `asrServiceProvider` → `AsrCapability` |
| LLM / chat | `POST /chat/completions` | `chatServiceProvider` → `LlmCapability` |
| Translation | `POST /translations` | `translationServiceProvider` → `TranslationCapability` |
| Contextual translation | `POST /chat/completions` (learner markdown) | `contextualTranslationServiceProvider` → `ContextualTranslationCapability` → `LlmCapability` |
| Dictionary | `POST /dictionary/query` | `dictionaryServiceProvider` → `DictionaryCapability` |
| Azure token | `POST /azure/tokens` | `azureTokenApiProvider` + `azureTokenCacheProvider` (9 min TTL) |
| Pronunciation assessment | `POST /azure/tokens` + **native Azure Speech SDK** | `assessmentServiceProvider` → `EnjoyAssessmentCapability` → [`packages/azure_speech`](../../packages/azure_speech/) |

### Native pronunciation plugin

- **Package**: [`packages/azure_speech/README.md`](../../packages/azure_speech/README.md) (Speech SDK wrapper; assessment, transcribe, synthesize)
- **Capability**: [`lib/features/ai/data/enjoy/enjoy_assessment_capability.dart`](../../lib/features/ai/data/enjoy/enjoy_assessment_capability.dart) (token cache + WAV path or temp file from bytes). Before calling the SDK, recordings are re-encoded via **FFmpeg** to **16 kHz mono 16-bit PCM WAV** ([`azure_assessment_wav_normalizer.dart`](../../lib/features/ai/data/azure_assessment_wav_normalizer.dart)) so legacy float / odd-RIFF WAVs do not trigger Azure **SPXERR_UNEXPECTED_EOF**. The normalizer uses an **`aresample` + `aformat` filter graph** for reliable Windows decodes, rejects silent FFmpeg output via a peak/RMS scan ([`wav_signal_peak.dart`](../../lib/core/audio/wav_signal_peak.dart)), and the capability falls back to assessing the original recording if the normalized run comes back blank.
- **Language codes**: [`lib/features/ai/data/azure_language_mapper.dart`](../../lib/features/ai/data/azure_language_mapper.dart) maps short / transcript codes to Azure locales (aligned with the browser extension mapper).
- **Persistence**: `assessment_json` stores the **decoded native SDK JSON** (PascalCase keys from `SpeechServiceResponse_JsonResult`), not `AzurePronunciationAssessmentResult.toJson()`, so `jsonEncode` round-trips correctly when reopening the assessment dialog.
- **Observability**: Logger `ai.enjoy.assessment` logs recognition status, aggregate scores, word/omission counts, and audio metadata (file name, byte size, whether FFmpeg normalization ran). All-zero aggregate scores emit a **warning** (often silent or mismatched audio vs reference, skipped normalization, or locale mismatch).

Assessment requires the native Azure Speech SDK (see [echo-mode](echo-mode.md)). **Shadow reading** exposes per-take assess + result dialog.

## BYOK provider (per-modality settings)

**Settings → AI providers** (`/settings/ai-providers`) configures Enjoy vs BYOK independently for LLM, ASR, TTS, and assessment.

| Modality | BYOK backends | Secret storage |
|----------|---------------|----------------|
| LLM | OpenAI-, Anthropic-, Google-compatible HTTP via `ai_sdk_dart` | `ModalityKind.llm` |
| ASR | OpenAI Whisper-compatible multipart **or** Azure Speech `transcribe` | `ModalityKind.asr` |
| TTS | OpenAI `/audio/speech` **or** Azure Speech `synthesize` | `ModalityKind.tts` |
| Assessment | Azure Speech pronunciation assessment (subscription key) | `ModalityKind.assessment` |

Translation, dictionary, and contextual translation follow the **LLM** provider when BYOK is selected (LLM-backed prompts, not Enjoy worker HTTP).

### Persistence and security

- Non-secret config: Drift settings key `ai.modality_configs_v1` (`AiModalityConfigRepository`).
- Secrets: [`ByokSecretStore`](../../lib/data/api/byok_secret_store.dart) (secure storage per modality).
- Validation: [`ByokConfigValidator`](../../lib/features/ai/domain/byok_config_validator.dart) — HTTPS base URLs only, required fields per vendor.
- Missing secret at runtime: [`ByokNotConfiguredFailure`](../../lib/features/ai/domain/byok_not_configured_failure.dart) with localized message and link to AI providers settings (no silent Enjoy fallback).

### Capability routing

[`ai_capability_providers.dart`](../../lib/features/ai/application/ai_capability_providers.dart) resolves `Enjoy*Capability` vs `Byok*Capability` from `aiModalityConfigsProvider`. Feature code should use `*ServiceProvider`, not vendor HTTP in widgets.

### Debug UI

**Settings → Developer → AI playground** shows the active provider label per modality and exercises ASR, chat, translation, dictionary, and assessment.

## Not wired yet

- **Enjoy TTS** still throws `UnimplementedError` ([`EnjoyTtsCapability`](../../lib/features/ai/data/enjoy/enjoy_tts_capability.dart)).
- **`AIProvider.local`** (on-device models) remains a typed placeholder.

## Code layout

- Domain contracts and DTO-style models: `lib/features/ai/domain/`
- Enjoy implementations: `lib/features/ai/data/enjoy/`
- BYOK implementations: `lib/features/ai/data/byok/`
- Riverpod services and capability wiring: `lib/features/ai/application/`
- Settings UI: `lib/features/ai/presentation/settings/`
- HTTP clients (Enjoy paths only): `lib/data/api/services/ai/`

## Consumers

Feature screens should depend on `*ServiceProvider` types in `application/`, not on `ApiClient` directly, so modality and provider selection stay in one place. Transcript dictionary lookup uses the same services — see [dictionary-lookup](features/dictionary-lookup.md).

## Verification

Automated: `flutter test test/features/ai/` and `packages/azure_speech/test/`. Manual BYOK scenarios: [`specs/003-byok-ai/quickstart.md`](../../specs/003-byok-ai/quickstart.md).
