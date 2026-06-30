# Quickstart: BYOK AI Provider Settings

**Feature**: `003-byok-ai` | **Date**: 2026-06-30

Validation guide after implementation. See [contracts/](./contracts/) and [data-model.md](./data-model.md).

## Prerequisites

- Flutter SDK matching `pubspec.yaml`
- Enjoy API reachable for **Enjoy AI** regression tests (`api.base_url`, `api.ai_base_url`)
- **Optional BYOK keys** (never commit):
  - DeepSeek or OpenAI key for LLM OpenAI-compatible test
  - Azure Speech subscription key + region for assessment/ASR BYOK
- Test WAV: 16 kHz mono PCM for assessment/ASR Azure paths

## Setup

```bash
cd c:/Users/me/dev/enjoy_player
flutter pub get
dart run build_runner build
flutter gen-l10n
```

## Automated verification

```bash
flutter analyze
flutter test test/features/ai/domain/byok_config_validator_test.dart
flutter test test/core/validation/byok_url_guard_test.dart
flutter test test/features/ai/
flutter test
```

**Expected**: All tests pass; no secrets in test fixtures committed to repo.

## Manual scenarios

### QS-1 — Default Enjoy AI unchanged (SC-001)

1. Fresh install or delete `ai.modality_configs_v1` from app data.
2. Open transcript dictionary lookup or AI playground chat.

**Expected**: Works via Enjoy AI; no BYOK prompt unless credits fail.

### QS-2 — DeepSeek LLM BYOK (SC-009)

1. Settings → **AI providers** → LLM → BYOK.
2. Spec: **OpenAI-compatible**; preset **DeepSeek** (or manual base URL `https://api.deepseek.com/v1`).
3. Enter API key + model `deepseek-chat` → Save.
4. AI playground → Translation with sample text.

**Expected**: Translation succeeds; Enjoy credits not consumed (no 402 from Enjoy worker for that call).

### QS-3 — Anthropic-compatible custom base URL

1. LLM BYOK → spec **Anthropic-compatible**.
2. Set base URL, key, model → Save.
3. Run chat completion in playground.

**Expected**: Response from configured endpoint; all three fields were editable.

### QS-4 — Azure assessment BYOK (SC-004)

1. Assessment modality → BYOK → Azure.
2. Enter subscription key + region → Save.
3. AI playground or echo → assess recording with reference text.

**Expected**: Scores returned; no Enjoy Azure token request in logs (`ai.enjoy.assessment` token path skipped for BYOK).

### QS-5 — Azure ASR BYOK (SC-008)

1. ASR → BYOK → Azure → key + region → Save.
2. Playground → transcribe sample WAV.

**Expected**: Transcript text returned via Azure Speech.

### QS-6 — Remove BYOK per modality (Story 6)

1. Configure BYOK on LLM only; leave assessment on Enjoy.
2. Remove LLM BYOK.

**Expected**: LLM reverts to Enjoy; assessment unchanged; secure key deleted for LLM.

### QS-7 — Validation UX (SC-003)

1. Attempt save with empty base URL on OpenAI-compatible LLM.

**Expected**: Inline field error; no save; no partial secure write.

### QS-8 — Security (SC-005)

1. Trigger invalid API key error on BYOK call.
2. Inspect on-screen error and debug logs (verbose diagnostics if enabled).

**Expected**: No full API key in UI or logs.

## Platform matrix

| Scenario | Android | iOS | macOS | Windows |
|----------|---------|-----|-------|---------|
| QS-1 Enjoy default | ✓ | ✓ | ✓ | ✓ |
| QS-2 DeepSeek BYOK | ✓ | ✓ | ✓ | ✓ |
| QS-4 Azure assessment | ✓ | ✓ | ✓ | ✓ |
| QS-5 Azure ASR | ✓ | ✓ | ✓ | ✓ |

## Rollback

To reset BYOK locally:

1. Remove BYOK per modality in settings, **or**
2. Clear app data / reinstall (dev only).

No server-side BYOK state to clear.
