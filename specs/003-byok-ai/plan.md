# Implementation Plan: BYOK AI Provider Settings

**Branch**: `003-byok-ai` | **Date**: 2026-06-30 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/003-byok-ai/spec.md`

## Summary

Add **Bring Your Own Key (BYOK)** for all AI modalities in Enjoy Player while keeping **Enjoy AI** the default. Users configure per-modality provider choice (Enjoy vs BYOK) in **Settings → AI providers** (user-facing, not developer-only).

**LLM BYOK** uses **protocol spec types** (OpenAI-compatible, Anthropic-compatible, Google-compatible) with **uniform customizable fields** (base URL, API key, model) and optional presets (OpenAI, DeepSeek, Claude, Gemini). Backend: **`ai_sdk_dart`** provider packages calling vendor HTTPS directly (no Enjoy worker BYOK proxy on native).

**Speech BYOK**: ASR/TTS OpenAI-compatible paths + **Azure Speech** (subscription key + region) for ASR, TTS, and assessment. Assessment BYOK reuses `packages/azure_speech` with subscription-key auth instead of Enjoy token cache. Azure ASR BYOK requires extending the `azure_speech` plugin for recognize-once transcription.

**Persistence**: Non-secret modality config in Drift `SettingsDao` (JSON); API keys in `flutter_secure_storage` via extended `SecureTokenStore`. **`aiModalityConfigsProvider`** becomes async/loadable from persistence and drives existing `*CapabilityProvider` resolution.

## Technical Context

**Language/Version**: Dart ^3.12, Flutter stable (SDK constraint in `pubspec.yaml`)

**Primary Dependencies**:
- Existing: Riverpod 3 (`@riverpod`), Drift `SettingsDao`, `flutter_secure_storage`, `http`, `azure_speech`, Enjoy AI HTTP clients
- **New**: `ai_sdk_dart`, `ai_sdk_openai`, `ai_sdk_anthropic`, `ai_sdk_google` (LLM BYOK)
- **Optional fallback** (spike): `openai_dart` for OpenAI-compatible ASR Whisper multipart if not using raw `http`

**Storage**:
- Drift key `ai.modality_configs_v1` — JSON map of per-modality `{ provider, byokMeta }` without secrets
- Secure storage keys `enjoy_player.byok.{modality}.api_key` — one secret per modality BYOK bundle
- No new Drift tables; extend `SettingsKeys` + `SecureTokenStore`

**Testing**: `flutter test` — unit tests for validation, URL guard, config serialization, capability routing, secret store; widget tests for protocol-spec forms and modality cards; integration-style tests for `ByokLlmCapability` with mocked HTTP or fake provider

**Target Platform**: Android, iOS, macOS, Windows (no Flutter web)

**Project Type**: Flutter native mobile/desktop app

**Performance Goals**:
- Load cached modality configs in **<100 ms** on AI feature open (QR-004)
- BYOK settings save → secure write + Drift update without blocking UI (>16 ms work off critical path via async)
- No regression to Enjoy AI default path latency

**Constraints**:
- No `AIProvider.local` in UI; no cloud sync of BYOK keys (spec out of scope)
- No Enjoy worker `/byok-proxy` for native LLM (direct HTTPS only)
- HTTPS-only base URLs; block localhost/private IPs (port Enjoy `byok-url-guard` rules)
- Never log or display full API keys (FR-005, FR-006, SC-005)
- Single `media_kit` player unchanged; widgets use `*ServiceProvider` only (FR-014)

**Scale/Scope**:
- Extend `lib/features/ai/` (~25–35 new/modified Dart files)
- New settings screens/widgets under `lib/features/ai/presentation/settings/` or `lib/features/settings/`
- Extend `packages/azure_speech` for subscription-key ASR (+ assessment BYOK variant)
- ~15–20 test files, ~80 ARB keys, 1 ADR, docs update

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### I. Architecture and Code Quality

- **Pass**: Extend `lib/features/ai/{domain,data,application,presentation}`; URL validation in `lib/core/` or `lib/features/ai/domain/`; secure I/O in `lib/data/api/`.
- **Pass**: Domain models (`LlmApiSpec`, `ModalityByokConfig`, `AiModalityConfigs`) remain UI-free.
- **Pass**: Persistence via Drift `SettingsDao` + `SecureTokenStore` (ADR-0002 pattern).
- **Pass**: Replace static `AiModalityConfigs.defaults` with `@Riverpod` notifier reading persisted config; capability providers already watch `aiModalityConfigsProvider`.
- **Pass**: No new global singletons; no `print()`.

### II. Testing Defines the Contract

- **Required**: Unit — `ByokConfigValidator`, URL guard, JSON round-trip, `resolve*Capability` routing for Enjoy vs BYOK per modality.
- **Required**: Unit — `ByokLlmCapability` message mapping (mock `ai_sdk_dart` or HTTP client).
- **Required**: Widget — LLM protocol form (all three specs show base URL field); modality card save/remove; masked key display.
- **Manual**: DeepSeek OpenAI-compatible translation; Azure assessment BYOK with user key; Azure ASR on Windows/macOS (see [quickstart.md](./quickstart.md)).
- **Codegen**: `dart run build_runner build` after new `@Riverpod` / Freezed types.

### III. User Experience Consistency

- **Pass**: ARB strings in `app_en.arb` + `app_zh.arb`; `flutter gen-l10n`.
- **Pass**: `EnjoyTappableSurface`, `EnjoyButton`, `EnjoyModal` for settings cards and save/remove flows; tooltips on icon-only actions.
- **Pass**: Move AI provider settings to main Settings (new section), not only Developer block (FR-015).
- **Docs**: Update `docs/features/ai.md`; new ADR for BYOK persistence + protocol-spec UI.

### IV. Performance Is a Requirement

- **Pass**: In-memory cache on `aiModalityConfigsProvider` (keepAlive); invalidate on settings save only.
- **Pass**: Secure storage reads batched once per capability invocation, not per widget rebuild.
- **Evidence**: Manual — dictionary lookup cold open with default Enjoy config unchanged vs baseline.

### V. Documentation and Traceability

- **Required**: ADR `docs/decisions/0033-byok-ai-provider-settings.md` — protocol-spec UI, Drift+secure split, direct vendor HTTPS.
- **Required**: `docs/features/ai.md` BYOK section; link from `docs/README.md` if new top-level mention needed.
- **No exception** needed.

**Post-design re-check**: All gates pass. `azure_speech` plugin extension is scoped package work, not a feature-to-feature shortcut.

## Project Structure

### Documentation (this feature)

```text
specs/003-byok-ai/
├── plan.md              # This file
├── research.md          # Phase 0 (updated with storage + spike outcomes)
├── data-model.md        # Phase 1
├── quickstart.md        # Phase 1 validation guide
├── contracts/           # Phase 1
│   ├── byok-persistence.md
│   ├── llm-protocol-spec-ui.md
│   ├── modality-capability-routing.md
│   └── byok-validation.md
└── tasks.md             # Phase 2 (/speckit-tasks — not created here)
```

### Source Code (repository root)

```text
lib/
├── core/
│   └── validation/
│       └── byok_url_guard.dart              # NEW — HTTPS + host denylist
├── data/
│   ├── api/
│   │   ├── secure_token_store.dart          # EXTEND — BYOK secret helpers
│   │   └── byok_secret_store.dart           # NEW — modality-scoped keys
│   └── db/
│       └── settings_keys.dart               # EXTEND — ai.modality_configs_v1
├── features/ai/
│   ├── domain/
│   │   ├── llm_api_spec.dart                # NEW enum
│   │   ├── speech_api_spec.dart             # NEW — whisper vs azure
│   │   ├── modality_byok_config.dart        # NEW freezed
│   │   ├── ai_service_config.dart           # EXTEND — apiSpec fields
│   │   └── byok_config_validator.dart       # NEW
│   ├── data/
│   │   ├── byok/
│   │   │   ├── byok_llm_capability.dart     # NEW — ai_sdk_dart
│   │   │   ├── byok_asr_openai_capability.dart
│   │   │   ├── byok_asr_azure_capability.dart
│   │   │   ├── byok_tts_openai_capability.dart
│   │   │   ├── byok_tts_azure_capability.dart
│   │   │   └── byok_assessment_azure_capability.dart
│   │   ├── ai_modality_config_repository.dart  # NEW — Drift + secrets
│   │   └── stub_ai_capabilities.dart        # REMOVE usages
│   ├── application/
│   │   ├── ai_modality_configs.dart         # EXTEND — from repository
│   │   ├── ai_modality_config_controller.dart  # NEW @Riverpod notifier
│   │   └── ai_capability_providers.dart     # WIRE BYOK impls
│   └── presentation/
│       ├── settings/
│       │   ├── ai_providers_screen.dart     # NEW
│       │   ├── widgets/
│       │   │   ├── modality_provider_card.dart
│       │   │   ├── llm_byok_form.dart       # protocol spec UI
│       │   │   ├── speech_byok_form.dart    # ASR/TTS/assessment
│       │   │   └── byok_preset_chips.dart
│       │   └── llm_presets.dart             # NEW — DeepSeek, OpenAI, etc.
│       └── ai_playground_screen.dart        # EXTEND — show active provider
├── features/settings/presentation/
│   └── settings_screen.dart                 # ADD nav tile → AI providers
└── l10n/
    ├── app_en.arb
    └── app_zh.arb

