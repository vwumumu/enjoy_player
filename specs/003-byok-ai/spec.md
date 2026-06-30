# Feature Specification: BYOK AI Provider Settings

**Feature Branch**: `003-byok-ai`

**Created**: 2026-06-30

**Status**: Draft

**Input**: User description: "Let's bring BYOK feature. User could use Enjoy AI API as default, but they could provide their own keys to use their own subscription too. For the pronunciation assessment, we need user to bring the azure subscription key. Just ref the Enjoy project — we mostly port from it. But Enjoy Player does not support native AI for now. Just BYOK or Enjoy AI."

## Scope

### In scope

- Per-modality AI provider selection: **Enjoy AI** (default) or **BYOK** (user-supplied credentials).
- Settings UI to configure, validate, save, update, and remove BYOK credentials per AI capability.
- BYOK implementations for all cloud-backed modalities already wired on the Enjoy path: speech recognition, text generation (chat / translation / dictionary / contextual translation), text-to-speech, and pronunciation assessment.
- **Pronunciation assessment BYOK** requires the user's **Azure Speech subscription key and region** (Azure-only vendor for this modality).
- Secure local persistence of BYOK settings on device.
- Clear user-facing errors when BYOK is selected but misconfigured, or when a vendor call fails.
- Parity with Enjoy **`packages/ai` capability routing** for backend behavior; LLM settings UI uses an **API-spec model** (OpenAI-compatible as primary) so providers like DeepSeek work without a dedicated vendor entry for each brand.

### Out of scope

- **Local / on-device AI** (`AIProvider.local`) — not supported in Enjoy Player; settings MUST NOT expose a local provider option.
- Cloud sync of BYOK keys across devices (keys stay on the device where configured unless a future ADR adds encrypted sync).
- Changes to Enjoy worker pricing, credits, or Pro subscription logic (see `002-pro-upgrade`).
- New AI modalities beyond those already defined in the player AI layer.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Keep Enjoy AI as the default (Priority: P1)

A signed-in learner uses translation, dictionary, speech recognition, and other AI features without changing settings. All requests continue to route through Enjoy AI using their account credits and existing worker integration.

**Why this priority**: Existing users must not regress; BYOK is opt-in.

**Independent Test**: Fresh install or reset AI settings, invoke any AI feature (e.g., dictionary lookup), and confirm it succeeds via Enjoy AI with no BYOK configuration required.

**Acceptance Scenarios**:

1. **Given** a user who has never opened AI provider settings, **When** they use dictionary lookup or translation, **Then** the request uses Enjoy AI and behaves as today.
2. **Given** default settings, **When** the user opens AI provider settings, **Then** every modality shows **Enjoy AI** as the active provider.
3. **Given** a Free or Pro user on Enjoy AI, **When** credits are exhausted (402-style failure), **Then** the user sees the existing credits guidance without BYOK being forced automatically.

---

### User Story 2 - Configure BYOK for LLM-backed features (Priority: P1)

A learner who prefers their own LLM subscription opens AI settings, selects BYOK for LLM-backed services (chat, translation, dictionary, contextual translation), picks an **API spec** (see below), enters credentials, saves, and subsequent LLM-backed requests use their subscription instead of Enjoy credits.

**LLM BYOK UI model (API protocol specs — all equally customizable)**:

Each spec defines the **request protocol** the app speaks. Every spec exposes the **same editable connection fields**; there is no separate “Custom” spec or one-off escape hatch.

| API spec | Protocol | Required fields (all editable) | Typical use |
|----------|----------|--------------------------------|-------------|
| **OpenAI-compatible** | Chat Completions (`/v1/chat/completions` or equivalent on your base URL) | **Base URL**, **API key**, **model** | OpenAI, DeepSeek, Groq, OpenRouter, Azure OpenAI, self-hosted gateways |
| **Anthropic-compatible** | Messages API (`/v1/messages` or equivalent on your base URL) | **Base URL**, **API key**, **model** | Claude, Anthropic proxies, compatible gateways |
| **Google-compatible** | Gemini generateContent (base URL + model path) | **Base URL**, **API key**, **model** | Gemini, Vertex-style proxies, compatible gateways |

**Customization rules**:

- **Base URL is required and editable for every spec** — defaults may appear as placeholders (e.g. `https://api.openai.com/v1`) but the user can point at any HTTPS-compatible endpoint for that protocol.
- **Optional presets** (OpenAI, DeepSeek, Claude, Gemini, …) only pre-fill base URL and model suggestions; they do not lock fields or introduce a special “Custom” type.
- Switching spec changes the client protocol; switching base URL within a spec changes where requests are sent — both are first-class.

