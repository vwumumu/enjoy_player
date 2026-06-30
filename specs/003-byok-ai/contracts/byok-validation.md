# Contract: BYOK Validation

**Feature**: `003-byok-ai` | **Consumer**: `ByokConfigValidator` | **Version**: 1.0

Port rules from Enjoy `byok-validation.ts` + `byok-url-guard.ts`, extended for protocol-spec model and Azure ASR.

## URL guard (`byok_url_guard.dart`)

Reject base URL when:

- Scheme is not `https`
- Host is `localhost` or `127.0.0.1`
- Host matches private IP ranges (`10.*`, `172.16–31.*`, `192.168.*`)
- URL fails parse

**Pass examples**:

- `https://api.openai.com/v1`
- `https://api.deepseek.com/v1`
- `https://my-resource.openai.azure.com/openai/deployments/foo`

**Fail examples**:

- `http://api.openai.com/v1`
- `https://localhost:8080/v1`
- `https://192.168.1.5/v1`

## LLM BYOK

| Field | Rule |
|-------|------|
| `apiSpec` | Required enum |
| `baseUrl` | Required; URL guard |
| `model` | Required; non-empty trim |
| `apiKey` | Required on first save; on edit may omit if existing secure key |

## Speech BYOK — OpenAI-compatible (ASR / TTS)

| Field | Rule |
|-------|------|
| `kind` | `openAiCompatible` |
| `baseUrl` | Required; URL guard |
| `model` | Required (e.g. `whisper-1`, `tts-1`) |
| `apiKey` | Required |

## Speech BYOK — Azure (ASR / TTS / assessment)

| Field | Rule |
|-------|------|
| `kind` | `azureSpeech` (assessment: only allowed kind) |
| `region` | Required; non-empty trim (e.g. `eastus`, `southeastasia`) |
| `apiKey` | Required subscription key |
| `baseUrl` | Must be absent / ignored |

## Error codes (localization keys)

Map validator failures to ARB keys:

| Key suffix | When |
|------------|------|
| `byokValidationApiKeyRequired` | Missing key |
| `byokValidationBaseUrlRequired` | Missing URL |
| `byokValidationBaseUrlInvalid` | URL guard fail |
| `byokValidationModelRequired` | Missing model |
| `byokValidationRegionRequired` | Azure without region |
| `byokValidationApiSpecRequired` | Missing LLM spec |

## Fetch models pre-check

Before network fetch:

- baseUrl passes URL guard
- apiKey non-empty
- Only for `LlmApiSpec.openAiCompatible`

## Runtime vendor errors (post-save)

Map HTTP status to user messages without echoing secrets:

| Status | User message class |
|--------|-------------------|
| 401 / 403 | Invalid API key |
| 429 | Rate limit |
| 5xx | Provider unavailable |
| Network | Offline / connection error |

Log via `logNamed` with provider + modality; **never** log Authorization header or key.