packages/azure_speech/
├── lib/                                     # EXTEND — transcribe + sub-key assess
└── ...

test/
├── features/ai/
│   ├── domain/byok_config_validator_test.dart
│   ├── data/byok_llm_capability_test.dart
│   ├── data/ai_modality_config_repository_test.dart
│   └── presentation/llm_byok_form_test.dart
└── core/validation/byok_url_guard_test.dart

docs/
├── features/ai.md                           # UPDATE
└── decisions/0033-byok-ai-provider-settings.md
```

**Structure Decision**: BYOK lives inside existing `ai` feature (ADR-0014). Settings UI can sit under `ai/presentation/settings/` with a entry tile from `settings_screen.dart` — avoids a cross-feature import from settings into ai data layer beyond navigation.

## Complexity Tracking

> No constitution violations.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| — | — | — |

## Implementation Phases (for `/speckit-tasks`)

### Phase A — Domain, persistence, validation (foundation)

1. Add `LlmApiSpec`, `SpeechByokKind` (openAiCompatible / azure), `ModalityByokConfig` Freezed types.
2. Extend `SettingsKeys` + `AiModalityConfigRepository` (Drift JSON + `ByokSecretStore`).
3. Implement `ByokConfigValidator` + `byok_url_guard` (HTTPS, deny private hosts).
4. Replace static `aiModalityConfigsProvider` with notifier loading defaults → persisted overlay.
5. Unit tests for validator, URL guard, repository round-trip (secrets mocked).

### Phase B — LLM BYOK backend (P1 story 2)

1. Add `ai_sdk_dart` dependencies; spike OpenAI-compatible + DeepSeek base URL.
2. Implement `ByokLlmCapability` mapping `LlmApiSpec` → `ai_sdk_*` provider with custom `baseURL`.
3. Wire `resolveLlmCapability` + downstream translation/dictionary/contextual (via `llmCapabilityProvider`).
4. Unit tests with mocked generateText / HTTP.

### Phase C — LLM settings UI (P1 story 2, FR-017–019)

1. Build `AiProvidersScreen` with LLM modality card.
2. `LlmByokForm` — spec selector + uniform fields + optional presets (OpenAI, DeepSeek, Anthropic, Google).
3. Fetch models button for OpenAI-compatible when endpoint supports listing.
4. Save/remove flows; masked key UX; localized validation errors.
5. Widget tests for form states.

### Phase D — Azure assessment BYOK (P1 story 4)

1. `ByokAssessmentAzureCapability` — subscription key + region via `AzureSpeech` (extend plugin if token-only today).
2. Wire `resolveAssessmentCapability`; echo + playground paths unchanged at service layer.
3. Manual + unit tests with mocked SDK.

### Phase E — ASR BYOK (P2 story 3)

1. `ByokAsrOpenAiCapability` — Whisper multipart via `http` or `openai_dart`.
2. Extend `azure_speech` for recognize-once ASR with subscription key; `ByokAsrAzureCapability`.
3. Wire `resolveAsrCapability`; playground transcribe validation.

### Phase F — TTS BYOK + credential management (P3 story 5, P2 story 6)

1. TTS OpenAI-compatible + Azure capabilities (stub OK if Enjoy TTS still unimplemented — BYOK ready).
2. Per-modality remove/revert to Enjoy; partial BYOK across modalities.
3. Complete remaining modality cards on `AiProvidersScreen`.

### Phase G — Docs, ADR, verification

1. ADR-0033, `docs/features/ai.md`, quickstart manual passes.
2. `flutter gen-l10n`, `dart run build_runner build`, `flutter analyze`, `flutter test`.

## Risk Notes

| Risk | Mitigation |
|------|------------|
| `ai_sdk_dart` low adoption / API gaps | Time-boxed spike in Phase B; fallback to `openai_dart` + thin HTTP for Anthropic/Google |
| `ai_sdk_anthropic` / `ai_sdk_google` lack custom baseURL | Custom HTTP adapter in `ByokLlmCapability`; UI still persists user base URL |
| `azure_speech` only supports token auth today | Plugin PR: accept subscription key OR token param (same SDK entry point) |
| Secret leakage in logs | Code review gate; test asserts error messages exclude key substrings |
| Enjoy web validation drift | Player follows `packages/ai` capability routing + spec protocol model |

## Phase 0 / Phase 1 Artifacts

- [research.md](./research.md) — library choice, protocol UI, storage decision (§8 added)
- [data-model.md](./data-model.md)
- [contracts/](./contracts/)
- [quickstart.md](./quickstart.md)