**Why this priority**: Power users run proxies, regional endpoints, and alternate hosts (DeepSeek, corporate gateways, etc.). Treating only OpenAI-compatible as fully configurable while hardcoding Anthropic/Google URLs would block valid BYOK setups.

**Independent Test**: Configure Anthropic-compatible BYOK with a non-default base URL and model, run translation, confirm Enjoy credits are not consumed.

**Acceptance Scenarios**:

1. **Given** LLM BYOK is enabled, **When** the user picks any API spec, **Then** they always see **base URL**, **API key**, and **model** — same field set for OpenAI-, Anthropic-, and Google-compatible.
2. **Given** OpenAI-compatible spec, **When** the user selects a DeepSeek preset, **Then** base URL and model are pre-filled but remain fully editable before save.
3. **Given** Anthropic-compatible spec, **When** the user changes base URL to a proxy or alternate host, **Then** save succeeds (HTTPS + URL guard) and LLM calls use that URL with the Anthropic Messages protocol.
4. **Given** Google-compatible spec, **When** the user enters a non-default base URL and model, **Then** save succeeds and LLM calls use the Gemini-compatible protocol against that endpoint.
5. **Given** valid config for any spec, **When** the user runs chat or translation, **Then** results come from their endpoint and Enjoy AI credits are not charged.
6. **Given** incomplete config (missing base URL, API key, or model), **When** the user saves, **Then** validation blocks save with field-level messages.
7. **Given** an invalid base URL (non-HTTPS or disallowed host), **When** the user saves any spec, **Then** validation rejects it.
8. **Given** OpenAI-compatible config where the endpoint supports `GET /v1/models`, **When** the user taps Fetch models, **Then** they can pick from a list; otherwise they enter the model manually (other specs may offer fetch only when the endpoint supports an equivalent listing).
9. **Given** BYOK LLM is active, **When** the user switches back to Enjoy AI, **Then** subsequent requests use Enjoy AI; stored BYOK credentials may remain inactive.

---

### User Story 3 - Configure BYOK for speech recognition (Priority: P2)

A learner configures BYOK for speech recognition using either an **OpenAI Whisper-compatible key** (optional custom HTTPS endpoint) or an **Azure Speech subscription key + region**, and uses that path for ASR in the AI playground or future echo flows.

**Why this priority**: ASR BYOK supports two vendor paths on Enjoy (`byok.ts` for OpenAI Whisper, `byok-azure.ts` for Azure Speech SDK); Azure is especially useful for learners who already bring Azure keys for pronunciation assessment.

**Independent Test**: Set ASR to BYOK with a valid Azure key + region (or OpenAI key), transcribe audio in the AI playground, and verify transcription succeeds without Enjoy ASR credits.

**Acceptance Scenarios**:

1. **Given** the ASR settings card, **When** the user selects BYOK, **Then** **OpenAI** (optional custom HTTPS endpoint) and **Azure** (subscription key + required region) are offered as vendor choices.
2. **Given** valid OpenAI BYOK ASR config, **When** the user transcribes audio, **Then** transcription completes using the user's OpenAI Whisper subscription.
3. **Given** valid Azure BYOK ASR config (key + region), **When** the user transcribes audio, **Then** transcription completes using the user's Azure Speech subscription via native speech recognition (not Enjoy worker routing).
4. **Given** ASR BYOK with an invalid or revoked key, **When** transcription is attempted, **Then** the user sees a vendor-specific error message and can open settings to fix credentials.
5. **Given** Azure ASR BYOK, **When** audio is not in a compatible format, **Then** the system normalizes or rejects with the same guidance as other Azure speech flows (16 kHz mono PCM WAV convention).

---

### User Story 4 - Configure Azure BYOK for pronunciation assessment (Priority: P1)

A learner practicing shadow reading wants pronunciation scoring without spending Enjoy credits. They open assessment settings, select BYOK, enter their **Azure Speech subscription key** and **region**, save, and run pronunciation assessment on a recording using their Azure subscription directly.

**Why this priority**: User explicitly requires Azure subscription key for assessment BYOK; assessment is a core learning differentiator in echo mode.

**Independent Test**: Configure assessment BYOK with valid Azure key + region, assess a WAV recording with reference text in the AI playground or echo flow, and confirm scores return without requesting an Enjoy Azure token.

**Acceptance Scenarios**:

