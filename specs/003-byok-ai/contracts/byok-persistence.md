# Contract: BYOK Persistence

**Feature**: `003-byok-ai` | **Consumer**: `AiModalityConfigRepository` / `ByokSecretStore` | **Version**: 1.0

## Split storage

| Data | Store | Key pattern |
|------|-------|-------------|
| Provider choice + non-secret BYOK fields | Drift `SettingsDao` | `SettingsKeys.aiModalityConfigsV1` |
| API keys / subscription secrets | `flutter_secure_storage` | `enjoy_player.byok.{modality}.api_key` |

**Rule**: Drift JSON MUST NEVER contain `apiKey`, `subscriptionKey`, or equivalent secret fields.

## Drift JSON schema (v1)

Top-level object with keys `llm`, `asr`, `tts`, `assessment`. Each modality:

```json
{
  "provider": "enjoy" | "byok",
  "llmByok": { "apiSpec": "...", "baseUrl": "...", "model": "...", "presetId": "..." },
  "speechByok": { "kind": "...", "baseUrl": "...", "model": "...", "region": "...", "presetId": "..." }
}
```

- Include `llmByok` only when `provider == "byok"` and modality is `llm`.
- Include `speechByok` only when `provider == "byok"` and modality is `asr` | `tts` | `assessment`.
- Omit unknown keys on read (forward compatible).

## Secure storage API

```dart
abstract class ByokSecretStore {
  Future<void> writeApiKey(ModalityKind modality, String apiKey);
  Future<String?> readApiKey(ModalityKind modality);
  Future<void> deleteApiKey(ModalityKind modality);
  Future<bool> hasApiKey(ModalityKind modality);
}
```

**Platform options**: Reuse `SecureTokenStore` Android/iOS options (`first_unlock` on iOS).

## Repository operations

### `load() → AiModalityConfigs`

1. Read Drift JSON; if missing → defaults (all Enjoy).
2. For each BYOK modality, verify secure key exists; if missing → treat modality as **misconfigured BYOK** (provider stays `byok` but capability layer returns actionable error — spec edge case).

### `saveModality(modality, config, apiKey?)`

1. Validate via `ByokConfigValidator`.
2. If `apiKey` non-null → `writeApiKey`.
3. Upsert Drift JSON for modality.
4. Invalidate `aiModalityConfigsProvider`.

### `removeByok(modality)`

1. `deleteApiKey(modality)`.
2. Set modality `provider: enjoy`; remove `llmByok` / `speechByok`.
3. Invalidate provider.

## Masked display

UI reads `hasApiKey` + last-four hint stored nowhere — derive mask at display time only when user re-opens form:

- If key exists and user not editing: show `****` + optional last 4 from secure read in edit mode only.
- Never persist mask string in Drift.

## Sign out behavior

**v1**: BYOK secrets **persist across sign out** (device-local keys, not account-scoped). Document in settings privacy notice. Future ADR may clear on sign out.
