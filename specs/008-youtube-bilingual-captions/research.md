# Research: YouTube Bilingual Captions

**Feature**: [spec.md](./spec.md) · **Plan**: [plan.md](./plan.md) · **Date**: 2026-07-09

This document records the technical decisions for the bilingual-caption feature.
The spec had no unresolved `[NEEDS CLARIFICATION]` items; the worker backend was
**confirmed** by reading the local worker source (`C:\Users\me\dev\enjoy`,
`apps/worker/src/routes/youtube.ts`). Each decision below states what was chosen,
why, and what alternatives were rejected.

---

## R0. Worker backend confirmation

**Decision**: The worker already supports everything the feature needs. Adopt it
as-is (no worker changes required).

**Findings** (verified in `routes/youtube.ts` + `youtube.test.ts`):
- `POST /youtube/transcripts` accepts a `languages: string[]` body field. When
  present, the request takes the **multi-language path**
  (`handleMultiLanguageRequest`).
  - First entry = **source** language (the original caption fetched from the
    video via `getEnjoyForRequest`).
  - Remaining entries = **translation** targets (read via
    `getTranslatedEnjoyForRequest`, stored under a `to-{lang}/` sub-prefix).
  - `parseMultiLanguages`: max 5, de-duplicated, order-preserved, ignores
    `auto`/non-strings; malformed arrays → `[]` → falls back to single-language
    validation.
- Response shapes (snake_case on the wire; the Flutter `ApiClient` converts to
  camelCase):
  - `ready` → `{ status, videoId, transcripts: [ {videoId, language, source,
    format, cached, timeline, rawUrl, metadata} ] }` — **note the array**, this
    differs from the flat single-caption response.
  - `partial` → same `transcripts[]` (only the ready entries; the worker filters
    out `{language, status:'missing'}` from the array) **plus**
    `missing_languages`.
  - `generating` → HTTP 202 `{ status, jobId, stage, created }`, header
    `Retry-After: 5` (only when `wait_ms > 0`).
  - `failed` → HTTP 500 `{ status, jobId, error, debugRequestId }`.
- Two more capabilities exist for cheaper polling:
  - `GET /youtube/transcripts/:job_id` with `ETag` / `If-None-Match` (304 when
    unchanged) and optional `?wait_ms=`.
  - `GET /youtube/transcripts/:job_id/events` — SSE stream (status → end/error).
- `wait_ms` body field (0–25000, capped at `MAX_WAIT_MS = 25_000`) enables
  server-side long-polling; the worker polls the Cloudflare Workflow internally
  at a 1 s interval until terminal or the deadline.
- The single-language path (no `languages`) is unchanged and **retains the
  Apify fallback** (`handleApifyFallbackWorkflow`) that the multi-language path
  does **not** have.

**Rationale**: Confirms the user's "confirm the API backend" request. The client
work is purely consumer-side.

**Alternatives considered**: none — the backend is fixed.

---

## R1. Polling strategy: adopt `wait_ms` long-poll now; defer ETag/SSE

**Decision**: Replace the client's fixed `Duration(seconds: 2) × 30` sleep loop
with **server-side long-polling via `wait_ms`**, honouring the `Retry-After`
header between attempts.

**Rationale**:
- Lowest-risk, highest-immediate-value improvement. It reuses the existing
  `POST /youtube/transcripts` call and only adds a `waitMs` field + reads a
  response header.
- Each long-poll holds up to ~20 s server-side, so a typical video resolves in
  1–3 POSTs instead of up to 30. Wall-clock to first caption stays the same or
  improves (no fixed 2 s floor when the workflow finishes mid-poll).
- `wait_ms` is capped at 25 s by the worker (below the 30 s edge timeout). We
  will send `waitMs: 20000` to leave headroom for the post-poll R2 lookup + JSON
  serialisation on the worker.

**Alternatives considered**:
- **ETag GET polling** (`GET …/:job_id`, `If-None-Match` → 304): good for cheap
  unchanged polls, but requires persisting the `jobId` from the initial 202 and
  adding a second API method + a 304-aware path through `ApiClient` (which today
  treats non-2xx as errors and decodes bodies; 304 has an empty body). Net extra
  complexity for a marginal gain over long-poll. **Deferred to a follow-up.**
