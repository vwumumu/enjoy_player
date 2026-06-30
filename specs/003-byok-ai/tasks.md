---
description: "Task list for BYOK AI provider settings"
---

# Tasks: BYOK AI Provider Settings

**Input**: Design documents from `/specs/003-byok-ai/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Required per plan Constitution Check — unit tests for validator, URL guard, repository, capability routing, `ByokLlmCapability`; widget tests for protocol-spec forms and modality cards.

**Organization**: Tasks grouped by user story (US1–US6) plus setup, foundation, and polish.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Maps to user stories in spec.md (US1–US6)

## Path Conventions

- **Feature code**: `lib/features/ai/{application,data,domain,presentation}/`
- **Shared**: `lib/core/validation/`, `lib/data/api/`, `lib/data/db/settings_keys.dart`
- **Plugin**: `packages/azure_speech/`
- **Routing**: `lib/core/routing/app_router.dart`
- **Tests**: `test/features/ai/`, `test/core/validation/`
- **Docs**: `docs/features/ai.md`, `docs/decisions/0033-byok-ai-provider-settings.md`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Dependencies, directory scaffold, design review.

- [X] T001 Review spec, plan, contracts, and quickstart in `specs/003-byok-ai/`
- [X] T002 Create directory scaffold `lib/features/ai/presentation/settings/widgets/` and `lib/features/ai/data/byok/`
- [X] T003 Add `ai_sdk_dart`, `ai_sdk_openai`, `ai_sdk_anthropic`, `ai_sdk_google` to `pubspec.yaml` per `specs/003-byok-ai/research.md`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Domain types, persistence, validation, config loading — MUST complete before user story phases.

**⚠️ CRITICAL**: No user story work until this phase is complete.

### Tests for Foundation

- [X] T004 [P] Add URL guard unit tests in `test/core/validation/byok_url_guard_test.dart` per `specs/003-byok-ai/contracts/byok-validation.md`
- [X] T005 [P] Add validator unit tests in `test/features/ai/domain/byok_config_validator_test.dart`
- [X] T006 [P] Add repository unit tests in `test/features/ai/data/ai_modality_config_repository_test.dart` (mock `ByokSecretStore`)

### Implementation for Foundation

- [X] T007 [P] Add `LlmApiSpec` enum in `lib/features/ai/domain/llm_api_spec.dart`
- [X] T008 [P] Add `SpeechByokKind` enum in `lib/features/ai/domain/speech_byok_kind.dart`
- [X] T009 [P] Add `LlmByokConfig` and `SpeechByokConfig` Freezed types in `lib/features/ai/domain/modality_byok_config.dart`
- [X] T010 Extend `AIServiceConfig` / BYOK union in `lib/features/ai/domain/ai_service_config.dart` per `specs/003-byok-ai/data-model.md`
- [X] T011 [P] Implement HTTPS host denylist in `lib/core/validation/byok_url_guard.dart`
- [X] T012 Implement `ByokConfigValidator` in `lib/features/ai/domain/byok_config_validator.dart` per `specs/003-byok-ai/contracts/byok-validation.md`
- [X] T013 [P] Add `SettingsKeys.aiModalityConfigsV1` in `lib/data/db/settings_keys.dart`
- [X] T014 [P] Implement `ByokSecretStore` in `lib/data/api/byok_secret_store.dart` per `specs/003-byok-ai/contracts/byok-persistence.md`
- [X] T015 Implement `AiModalityConfigRepository` (load/save/remove) in `lib/features/ai/data/ai_modality_config_repository.dart`
- [X] T016 Implement `@Riverpod` `AiModalityConfigController` in `lib/features/ai/application/ai_modality_config_controller.dart` replacing static defaults in `lib/features/ai/application/ai_modality_configs.dart`
- [X] T017 Wire `aiModalityConfigsProvider` in `lib/features/ai/application/ai_capability_providers.dart` to watch controller (Enjoy paths unchanged when no BYOK saved)
- [X] T018 Run `dart run build_runner build` after Freezed and `@Riverpod` additions

**Checkpoint**: Defaults load as all-Enjoy; validator and URL guard tests pass; repository round-trips JSON without secrets.

---

## Phase 3: User Story 1 — Keep Enjoy AI as the default (Priority: P1) 🎯 MVP

**Goal**: Existing users see no behavior change until they opt into BYOK; settings show Enjoy AI for every modality.

**Independent Test**: Fresh install → dictionary lookup succeeds via Enjoy AI; Settings → AI providers shows Enjoy for all modalities (QS-1 in `specs/003-byok-ai/quickstart.md`).

### Tests for User Story 1

- [X] T019 [P] [US1] Add unit test asserting `AiModalityConfigs.defaults` when Drift key absent in `test/features/ai/application/ai_modality_config_controller_test.dart`
- [X] T020 [P] [US1] Add regression test that `resolveLlmCapability` returns `EnjoyLlmCapability` for default config in `test/features/ai/application/ai_capability_providers_test.dart`

### Implementation for User Story 1

- [X] T021 [P] [US1] Add `/settings/ai-providers` route in `lib/core/routing/app_router.dart`
- [X] T022 [US1] Create shell `AiProvidersScreen` listing four modality cards defaulting to Enjoy in `lib/features/ai/presentation/settings/ai_providers_screen.dart`
- [X] T023 [US1] Add Settings nav tile (user-facing, not Developer-only) in `lib/features/settings/presentation/settings_screen.dart`
- [X] T024 [P] [US1] Add core BYOK settings ARB keys (screen title, Enjoy AI label, privacy notice) in `lib/l10n/app_en.arb` and `lib/l10n/app_zh.arb`
- [X] T025 [US1] Run `flutter gen-l10n` after US1 strings

**Checkpoint**: MVP — app behaves as today; new settings screen shows all Enjoy with no BYOK backend wired yet.

---

## Phase 4: User Story 2 — Configure BYOK for LLM-backed features (Priority: P1)

**Goal**: Protocol-spec LLM BYOK (OpenAI / Anthropic / Google-compatible) with uniform base URL + key + model; DeepSeek via preset.

**Independent Test**: Configure DeepSeek OpenAI-compatible BYOK → translation in playground succeeds without Enjoy credits (QS-2, SC-009).

### Tests for User Story 2

- [X] T026 [P] [US2] Add `ByokLlmCapability` unit tests with mocked `ai_sdk_dart` in `test/features/ai/data/byok/byok_llm_capability_test.dart`
- [X] T027 [P] [US2] Add widget tests for `LlmByokForm` (three specs show base URL field) in `test/features/ai/presentation/settings/llm_byok_form_test.dart`

### Implementation for User Story 2

- [X] T028 [US2] Time-boxed spike: verify OpenAI-compatible + DeepSeek base URL chat completion via `ai_sdk_openai` (document result in PR or `specs/003-byok-ai/research.md` spike section)
- [X] T029 [P] [US2] Implement `ByokLlmCapability` in `lib/features/ai/data/byok/byok_llm_capability.dart` mapping `LlmApiSpec` → `ai_sdk_*` with user `baseURL`
- [X] T030 [P] [US2] Add preset table (OpenAI, DeepSeek, Groq, Azure OpenAI, Anthropic, Google) in `lib/features/ai/presentation/settings/llm_presets.dart`
- [X] T031 [US2] Wire `resolveLlmCapability` BYOK branch in `lib/features/ai/application/ai_capability_providers.dart`
- [X] T032 [P] [US2] Implement BYOK translation/dictionary/contextual paths using `LlmCapability` prompts (port Enjoy worker prompt shapes) in `lib/features/ai/data/byok/byok_translation_capability.dart` and related files as needed
- [X] T033 [US2] Build `LlmByokForm` (spec selector, base URL, key, model, presets, fetch models) in `lib/features/ai/presentation/settings/widgets/llm_byok_form.dart` per `specs/003-byok-ai/contracts/llm-protocol-spec-ui.md`
- [X] T034 [US2] Build `ModalityProviderCard` Enjoy/BYOK toggle + save in `lib/features/ai/presentation/settings/widgets/modality_provider_card.dart`
- [X] T035 [US2] Connect LLM card save/remove to `AiModalityConfigController` in `lib/features/ai/presentation/settings/ai_providers_screen.dart`
- [X] T036 [P] [US2] Add LLM BYOK validation and error ARB keys in `lib/l10n/app_en.arb` and `lib/l10n/app_zh.arb`

**Checkpoint**: LLM BYOK end-to-end including DeepSeek preset; Enjoy AI still default for users who do not configure.

---

## Phase 5: User Story 4 — Configure Azure BYOK for pronunciation assessment (Priority: P1)

**Goal**: Assessment BYOK uses user Azure subscription key + region directly (no Enjoy token).

**Independent Test**: Assessment BYOK → playground echo assess returns scores (QS-4, SC-004).

### Tests for User Story 4

- [X] T037 [P] [US4] Add unit tests for `ByokAssessmentAzureCapability` with mocked `AzureSpeech` in `test/features/ai/data/byok/byok_assessment_azure_capability_test.dart`

### Implementation for User Story 4

- [X] T038 [P] [US4] Extend `packages/azure_speech` to accept subscription key auth (or key OR token) for assessment in `packages/azure_speech/lib/` and native platform code
- [X] T039 [US4] Implement `ByokAssessmentAzureCapability` in `lib/features/ai/data/byok/byok_assessment_azure_capability.dart` reusing WAV normalization from `lib/features/ai/data/enjoy/enjoy_assessment_capability.dart`
- [X] T040 [US4] Wire `resolveAssessmentCapability` BYOK branch in `lib/features/ai/application/ai_capability_providers.dart`
- [X] T041 [US4] Build assessment `SpeechByokForm` (Azure key + region only) in `lib/features/ai/presentation/settings/widgets/speech_byok_form.dart`
- [X] T042 [US4] Connect assessment modality card on `AiProvidersScreen` in `lib/features/ai/presentation/settings/ai_providers_screen.dart`
- [X] T043 [P] [US4] Add assessment BYOK ARB keys in `lib/l10n/app_en.arb` and `lib/l10n/app_zh.arb`

**Checkpoint**: Shadow reading / playground assessment works on BYOK Azure path; Enjoy assessment path unchanged when Enjoy selected.

---

## Phase 6: User Story 3 — Configure BYOK for speech recognition (Priority: P2)

**Goal**: ASR BYOK via OpenAI Whisper-compatible or Azure Speech subscription.

**Independent Test**: Azure or OpenAI ASR BYOK → playground transcribe succeeds (QS-5, SC-008).

### Tests for User Story 3

- [X] T044 [P] [US3] Add unit tests for `ByokAsrOpenAiCapability` in `test/features/ai/data/byok/byok_asr_openai_capability_test.dart`
- [X] T045 [P] [US3] Add unit tests for `ByokAsrAzureCapability` in `test/features/ai/data/byok/byok_asr_azure_capability_test.dart`

### Implementation for User Story 3

- [X] T046 [P] [US3] Extend `packages/azure_speech` with recognize-once transcription API using subscription key in `packages/azure_speech/lib/`
- [X] T047 [P] [US3] Implement `ByokAsrOpenAiCapability` (Whisper multipart) in `lib/features/ai/data/byok/byok_asr_openai_capability.dart`
- [X] T048 [US3] Implement `ByokAsrAzureCapability` in `lib/features/ai/data/byok/byok_asr_azure_capability.dart`
- [X] T049 [US3] Wire `resolveAsrCapability` BYOK branches in `lib/features/ai/application/ai_capability_providers.dart`
- [X] T050 [US3] Extend `SpeechByokForm` for ASR (OpenAI-compatible vs Azure) in `lib/features/ai/presentation/settings/widgets/speech_byok_form.dart`
- [X] T051 [US3] Connect ASR modality card on `AiProvidersScreen` in `lib/features/ai/presentation/settings/ai_providers_screen.dart`
- [X] T052 [P] [US3] Add ASR BYOK ARB keys in `lib/l10n/app_en.arb` and `lib/l10n/app_zh.arb`

**Checkpoint**: Playground ASR exercises both BYOK paths independently of LLM/assessment settings.

---

## Phase 7: User Story 6 — Manage and remove BYOK credentials (Priority: P2)

**Goal**: Edit keys, partial BYOK across modalities, remove BYOK reverts to Enjoy and deletes secrets.

**Independent Test**: BYOK assessment only → translation still Enjoy; Remove LLM BYOK deletes secret (QS-6).

### Tests for User Story 6

- [X] T053 [P] [US6] Add repository tests for `removeByok` and key rotation in `test/features/ai/data/ai_modality_config_repository_test.dart`
- [X] T054 [P] [US6] Add widget test for Remove BYOK confirm dialog in `test/features/ai/presentation/settings/modality_provider_card_test.dart`

### Implementation for User Story 6

- [X] T055 [US6] Implement masked API key display and edit-mode toggle in `lib/features/ai/presentation/settings/widgets/modality_provider_card.dart`
- [X] T056 [US6] Implement Remove BYOK confirm + `AiModalityConfigRepository.removeByok` for all four modalities in `lib/features/ai/application/ai_modality_config_controller.dart`
- [X] T057 [US6] Surface `ByokNotConfiguredFailure` with settings deep-link when BYOK selected but secret missing in `lib/features/ai/application/` error mapping
- [X] T058 [US6] Verify independent modality configs (LLM BYOK + assessment Enjoy) via integration-style test in `test/features/ai/application/ai_modality_config_controller_test.dart`

**Checkpoint**: Credential lifecycle complete for all modalities configured so far.

---

## Phase 8: User Story 5 — Configure BYOK for text-to-speech (Priority: P3)

**Goal**: TTS BYOK ready for OpenAI-compatible and Azure when TTS surfaces invoke it.

**Independent Test**: Playground TTS BYOK produces audio (QS-2 pattern for TTS in `specs/003-byok-ai/quickstart.md`).

### Tests for User Story 5

- [X] T059 [P] [US5] Add unit tests for TTS BYOK capabilities in `test/features/ai/data/byok/byok_tts_openai_capability_test.dart` and `byok_tts_azure_capability_test.dart`

### Implementation for User Story 5

- [X] T060 [P] [US5] Implement `ByokTtsOpenAiCapability` in `lib/features/ai/data/byok/byok_tts_openai_capability.dart`
- [X] T061 [US5] Implement `ByokTtsAzureCapability` in `lib/features/ai/data/byok/byok_tts_azure_capability.dart`
- [X] T062 [US5] Wire `resolveTtsCapability` BYOK branches in `lib/features/ai/application/ai_capability_providers.dart`
- [X] T063 [US5] Connect TTS modality card on `AiProvidersScreen` using `SpeechByokForm` in `lib/features/ai/presentation/settings/ai_providers_screen.dart`
- [X] T064 [P] [US5] Add TTS BYOK ARB keys in `lib/l10n/app_en.arb` and `lib/l10n/app_zh.arb`

**Checkpoint**: All four modality cards complete; TTS BYOK wired even if Enjoy TTS path still throws.

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Docs, ADR, playground visibility, verification, cleanup.

- [X] T065 [P] Update BYOK section in `docs/features/ai.md`
- [X] T066 [P] Add ADR `docs/decisions/0033-byok-ai-provider-settings.md` and index entry in `docs/decisions/README.md`
- [X] T067 Show active provider label per modality on `lib/features/ai/presentation/ai_playground_screen.dart`
- [X] T068 Remove dead `Unimplemented*Capability` usages from production paths in `lib/features/ai/data/stub_ai_capabilities.dart` (keep stubs only for `AIProvider.local` guard if needed)
- [X] T069 Audit logging: ensure no API keys in log output under `lib/features/ai/data/byok/`
- [X] T070 Run manual quickstart scenarios QS-1 through QS-8 in `specs/003-byok-ai/quickstart.md`
- [X] T071 Run `flutter gen-l10n`
- [X] T072 Run `dart run build_runner build`
- [X] T073 Run `flutter analyze`
- [X] T074 Run `flutter test`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Setup — **blocks all user stories**
- **US1 (Phase 3)**: Depends on Foundational — **MVP checkpoint**
- **US2 (Phase 4)**: Depends on Foundational; independent of US3/US4/US5
- **US4 (Phase 5)**: Depends on Foundational + `azure_speech` extension (T038); parallel with US2 after T038 base plugin work
- **US3 (Phase 6)**: Depends on T046 (`azure_speech` transcribe); can parallel US4 after plugin extended
- **US6 (Phase 7)**: Depends on at least one BYOK modality UI (US2 or US4)
- **US5 (Phase 8)**: Depends on Foundational; benefits from US6 credential patterns
- **Polish (Phase 9)**: Depends on desired user stories complete

### User Story Dependencies

| Story | Depends on | Independent test |
|-------|------------|------------------|
| US1 | Phase 2 | Default Enjoy AI unchanged |
| US2 | Phase 2 | DeepSeek LLM translation |
| US4 | Phase 2, azure_speech | Azure assessment BYOK |
| US3 | Phase 2, azure_speech ASR | ASR transcribe BYOK |
| US6 | US2 or US4 UI | Partial BYOK + remove |
| US5 | Phase 2 | TTS BYOK synthesis |

### Parallel Opportunities

**After Phase 2 completes:**

- US2 (LLM) and US4 (assessment plugin T038) can start in parallel
- US3 waits on `azure_speech` transcribe (T046) — can share plugin PR with T038
- US5 can start after US2 patterns exist but does not block US4/US3

**Within Phase 2:** T004–T006 tests parallel; T007–T009 domain models parallel; T011–T014 parallel before T015–T017 sequential.

**Within US2:** T026–T027 tests parallel; T029–T030 parallel before T031–T035.

---

## Parallel Example: User Story 2

```bash
# Tests in parallel:
T026: test/features/ai/data/byok/byok_llm_capability_test.dart
T027: test/features/ai/presentation/settings/llm_byok_form_test.dart

