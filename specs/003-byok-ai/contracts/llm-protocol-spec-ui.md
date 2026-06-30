# Contract: LLM Protocol Spec Settings UI

**Feature**: `003-byok-ai` | **Consumer**: `LlmByokForm` / `ModalityProviderCard` | **Version**: 1.0

## Screen entry

- **Route**: `/settings/ai-providers` (or nested under settings shell)
- **Navigation**: Settings main list → **AI providers** tile (user-facing, not Developer-only)

## LLM modality card states

| State | UI |
|-------|-----|
| Enjoy AI | Radio/toggle: Enjoy selected; BYOK form hidden |
| BYOK (new) | BYOK selected; empty form with spec default `openAiCompatible` |
| BYOK (saved) | BYOK selected; form filled from Drift; key masked |
| BYOK misconfigured | Banner: complete setup; link focuses form |

## Protocol spec selector

Three options (localized labels):

1. **OpenAI-compatible**
2. **Anthropic-compatible**
3. **Google-compatible**

Changing spec:

- Updates preset list for that spec.
- Does **not** auto-clear user-edited base URL/model unless user confirms (optional discard dialog) OR spec change resets only when no unsaved edits — **implementation choice**: preserve fields when switching spec if all three fields already filled (user may fix protocol only).

## Uniform field set (all specs)

| Field | Control | Required on save |
|-------|---------|------------------|
| Base URL | `TextFormField` url | Yes |
| API key | `TextFormField` password + show toggle | Yes (or existing secure key if not editing) |
| Model | `TextFormField` or dropdown after fetch | Yes |

**No separate "Custom" spec type.**

## Presets (optional chips / dropdown)

Presets apply only to **currently selected spec**. Selecting a preset fills `baseUrl` + suggested `model`; user may edit before save.

Minimum presets:

| Spec | Preset IDs |
|------|------------|
| OpenAI-compatible | `openai`, `deepseek`, `groq`, `azureOpenAi` |
| Anthropic-compatible | `anthropic` |
| Google-compatible | `google` |

Preset id persisted as `presetId` (non-authoritative).

## Fetch models (OpenAI-compatible only)

**When**: User taps **Fetch models** and base URL + API key valid.

**Behavior**:

1. `GET {baseUrl}/models` (OpenAI-style) with bearer key.
2. On success → populate model dropdown.
3. On failure → inline message; manual model entry remains.

Anthropic/Google: show Fetch only if implementation detects compatible listing endpoint; otherwise hide control.

## Actions

| Action | Result |
|--------|--------|
| Save | Validate → repository save → success notice → pop or stay |
| Remove BYOK | Confirm dialog → `removeByok(llm)` → revert card to Enjoy |
| Cancel | Discard unsaved edits |

## Privacy notice

Static copy (localized): keys stored on device only; never sent to Enjoy servers.

## Accessibility

- All fields have labels + error text linked via `semantics`.
- Icon-only show-key button has tooltip.

## Other modality cards (summary)

| Modality | BYOK options | Fields |
|----------|--------------|--------|
| ASR | OpenAI-compatible Whisper **or** Azure Speech | Whisper: base URL + key + model; Azure: key + region |
| TTS | OpenAI-compatible **or** Azure | Same pattern as ASR |
| Assessment | Azure only | key + region |

Speech cards use `SpeechByokForm`; same mask/save/remove patterns as LLM.