- **SSE** (`/events`): eliminates polling but needs a persistent streaming
  connection, reconnect/backoff, and an SSE-capable client. `package:http` does
  not stream SSE cleanly; we would need `dart:io HttpClient` (mobile/desktop
  only — fine platform-wise, but more code) or an added dependency. The worker
  already long-polls internally at 1 s, so SSE's latency advantage is small.
  **Deferred to a follow-up.**

**Open follow-up**: file an issue/ADR note to evaluate ETag-GET or SSE if
long-poll proves insufficient on slow workflows.

---

## R2. Request shape: conditional multi-language path

**Decision**:
- Compute `source = workerLanguageBase(video.language)` (skip cloud if
  empty/`und` — current behaviour).
- Compute `native = workerLanguageBase(effectiveNativeLanguage)`.
- **If `native == null || native == source`**: use the **existing single-language
  path** (`language: source`, flat response, Apify fallback intact). No behaviour
  change for monolingual videos.
- **Else**: use the **multi-language path** (`languages: [source, native]`,
  `transcripts[]` response).

**Rationale**:
- Preserves the single-language **Apify fallback** (`handleApifyFallbackWorkflow`),
  which only the single-language path triggers. If we always used `languages:`,
  we would regress edge cases where only Apify can fetch the auto captions.
- Keeps the common case (learner's native == content language, or unknown
  native) on the well-tested flat-response path.
- The bilingual branch is additive and isolated.

**Alternatives considered**:
- **Always use `languages:`** (uniform one code path): rejected because it loses
  the Apify fallback for single-language auto-caption fetches and changes the
  response shape for the common monolingual case (more regression surface).

**Wire format note**: `ApiClient.convertKeysToSnake` turns camelCase body keys
into snake_case, so feature code keeps camelCase (`languages`, `captionFetch`,
`forceRefresh`, `waitMs`). The worker reads `languages` / `caption_fetch` /
`force_refresh` / `wait_ms`.

---

## R3. Response handling: `ready` / `partial` / `generating` / `failed`

**Decision**:
- **`ready`**: iterate `response['transcripts']` (camelCased by `ApiClient`).
  For each entry, upsert a `TranscriptRow` using
  `enjoyTranscriptId(targetType:'Video', targetId, language, source)` and the
  entry's `timeline` (via the existing `transcriptLinesFromApiTimeline`),
  `rawUrl`, and `metadata`-derived label. Then assign primary = the row whose
  language matches `source`, secondary = the row whose language matches `native`
  (when present).
- **`partial`**: identical storage for whatever `transcripts[]` contains (the
  worker already excludes missing entries from the array). Result is **success**
  (store count = stored entries), not an error. `missing_languages` is logged
  via `logNamed` for diagnostics only. **Source-missing edge case**: if the
  *source/original* language is the missing one (only the translation is ready),
  do NOT call `updatePrimaryTranscriptForTarget` with a non-existent source-row
  id — store the ready track(s) and let the existing `ensurePrimaryTranscript`
  source-priority sort pick a primary, still returning `success`.
- **`generating` (202)**: read `Retry-After` (default 5 s) and re-POST with
  `waitMs` until a terminal status or the attempt budget elapses; preserve the
  existing "record a fetched state on terminal failure so the UI does not spin
  forever" behaviour (`docs/features/youtube.md`).
- **`failed` (500)**: record `error` fetch-state outcome; keep any already-stored
  tracks; do **not** wipe them.

**Rationale**: matches the spec's graceful-degradation user story (US2) and the
worker's own partial semantics.

**Alternatives considered**: treating `partial` as an error → rejected (would
hide the successfully fetched original caption).

---

## R4. Primary / secondary assignment

**Decision**: After upserting, set primary and secondary **explicitly** rather
than relying on `_sortTranscriptRows`:
- `echoSessionDao.updatePrimaryTranscriptForTarget(...)` → primary = source-row id.
- `echoSessionDao.updateSecondaryTranscriptForTarget(...)` → secondary =
  native-row id (only if a native track was stored; otherwise leave secondary
  unchanged or clear it if a previous secondary no longer exists).

Both DAO helpers already exist (`updatePrimaryTranscriptForTarget`,
`updateSecondaryTranscriptForTarget`) — no new persistence code.

**Rationale**: deterministic per-language assignment; the existing source-priority
sort is a fallback for user-imported/embedded tracks, not the right tool for
"original is primary, translation is secondary".

**Alternatives considered**: rely on sort order → rejected (non-deterministic
when the translation happens to be `official` and the original is `auto`).

---

## R5. Native-language plumbing (architecture-safe)