1. **Given** the assessment settings card, **When** the user selects BYOK, **Then** only Azure is offered and both subscription key and region are required before save.
2. **Given** valid Azure BYOK assessment config, **When** the user assesses a recording with reference text, **Then** pronunciation scores and word-level feedback are returned using the user's Azure subscription.
3. **Given** assessment on Enjoy AI, **When** the user has not configured BYOK, **Then** assessment continues to use Enjoy-mediated Azure access (existing behavior) and consumes Enjoy credits where applicable.
4. **Given** Azure BYOK with wrong region or key, **When** assessment runs, **Then** the user sees a clear failure message distinguishing configuration errors from audio/reference mismatches.
5. **Given** assessment BYOK is active, **When** the user removes BYOK credentials, **Then** assessment falls back to Enjoy AI on the next run (or prompts to reconfigure if Enjoy path is unavailable).

---

### User Story 5 - Configure BYOK for text-to-speech (Priority: P3)

A learner configures BYOK TTS with OpenAI or Azure (Azure requires region), saves, and hears synthesized speech from their vendor subscription when TTS is invoked.

**Why this priority**: TTS BYOK completes parity with Enjoy web; TTS on the Enjoy path may still be limited in the player, but BYOK should be ready when TTS surfaces ship.

**Independent Test**: Configure TTS BYOK, trigger TTS in the AI playground, and confirm audio is produced via the chosen vendor.

**Acceptance Scenarios**:

1. **Given** the TTS settings card, **When** the user selects BYOK, **Then** OpenAI and Azure are the only vendor options; Azure requires region.
2. **Given** valid TTS BYOK config, **When** synthesis is requested, **Then** audio is returned from the configured vendor.
3. **Given** TTS BYOK misconfiguration, **When** synthesis is requested, **Then** the user receives an actionable error and no silent fallback to Enjoy without explicit provider selection.

---

### User Story 6 - Manage and remove BYOK credentials (Priority: P2)

A learner updates an expired API key, edits vendor or model, or removes BYOK entirely for one modality while leaving others unchanged.

**Why this priority**: Credential rotation and partial BYOK (e.g., assessment only) are common real-world patterns.

**Independent Test**: Configure BYOK for two modalities, remove one, change the key on the other, and verify routing respects per-modality settings independently.

**Acceptance Scenarios**:

1. **Given** saved BYOK config, **When** the user edits and replaces the API key, **Then** the new key is persisted and masked in the UI; the old key is no longer used.
2. **Given** BYOK on assessment only, **When** the user uses translation, **Then** translation still uses Enjoy AI unless separately configured for BYOK.
3. **Given** saved BYOK config, **When** the user taps Remove BYOK, **Then** the modality reverts to Enjoy AI and stored secrets for that modality are deleted from device storage.

---

### Edge Cases

- User selects BYOK but has not saved valid credentials → feature surfaces that need that modality show a prompt to complete setup instead of failing opaquely.
- User switches provider while a long-running AI request is in flight → in-flight request completes on the provider selected at start; new requests use the updated provider.
- Invalid or expired API key → user-friendly error; no secret values echoed in logs or error text.
- Assessment audio format incompatible with Azure → same normalization and user guidance as the existing Enjoy assessment path (reference text mismatch, silent audio warnings).
- Offline use → BYOK calls that require network show a clear offline message; Enjoy AI similarly requires network.
- Platform differences (Android, iOS, macOS, Windows) → settings layout follows existing settings patterns; secure storage uses platform-appropriate protected storage.
- User on Free tier with BYOK → BYOK bypasses Enjoy credits for configured modalities; Enjoy AI remains subject to existing tier limits.
- User configures DeepSeek, a corporate proxy, or an alternate regional host → edits base URL on the matching spec; no app update and no special “Custom” type required.
- User switches from OpenAI-compatible to Anthropic-compatible → base URL and model must be re-entered or validated for the new protocol; presets may suggest defaults per spec.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST default every AI modality to **Enjoy AI** when no user override exists.
- **FR-002**: System MUST allow users to set provider to **BYOK** independently for each modality: speech recognition, text-to-speech, LLM (shared by chat / translation / dictionary / contextual translation), and pronunciation assessment.
- **FR-003**: System MUST NOT expose **local / on-device AI** as a selectable provider anywhere in the app.
- **FR-004**: System MUST persist BYOK settings locally on device and reload them on app restart.
- **FR-005**: System MUST store API keys and subscription secrets using platform-protected secure storage, not plain-text preferences or logs.
- **FR-006**: System MUST mask stored secrets in the UI (show partial prefix/suffix only) and never display full keys after initial entry unless the user explicitly chooses to edit.
- **FR-007**: System MUST validate BYOK configuration before save using modality-specific rules:
  - **LLM** — user selects an **API protocol spec**. **Every spec uses the same required fields: base URL, API key, and model** (all editable):
    - **OpenAI-compatible** — Chat Completions protocol against user-supplied base URL.
    - **Anthropic-compatible** — Messages API protocol against user-supplied base URL.
    - **Google-compatible** — Gemini generateContent protocol against user-supplied base URL.
  - ASR: **OpenAI-compatible (Whisper)** or **Azure Speech**; API key required; **base URL required** for OpenAI-compatible; **region required for Azure**.
  - TTS: OpenAI-compatible or Azure Speech; API key required; **base URL required** for OpenAI-compatible; region required for Azure.
  - Assessment: **Azure Speech only**; subscription key and region required.
