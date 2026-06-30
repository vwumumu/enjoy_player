# Data Model: BYOK AI Provider Settings

**Feature**: `003-byok-ai` | **Date**: 2026-06-30

No new Drift tables. Non-secret config in `SettingsDao`; API keys in `flutter_secure_storage`.

## Entities

### LlmApiSpec (enum)

HTTP protocol for LLM BYOK. Drives client request shape.

| Value | Protocol |
|-------|----------|
| `openAiCompatible` | Chat Completions on user `baseUrl` |
| `anthropicCompatible` | Messages API on user `baseUrl` |
| `googleCompatible` | Gemini generateContent on user `baseUrl` |

### SpeechByokKind (enum)

ASR / TTS BYOK sub-protocol (assessment uses Azure only).

| Value | Used for |
|-------|----------|
| `openAiCompatible` | Whisper / OpenAI TTS on user `baseUrl` |
| `azureSpeech` | Azure Speech SDK with subscription key + region |

### AIProvider (enum, existing)

| Value | Meaning |
|-------|---------|
| `enjoy` | Enjoy worker / token paths (default) |
| `byok` | User-supplied credentials |
| `local` | **Not exposed in UI** — unreachable |

### ModalityKind (enum, domain)

| Value | Services sharing config |
|-------|-------------------------|
| `llm` | chat, translation, dictionary, contextual translation |
| `asr` | speech recognition |
| `tts` | text-to-speech |
| `assessment` | pronunciation assessment |

### LlmByokConfig

Non-secret fields persisted in Drift JSON.

| Field | Type | Validation |
|-------|------|------------|
| `apiSpec` | `LlmApiSpec` | Required when provider is BYOK |
| `baseUrl` | `String` | Required; HTTPS; passes URL guard |
| `model` | `String` | Required; non-empty trim |
| `presetId` | `String?` | UX only; e.g. `deepseek`, `openai` |

Secret: `apiKey` stored separately in secure storage (see [byok-persistence.md](./contracts/byok-persistence.md)).

### SpeechByokConfig

Used for ASR, TTS, and assessment (assessment forces `azureSpeech`).

| Field | Type | Validation |
|-------|------|------------|
| `kind` | `SpeechByokKind` | Required |
| `baseUrl` | `String?` | Required when `kind == openAiCompatible` |
| `model` | `String?` | Required when `kind == openAiCompatible` (Whisper/TTS model id) |
| `region` | `String?` | Required when `kind == azureSpeech` |
| `presetId` | `String?` | Optional |

Secret: `apiKey` / subscription key in secure storage.

### AIServiceConfig (extended)

Existing Freezed type; BYOK branch holds typed config:

```dart
AIServiceConfig(
  provider: AIProvider.byok,
  byok: /* legacy BYOKConfig migration or new union */,
)
```

**Planning shape** (implementation may use sealed union or parallel fields):

| Modality | BYOK payload |
|----------|--------------|
| LLM | `LlmByokConfig` + secure key |
| ASR / TTS / assessment | `SpeechByokConfig` + secure key |

### AiModalityConfigs (aggregate)

| Field | Type |
|-------|------|
| `llm` | `AIServiceConfig` |
| `asr` | `AIServiceConfig` |
| `tts` | `AIServiceConfig` |
| `assessment` | `AIServiceConfig` |

**Default** (unchanged behavior): all modalities `AIServiceConfig(provider: AIProvider.enjoy)`.

### ModalityConfigsSnapshot (persistence DTO)

Drift value at `SettingsKeys.aiModalityConfigsV1` — JSON without secrets.

```json
{
  "llm": {
    "provider": "byok",
    "llmByok": {
      "apiSpec": "openAiCompatible",
      "baseUrl": "https://api.deepseek.com/v1",
      "model": "deepseek-chat",
      "presetId": "deepseek"
    }
  },
  "asr": { "provider": "enjoy" },
  "tts": { "provider": "enjoy" },
  "assessment": {
    "provider": "byok",
    "speechByok": {
      "kind": "azureSpeech",
      "region": "eastus"
    }
  }
}
```

### ByokSecretRef

Logical key for secure storage: `enjoy_player.byok.{modality}.api_key`.

| Modality | Secure key suffix |
|----------|-------------------|
| `llm` | `llm` |
| `asr` | `asr` |
| `tts` | `tts` |
| `assessment` | `assessment` |

On **Remove BYOK**: delete secure key + reset modality to `enjoy` in Drift JSON.

## State transitions

### Per-modality provider

```text
[default] enjoy
[user enables BYOK + saves valid config] byok (active)
[user switches to Enjoy AI] enjoy (byok meta may remain dormant)
[user Remove BYOK] enjoy + secret deleted
```

### Settings edit flow

```text
[open card] → load Drift meta + masked secret hint
[edit fields] → client-side validation
[save] → write secure key (if changed) → write Drift JSON → invalidate aiModalityConfigsProvider
[next AI call] → capability resolver reads new config
```

## Relationships

```text
AiModalityConfigs
  ├── llm ──► LlmByokConfig (optional) ──► LlmApiSpec
  ├── asr ──► SpeechByokConfig (optional) ──► SpeechByokKind
  ├── tts ──► SpeechByokConfig (optional)
  └── assessment ──► SpeechByokConfig (azure only)

Translation / Dictionary / ContextualTranslation / Chat
  └── inherit llm config via llmCapabilityProvider
```

## Validation summary

| Modality | BYOK valid when |
|----------|-----------------|
| LLM | `apiSpec` + `baseUrl` + `model` + `apiKey` all present; URL guard pass |
| ASR OpenAI | `baseUrl` + `model` + `apiKey`; URL guard pass |
| ASR Azure | `region` + `apiKey` |
| TTS OpenAI | same as ASR OpenAI |
| TTS Azure | `region` + `apiKey` |
| Assessment | `region` + `apiKey`; `kind` must be azure |

## Migration / compatibility

- Existing installs: absent `ai.modality_configs_v1` → use `AiModalityConfigs.defaults`.
- Legacy `BYOKVendor` enum may map to new shapes for any in-flight dev builds:
  - `openai` + endpoint → `LlmApiSpec.openAiCompatible`
  - `claude` → `anthropicCompatible`
  - `google` → `googleCompatible`
  - `azure` (LLM) → `openAiCompatible` with Azure OpenAI base URL
- No server sync; no migration of keys across devices.