**Decision**: Thread the native language from the Riverpod controller layer down
as a parameter into the repository — do **not** read providers inside
`TranscriptRepository`.

**Revised path** (consolidated so the manual-refresh route is never starved):
1. Read `effectiveNativeLanguage` **inside `TranscriptFetchCtrl._runResolve`**
   — the single private helper that BOTH `resolveOnOpen` and `refreshFromCloud`
   call — via `ref.read(appPreferencesCtrlProvider).valueOrNull?.effectiveNativeLanguage`.
2. Pass it as `nativeLanguage` into `TranscriptRepository.resolveOnOpen(...)` →
   `fetchCloudTranscripts(...)` → `_fetchYoutubeWorkerTranscripts(...)`.
3. `player_open_side_effects.dart` is **unchanged** — it already passes `signedIn`
   into `resolveOnOpen`; the native-language read moved into the controller.

**Rationale**: keeps the repository UI-free and provider-agnostic (Constitution
I). Reading in `_runResolve` (rather than at the `player_open_side_effects`
call site) guarantees FR-010: a manual "refresh from cloud" goes through the
same helper, so it automatically forwards the native language and re-requests
both captions. `appPreferencesCtrlProvider` already exposes
`effectiveNativeLanguage` (a canonical BCP-47 tag, coerced to never equal the
learning language). Unsigned users yield `null` → single-language/none path,
matching today.

**Alternatives considered**:
- Read at the `player_open_side_effects` call site and thread a parameter
  through `resolveOnOpen` only: **rejected** because `refreshFromCloud` shares
  `_runResolve` and would run without the native language (the FR-010 gap this
  revision fixes).
- Inject a `ProfileReader`/`NativeLanguageResolver` callback into the repo
  constructor: viable but adds a new abstraction for a single value; a parameter
  is simpler and sufficient.
- Read `appPreferencesCtrlProvider` inside the repo: rejected (would couple the
  data layer to Riverpod/UI providers).

---

## R6. Deduplication, base codes, and credits

**Decision**:
- Use `workerLanguageBase()` (first subtag, lowercased) for **both** source and
  native before comparing and before building `languages`. The worker's
  `parseMultiLanguages` dedupes, but normalising on the client avoids a
  pointless bilingual request and a confusing `partial`.
- Surface credit exhaustion gracefully: the worker returns a 4xx
  (`CreditsExhaustedError`) when the soft gate fails. `ApiClient` raises
  `ApiException`; the repository already maps failures to a `failed` fetch-state
  outcome. No special-casing required, but the error message should remain
  user-friendly (existing `transcriptErrorFriendlyTitle/Hint`).

**Rationale**: correctness + no extra wiring; reuses existing error UX.

---

## R7. Documentation & traceability

**Decision**:
- Update `docs/features/youtube.md` (Transcripts section: bilingual fetch +
  long-poll) and `docs/features/transcript.md`.
- Add ADR **0036-youtube-bilingual-transcripts.md** recording: (a) multi-language
  worker contract adoption, (b) conditional multi-path to preserve Apify
  fallback, (c) long-poll-now / ETag-SSE-later decision.

**Rationale**: Constitution V — the conditional-path and polling decisions are
non-obvious and costly to rediscover.

---

## Summary of files touched

| File | Change |
|------|--------|
| `lib/data/api/services/ai/youtube_transcripts_api.dart` | Add multi-language `pollTranscripts({videoId, languages, captionFetch, forceRefresh, waitMs})`; keep `pollTranscript`. |
| `lib/features/transcript/data/transcript_repository.dart` | Bilingual branch in `_fetchYoutubeWorkerTranscripts`; new `_storeWorkerTranscriptList` + explicit primary/secondary assignment; long-poll loop with `Retry-After`. |
| `lib/features/transcript/application/transcript_fetch_controller.dart` | Read `effectiveNativeLanguage` inside `_runResolve` (shared by `resolveOnOpen` + `refreshFromCloud`) and forward it as `nativeLanguage`. |
| `lib/features/player/application/player_open_side_effects.dart` | **Unchanged** — the native-language read moved into the controller. |
| `docs/features/youtube.md`, `docs/features/transcript.md` | Behaviour docs. |
| `docs/decisions/0036-…md` | New ADR (required — Constitution V; created in T030). |
| Tests under `test/` | Unit coverage per plan §Constitution II. |

**No DB migration. No new providers strictly required. No `build_runner` run
required for the minimal change.**