- **FR-017**: LLM BYOK settings MUST use **protocol spec types** (OpenAI-compatible, Anthropic-compatible, Google-compatible). **Each spec MUST expose the same customizable connection fields** — there MUST NOT be a single catch-all “Custom” spec type.
- **FR-018**: Optional **presets** MAY pre-fill base URL and model per spec (e.g. OpenAI, DeepSeek, Claude, Gemini); presets MUST NOT lock fields or replace user-entered values without explicit user action.
- **FR-019**: Persisted LLM BYOK config MUST always include **apiSpec + baseUrl + apiKey + model** (+ optional preset id for UX only).
- **FR-008**: System MUST reject non-HTTPS custom endpoints and disallowed host patterns (localhost, private IP ranges) at validation time.
- **FR-009**: When BYOK is active for a modality, system MUST route requests for that modality to the configured vendor using the user's credentials, not Enjoy AI worker routes (except where Enjoy web uses a authenticated proxy for vendor calls — native app MAY call vendors directly when secure and equivalent).
- **FR-010**: When Enjoy AI is active, system MUST preserve existing behavior and credit consumption rules unchanged.
- **FR-011**: System MUST surface distinct, localized error messages for BYOK misconfiguration, vendor auth failure, vendor quota/rate limits, and network failures.
- **FR-012**: System MUST allow users to remove BYOK configuration per modality and revert that modality to Enjoy AI.
- **FR-013**: Azure BYOK paths (ASR, TTS, assessment) MUST use the user's Azure Speech subscription key and region directly (no Enjoy Azure token exchange for BYOK).
- **FR-016**: OpenAI ASR BYOK MUST support Whisper-style transcription with optional custom HTTPS endpoint (same semantics as Enjoy `createBYOKASRProvider`).
- **FR-014**: AI feature entry points (playground, echo assessment, transcript dictionary, etc.) MUST resolve the active provider through the existing modality config layer — widgets MUST NOT bypass provider resolution.
- **FR-015**: Settings MUST expose AI provider configuration in the user-facing Settings area (not developer-only), aligned with Enjoy web's per-capability cards pattern.

### Quality, UX, and Performance Requirements

- **QR-001**: Implementation MUST preserve Enjoy Player's feature-first architecture and avoid feature-to-feature shortcuts unless the plan documents an exception.
- **QR-002**: Changed behavior MUST have automated tests or a documented manual verification reason.
- **QR-003**: User-facing strings, controls, haptics, tooltips, and keyboard affordances MUST follow existing localization and shared UI patterns (`EnjoyTappableSurface`, tooltips on icon actions, ARB strings).
- **QR-004**: Provider resolution and settings reads MUST not add perceptible delay to AI feature launches; target under 100 ms for reading cached modality config on cold feature open.
- **QR-005**: Feature behavior changes MUST update the matching documentation under `docs/features/ai.md` and add an ADR if secure-storage or provider-routing decisions are costly to reverse.

### Key Entities *(include if feature involves data)*

