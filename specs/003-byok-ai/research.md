# Research: BYOK AI Provider Settings

**Feature**: `003-byok-ai` | **Date**: 2026-06-30

## 1. Enjoy monorepo reference (porting source)

**Decision**: Port BYOK behavior from `enjoy/packages/ai`, not only the web settings UI.

**Rationale**: Enjoy web settings validation (`byok-validation.ts`) currently restricts ASR BYOK to OpenAI, but the **`@enjoy/ai` capability layer already routes Azure ASR BYOK** when `byok.provider === 'azure'`:

```typescript
// packages/ai/src/capabilities/asr/index.ts
if (mergedConfig.byok.provider === BYOKProvider.AZURE) {
  return createBYOKAzureASRProvider({ subscriptionKey, region })
}
return createBYOKASRProvider(mergedConfig.byok) // OpenAI Whisper
```

Enjoy Player should follow **capability routing** as source of truth and expose Azure for ASR in settings (product request).

| Modality | BYOK vendors (Enjoy `packages/ai`) | Required fields |
|----------|-----------------------------------|-----------------|
| LLM | OpenAI, Google, Claude, Azure OpenAI, custom endpoint | apiKey; endpoint for Azure/custom; model optional |
| ASR | OpenAI (Whisper) **or Azure Speech** | apiKey; region for Azure; endpoint optional for OpenAI |
| TTS | OpenAI **or Azure Speech** | apiKey; region for Azure |
| Assessment | Azure Speech only | apiKey + region |

**Enjoy web LLM stack**: Vercel AI SDK (`generateText`) + provider packages (`@ai-sdk/openai`, `@ai-sdk/anthropic`, `@ai-sdk/google`) + OpenAI SDK for audio. See `packages/ai/src/clients/byok/client.ts`.

---

## 2. LLM BYOK library options (Dart / Flutter)

Goal: implement `LlmCapability.generateText` / `generateChatCompletion` against user-supplied keys for **OpenAI, Anthropic (Claude), Google (Gemini), Azure OpenAI** — matching Enjoy BYOK matrix. No local/on-device models.

### Option A — `ai_sdk_dart` family (recommended)

| Package | Version (pub.dev) | Role |
|---------|-------------------|------|
| `ai_sdk_dart` | 1.1.0 | Core `generateText`, provider registry |
| `ai_sdk_openai` | 1.1.0 | OpenAI + custom base URL |
| `ai_sdk_anthropic` | 1.1.0 | Claude |
| `ai_sdk_google` | 1.1.0 | Gemini |
| `ai_sdk_azure` | 1.1.0 | Azure OpenAI (endpoint + apiKey) |

**Pros**

- **Direct architectural parity** with Enjoy web (`generateText` + per-vendor provider factories).
- Same vendor matrix and config shape (apiKey, endpoint, model, region).
- Modular — add only needed provider packages.
- Native app can call vendor HTTPS directly (no CORS proxy unlike browser).

**Cons**

- **Low pub.dev traction** (~76–283 weekly downloads, 0 likes on core packages as of 2026-06).
- Smaller community than LangChain.dart or `openai_dart`.
- Needs a short implementation spike before committing (verify chat completions + temperature/maxTokens map cleanly to `LlmCapability`).

**Fit for Enjoy Player**: **Best** — thinnest port of existing Enjoy BYOK client logic into Dart.

---

### Option B — `ai_clients_dart` per-provider packages (fallback)

| Package | Downloads | Vendors |
|---------|-----------|---------|
| `openai_dart` | ~26k/wk | OpenAI (+ Azure via custom base URL) |
| `google_generative_ai_dart` / langchain partners | varies | Google |
| Anthropic via `langchain_anthropic` or dedicated client | varies | Claude |

**Pros**

- Battle-tested HTTP clients (`openai_dart` from David Miguel, 160 pub points).
- Fine-grained control; only pull what you use.

**Cons**

- **No single unified interface** — need a custom `ByokLlmCapability` adapter with switch on `BYOKVendor`.
- More glue code for message format, error mapping, and streaming (if added later).
- Duplicates work Enjoy web already centralizes in Vercel AI SDK.

**Fit**: **Good fallback** if `ai_sdk_dart` spike fails quality or API gaps.

---

### Option C — LangChain.dart (`langchain` + `langchain_openai` + …)

**Pros**