# Implementation in parallel (after spike T028):
T029: lib/features/ai/data/byok/byok_llm_capability.dart
T030: lib/features/ai/presentation/settings/llm_presets.dart
T036: lib/l10n/app_en.arb + app_zh.arb
```

---

## Parallel Example: User Story 4 + User Story 3 (plugin)

```bash
# Shared plugin work first:
T038: packages/azure_speech assessment subscription-key auth
T046: packages/azure_speech ASR transcribe API

# Then parallel capabilities:
T039: byok_assessment_azure_capability.dart
T048: byok_asr_azure_capability.dart
```

---

## Implementation Strategy

### MVP First (User Story 1 only)

1. Complete Phase 1–2 (Setup + Foundational)
2. Complete Phase 3 (US1) — settings shell, all Enjoy defaults, regression tests
3. **STOP and VALIDATE** QS-1 — ship-safe incremental release with no BYOK vendor calls yet

### Recommended delivery order (P1 features)

1. Foundation + **US1** (MVP regression safety)
2. **US2** LLM BYOK (highest user value)
3. **US4** Assessment BYOK (echo mode differentiator)
4. **US6** Credential management hardening
5. **US3** ASR BYOK
6. **US5** TTS BYOK
7. Polish

### Incremental validation

Each checkpoint in quickstart (`specs/003-byok-ai/quickstart.md`) should pass before merging the corresponding phase.

---

## Notes

- Do not expose `AIProvider.local` in any UI task
- Never commit real API keys; use env/local test keys for manual QS scenarios only
- `ai_sdk_dart` spike (T028) is a gate: if fail, swap T029 implementation to `openai_dart` + HTTP adapters per research.md fallback
- All BYOK vendor HTTP calls are direct — do not route through Enjoy worker `/byok-proxy`