- **AI modality**: One of speech recognition, text-to-speech, LLM, or pronunciation assessment; each maps to an underlying capability and one or more user-facing services.
- **Provider selection**: Either Enjoy AI or BYOK for a given modality; translation, dictionary, and contextual translation inherit LLM provider selection.
- **BYOK credential bundle**: API protocol spec, **base URL** (LLM and OpenAI-compatible speech paths), API key, model, optional preset id (UX only), optional region (Azure speech modalities).
- **Modality configuration set**: The collection of per-modality provider selections and optional BYOK bundles persisted for the user on device.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of existing Enjoy AI users see no change in default behavior until they opt into BYOK (verified by regression tests on default modality configs).
- **SC-002**: A user can configure BYOK for any supported modality and complete a successful test action in under 3 minutes (open settings → enter key → save → run feature).
- **SC-003**: 95% of BYOK validation errors are resolved by the user without support contact (measured by clear field-level messages covering required key, region, vendor, and endpoint rules).
- **SC-004**: Pronunciation assessment with valid Azure BYOK returns scores on the first attempt for a well-formed recording and matching reference text, matching Enjoy/Azure parity expectations.
- **SC-008**: Azure ASR BYOK transcribes a well-formed sample recording on the first attempt with valid key, region, and language selection.
- **SC-005**: Zero occurrences of full API keys in application logs, crash reports, or on-screen error messages during QA pass across all four platforms.
- **SC-006**: Switching a modality from BYOK back to Enjoy AI takes effect on the next user-initiated AI action without app restart.
- **SC-007**: All new settings strings and error messages are localized in English and Chinese ARB files consistent with existing settings screens.
- **SC-009**: A user can configure **DeepSeek** (or any OpenAI-compatible preset) for LLM BYOK and complete a successful translation in under 3 minutes without developer assistance.

## Assumptions

- BYOK vendor allow-lists follow Enjoy **`packages/ai` capability routing** (source of truth). ASR includes **Azure** per `createBYOKAzureASRProvider` even though Enjoy web settings validation currently lists OpenAI only — player settings MUST expose both vendors.
- Enjoy Player calls third-party vendor APIs directly from the native app where feasible; the Enjoy worker BYOK proxy exists primarily for browser CORS and is not required for Flutter native clients.
- LLM BYOK backend uses **`ai_sdk_dart`** (see [research.md](research.md)); **UI uses API-spec forms**, not Enjoy web's vendor-only dropdown alone.
- **LLM settings UI** uses **protocol spec types** (OpenAI-compatible, Anthropic-compatible, Google-compatible). **All specs share the same customizable fields** (base URL, API key, model). Presets are optional shortcuts, not a separate “Custom” type.
- OpenAI-compatible covers DeepSeek, Groq, Azure OpenAI, etc.; Anthropic-compatible and Google-compatible also support non-vendor-default base URLs (proxies, regional hosts).
- ASR/TTS OpenAI paths use the same **OpenAI-compatible** field pattern where applicable (Whisper/TTS endpoints).
- ASR OpenAI BYOK ports `createBYOKASRProvider`; ASR Azure BYOK ports `createBYOKAzureASRProvider` and may extend `packages/azure_speech` beyond pronunciation assessment.
- TTS and assessment Azure BYOK port respective `byok-azure` capabilities.
- Secure storage uses OS keychain/keystore equivalents already available or introduced in the data layer (e.g., `flutter_secure_storage` or platform channel) — exact mechanism deferred to planning.
- Per-modality configuration matches Enjoy web: a user may use Enjoy AI for translation and Azure BYOK for assessment simultaneously.
- Local AI remains explicitly unsupported; any existing `AIProvider.local` enum value stays unreachable from UI and throws if programmatically set.
- Credits and Pro tier rules from `002-pro-upgrade` apply only to Enjoy AI usage, not BYOK vendor billing.
- Cloud sync of BYOK settings is out of scope; users re-enter keys on new devices.

## Dependencies

- Existing AI capability layer (`lib/features/ai/`) and Enjoy implementations (ADR-0014).
- Enjoy web BYOK UX as reference for per-modality cards; **LLM form diverges** to API-spec layout (OpenAI-compatible primary).
- Native Azure Speech integration for assessment and Azure ASR BYOK (`packages/azure_speech`, may need transcription API extension).
- LLM BYOK library selection — see [research.md](research.md).
- Settings navigation shell and localization infrastructure.
- Optional: Pro/credits UI for contextual messaging when users switch between Enjoy AI and BYOK.

## Reference (Enjoy monorepo)

| Area | Enjoy reference |
|------|-----------------|
| BYOK types & vendors | `packages/ai/src/types/core.ts` |
| Validation rules | `apps/web/.../byok-validation.ts` |
| Settings UI pattern | `apps/web/.../byok-config.tsx` |
| LLM BYOK | `packages/ai/src/capabilities/llm/byok.ts`, `clients/byok/client.ts` (Vercel AI SDK) |
| ASR BYOK (OpenAI) | `packages/ai/src/capabilities/asr/byok.ts` |
| ASR BYOK (Azure) | `packages/ai/src/capabilities/asr/byok-azure.ts`, `capabilities/asr/index.ts` |
| TTS / assessment BYOK (Azure) | `packages/ai/src/capabilities/*/byok-azure.ts` |
| Player stubs to replace | `lib/features/ai/data/stub_ai_capabilities.dart` |