- Mature ecosystem (300+ likes on core `langchain`).
- Documented multi-provider patterns at [langchaindart.dev](https://langchaindart.dev).

**Cons**

- **Heavyweight** for current scope (chat, translation, dictionary — no RAG/agents/tool loops in BYOK v1).
- Abstraction mismatch with Enjoy's thin capability interfaces.
- Extra concepts (chains, prompts, runnables) unrelated to BYOK settings feature.

**Fit**: **Not recommended** for BYOK v1 unless future agentic features justify the dependency.

---

### Option D — `llm_dart`, `llm_sdk`, `genesis_ai_sdk`, `flutter_ai_toolkit`

| Package | Issue |
|---------|-------|
| `llm_dart` | Broad scope (Ollama, local); 90/160 pub points |
| `llm_sdk` | Very early (302 downloads) |
| `genesis_ai_sdk` | On-device / Ollama routing — out of scope |
| `flutter_ai_toolkit` | Agent/RAG/UI stack — overkill |

**Fit**: **Not recommended**.

---

### Option E — Roll our own on `http` package

**Pros**: Zero new dependencies; full control.

**Cons**: Reimplement OpenAI/Anthropic/Google/Azure request shapes, error parsing, and message roles — high maintenance vs porting Enjoy logic.

**Fit**: **Reject** unless all libraries fail spike.

---

## 3. LLM BYOK UI — protocol specs (all customizable)

**Decision**: LLM BYOK settings use **API protocol spec types**. **Every spec type is fully customizable** with the same connection fields. There is **no** single “Custom” catch-all spec.

**Rationale**:

- Users need to point **any** protocol at proxies, regional endpoints, or third-party gateways — not only OpenAI-shaped APIs.
- Hardcoding Anthropic to `api.anthropic.com` or Google to `generativelanguage.googleapis.com` blocks valid BYOK (corporate proxy, Vertex wrapper, LiteLLM, etc.).
- “Custom” as one spec type wrongly implies other specs are not customizable; customization is universal.

### Uniform fields (every LLM spec)

| Field | Required | Notes |
|-------|----------|-------|
| **API spec** | Yes | Protocol selector: OpenAI-compatible / Anthropic-compatible / Google-compatible |
| **Base URL** | Yes | HTTPS; user-editable for **all** specs |
| **API key** | Yes | Stored in secure storage |
| **Model** | Yes | Deployment / model id at that endpoint |
| **Preset** | No | Optional UX shortcut only; never locks fields |

### Spec → protocol → backend

| API spec | HTTP shape (on user base URL) | `ai_sdk_dart` client |
|----------|------------------------------|----------------------|
| **OpenAI-compatible** | `POST …/chat/completions` | `ai_sdk_openai` (`baseURL` = user base URL) |
| **Anthropic-compatible** | `POST …/messages` | `ai_sdk_anthropic` (custom `baseURL` when SDK supports it; else adapter in spike) |
| **Google-compatible** | Gemini `generateContent` | `ai_sdk_google` (custom base URL when SDK supports it; else adapter in spike) |

### Presets (optional, per spec — not a “Custom” type)

Presets only suggest defaults; user can clear or overwrite any value.

**OpenAI-compatible presets (examples)**:

| Preset | Suggested base URL | Suggested model |
|--------|-------------------|-----------------|
| OpenAI | `https://api.openai.com/v1` | `gpt-4o-mini` |
| DeepSeek | `https://api.deepseek.com/v1` | `deepseek-chat` |
| Groq | `https://api.groq.com/openai/v1` | `llama-3.3-70b-versatile` |
| Azure OpenAI | *(user pastes deployment URL)* | *(deployment name)* |

**Anthropic-compatible presets (examples)**:

| Preset | Suggested base URL | Suggested model |
|--------|-------------------|-----------------|
| Anthropic | `https://api.anthropic.com/v1` | `claude-sonnet-4-20250514` |

**Google-compatible presets (examples)**:

| Preset | Suggested base URL | Suggested model |
|--------|-------------------|-----------------|
| Google AI | `https://generativelanguage.googleapis.com/v1beta` | `gemini-2.0-flash` |

New providers ship as **new presets** or user-typed URLs — no new spec type unless the HTTP protocol differs.

### Model discovery

- **OpenAI-compatible**: `GET /v1/models` when supported.
- **Anthropic / Google**: fetch only if endpoint exposes a compatible listing; otherwise manual model field.

### Persisted shape (planning)

```text
llmByok: {
  apiSpec: openAiCompatible | anthropicCompatible | googleCompatible
  baseUrl: string          // always persisted
  apiKey: secure ref
  model: string
  presetId?: string        // UX only, not authoritative
}
```

**Spike note**: Confirm `ai_sdk_anthropic` and `ai_sdk_google` accept custom `baseURL`; if not, thin HTTP adapter still uses user `baseUrl` — UI requirement unchanged.

---

## 4. LLM library decision

**Decision (planning recommendation)**: **Primary — `ai_sdk_dart` + provider packages** (`ai_sdk_openai`, `ai_sdk_anthropic`, `ai_sdk_google`, `ai_sdk_azure`).

**Rationale**:

1. Enjoy web already uses the TypeScript Vercel AI SDK with the same vendor split.
2. BYOK LLM is a thin wrapper: map `BYOKConfig` → provider factory → `generateText(messages)` → `LlmCapability`.
3. Flutter native clients do not need Enjoy worker `/byok-proxy` (CORS workaround).

**Spike tasks** (for `/speckit-plan`):

1. Prove `generateChatCompletion` with system + user messages for OpenAI-compatible base URL (OpenAI + **DeepSeek**).
2. Prove Anthropic and Google native specs with `ai_sdk_anthropic` / `ai_sdk_google`.
3. Prove Azure OpenAI via OpenAI-compatible URL or `ai_sdk_azure`.
4. Map vendor HTTP errors to existing player failure types (no secret leakage).
5. If spike fails: fall back to **Option B** with `openai_dart` for OpenAI-compatible only + minimal HTTP for Anthropic/Google.

---

## 5. ASR BYOK implementation notes

| Vendor | Enjoy reference | Enjoy Player approach |
|--------|-----------------|----------------------|
| OpenAI | `createBYOKASRProvider` → OpenAI Whisper multipart | `openai_dart` audio API **or** `http` multipart (already have `postMultipartJson` pattern on worker client) |
| Azure | `createBYOKAzureASRProvider` → Speech SDK | Extend `packages/azure_speech` with **subscription-key transcription** (recognize-once), reusing WAV normalization from assessment path |

**Note**: `packages/azure_speech` today only exposes pronunciation assessment, not general ASR. Azure ASR BYOK likely requires a **plugin extension** (native SDK already linked for assessment).

---

## 6. Non-LLM BYOK (brief)

| Modality | Library / path |
|----------|----------------|
| TTS OpenAI | `openai_dart` or `dart_openai` speech API |
| TTS Azure | `packages/azure_speech` extension or native SDK |
| Assessment Azure | Existing `EnjoyAssessmentCapability` pattern with subscription key instead of Enjoy token |

No additional multi-vendor LLM library needed for these modalities.

---

## 7. Security & storage (unchanged from spec)

- `flutter_secure_storage` already in `pubspec.yaml` — use for BYOK secrets.
- Never log apiKey/subscriptionKey; mask in UI (Enjoy web pattern: first 4 + last 4 chars).

---

## Summary table

| Need | Recommended |
|------|-------------|
| LLM BYOK UI | **Protocol specs** (OpenAI / Anthropic / Google-compatible) — **all** with editable base URL + key + model |
| LLM BYOK backend | **`ai_sdk_dart` family** (spike first) |
| LLM fallback | Per-vendor `openai_dart` + thin adapters |
| ASR OpenAI BYOK | `openai_dart` or direct Whisper HTTP |
| ASR Azure BYOK | Extend `azure_speech` plugin |
| Assessment/TTS Azure BYOK | Existing Azure Speech plugin + subscription key auth |

---

## 8. Persistence & configuration loading (Phase 0 closure)

**Decision**: Split **Drift JSON** (non-secrets) + **`SecureTokenStore` extension** (per-modality API keys).

**Rationale**:

- Matches existing auth token pattern (`secure_token_store.dart`).
- Keeps Drift backups/exports free of secrets.
- Allows masked UI without storing key hints in SQLite.

**Drift key**: `SettingsKeys.aiModalityConfigsV1` = `'ai.modality_configs_v1'`.

**Secure keys**: `enjoy_player.byok.{llm|asr|tts|assessment}.api_key`.

**Configuration loading**:

- `@Riverpod` `AiModalityConfigController` loads snapshot on startup, exposes `AiModalityConfigs`.
- `aiModalityConfigsProvider` watches controller; capability resolvers unchanged structurally.

**Sign out**: BYOK secrets **remain on device** in v1 (local keys, not account-bound). Privacy notice in settings copy.

**Alternatives considered**:

| Alternative | Rejected because |
|-------------|------------------|
| All-in-Drift encrypted blob | Reinvents secure storage; harder to rotate keys per modality |
| Single global BYOK key | Spec requires per-modality independent config |
| Cloud sync | Out of scope |

**ai_sdk_dart spike (2026-06-30, Phase 4 / T028)**: **PASS** — `ai_sdk_openai` accepts custom `baseUrl` + `apiKey` via `OpenAIProvider(apiKey:, baseUrl:)(modelId)` and posts to `/chat/completions`. Same pattern verified in SDK source for `ai_sdk_anthropic` (`/messages`) and `ai_sdk_google` (`/models/{id}:generateContent`). DeepSeek and other OpenAI-compatible hosts use the OpenAI-compatible spec with user base URL (e.g. `https://api.deepseek.com/v1`). Live network proof deferred to manual QS-2.
