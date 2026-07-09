---

description: "Task list for YouTube Bilingual Captions"
---

# Tasks: YouTube Bilingual Captions

**Input**: Design documents from `/specs/008-youtube-bilingual-captions/`

**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Automated tests are required for changed behavior (plan §Constitution II). Tests are written first and must FAIL before implementation.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Feature code**: `lib/features/transcript/{application,data,domain,presentation}/`, `lib/features/player/application/`
- **Shared code**: `lib/core/`, `lib/data/api/services/ai/`
- **Tests**: `test/features/transcript/`, `test/data/api/services/ai/`
- **Feature docs**: `docs/features/youtube.md`, `docs/features/transcript.md`
- **ADRs**: `docs/decisions/0036-youtube-bilingual-transcripts.md`

**Key constraint**: The repository file `lib/features/transcript/data/transcript_repository.dart` is edited by all three user stories. US1 establishes the bilingual structure; US2 and US3 extend it sequentially. Do not mark those repository tasks `[P]` against each other.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Branch + verify the existing schema/DAOs already support this feature (no migration).

- [ ] T001 Create feature branch `008-youtube-bilingual-captions` from `main`
- [x] T002 [P] Verify no Drift migration is needed: confirm `EchoSessions.secondaryTranscriptId`, `Transcripts`, and `TranscriptFetchStates` exist in `lib/data/db/tables/` and that `updatePrimaryTranscriptForTarget` / `updateSecondaryTranscriptForTarget` exist on the echo session DAO (read-only sanity check)
- [x] T003 [P] Note the worker contract source of truth (local clone path `apps/worker/src/routes/youtube.ts`) for later citation; it will be referenced by the ADR created in T030. This is a reference note only — it does not edit a not-yet-existing artifact (T030 is in the Polish phase).

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The shared worker API client method that all user stories consume. MUST be complete before any user story.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [x] T004 [P] Add multi-language method to `YoutubeTranscriptsClient`/`YoutubeTranscriptsApi` in `lib/data/api/services/ai/youtube_transcripts_api.dart`: `pollTranscripts({videoId, languages, captionFetch, forceRefresh, waitMs})` → `POST /youtube/transcripts`. Keep the existing single-language `pollTranscript`. (Keys stay camelCase; `ApiClient` converts to snake_case.)
- [x] T005 [P] Unit test for the new method in `test/data/api/services/ai/youtube_transcripts_api_test.dart`: assert the request body carries `languages`, `captionFetch`, `forceRefresh`, `waitMs` and posts to `/youtube/transcripts`

**Checkpoint**: Foundation ready — user story implementation can now begin.

---

## Phase 3: User Story 1 - Bilingual captions in a single fetch (Priority: P1) 🎯 MVP

**Goal**: Signed-in learner opening a YouTube video whose content language differs from their native language gets the original caption as **primary** and the native-language translation as **secondary**, fetched in one request, with no extra taps.

**Independent Test**: Open a distinct-language video while signed in; confirm a single `POST /youtube/transcripts` carrying `languages:[source,native]`, and both tracks appear with primary=original, secondary=translation. (quickstart V1)

### Tests for User Story 1

> Write these FIRST; ensure they FAIL before implementation.

- [x] T006 [P] [US1] Unit test for language-pair selection in `test/features/transcript/transcript_repository_multi_lang_test.dart`: native null OR `workerLanguageBase(native)==source` → single-language path; otherwise `languages:[source,native]` (deduped, base codes)
- [x] T007 [P] [US1] Unit test in `test/features/transcript/transcript_repository_multi_lang_test.dart`: multi-language `ready` with 2 transcripts → upserts two distinct rows (via `enjoyTranscriptId`) and returns `success` with storedCount=2
- [x] T008 [P] [US1] Unit test in `test/features/transcript/transcript_repository_multi_lang_test.dart`: primary set to the source-language row and secondary set to the native-language row
- [x] T009 [P] [US1] Unit test in `test/features/transcript/transcript_fetch_controller_native_lang_test.dart`: BOTH `resolveOnOpen` and `refreshFromCloud` forward the native language into the repository only when signed in (the refresh path is what closes the FR-010 gap)

### Implementation for User Story 1

- [x] T010 [US1] Add an optional `nativeLanguage` parameter through `TranscriptRepository.resolveOnOpen` → `fetchCloudTranscripts` → `_fetchYoutubeWorkerTranscripts` in `lib/features/transcript/data/transcript_repository.dart` (no behaviour change yet; wiring only)
- [x] T011 [US1] Implement the bilingual branch in `_fetchYoutubeWorkerTranscripts` in `lib/features/transcript/data/transcript_repository.dart`: compute source=`workerLanguageBase(video.language)` and native=`workerLanguageBase(nativeLanguage)`; when native is present and differs from source, call `pollTranscripts(languages:[source,native], captionFetch:'auto', forceRefresh, waitMs:0 for now)` and handle a `ready` response (depends T004, T010)
- [x] T012 [US1] Add `_storeWorkerTranscriptList` helper + explicit assignment in `lib/features/transcript/data/transcript_repository.dart`: iterate `response['transcripts']`, upsert each `TranscriptRow` via `enjoyTranscriptId('Video', mediaId, language, source)` with `transcriptLinesFromApiTimeline`, `rawUrl`, and metadata-derived label; then call `updatePrimaryTranscriptForTarget` (source row) and `updateSecondaryTranscriptForTarget` (native row). Reuse `_normalizeSource`/`_youtubeWorkerTranscriptLabel`
- [x] T013 [US1] Read `effectiveNativeLanguage` from `appPreferencesCtrlProvider` inside `TranscriptFetchCtrl._runResolve` (the shared helper used by BOTH `resolveOnOpen` and `refreshFromCloud`) via `ref.read(...).valueOrNull?.effectiveNativeLanguage`, and forward it to `repo.resolveOnOpen` in `lib/features/transcript/application/transcript_fetch_controller.dart`. A single read site means the native language is never missed on a manual refresh (FR-010). Note: `player_open_side_effects.dart` needs NO change — it already passes `signedIn`, and the native-language read now lives in the controller layer (still keeping the repository UI-free).
- [x] T014 [US1] Confirm the FR-010 refresh path end-to-end: assert in `test/features/transcript/transcript_fetch_controller_native_lang_test.dart` that `refreshFromCloud({signedIn:true})` forwards the native language through `_runResolve` into `repo.resolveOnOpen` (so a manual "refresh from cloud" re-requests both original + native), and that `player_open_side_effects.dart`'s existing `resolveOnOpen(signedIn:)` call is unchanged. Depends T013.
- [ ] T015 [US1] Manual verification + evidence for quickstart V1: open a distinct-language video, confirm one bilingual request and automatic primary/secondary selection; attach request log + screenshot to the PR

**Checkpoint**: User Story 1 is fully functional and testable independently (happy path only; hardening is US2, polling perf is US3).

---

## Phase 4: User Story 2 - Graceful degradation and skip-when-same (Priority: P2)

**Goal**: Bilingual fetch never makes captions worse — partial results store what is ready, missing translations never error, `failed` keeps stored tracks, and unknown/`und` content language skips cloud entirely.

**Independent Test**: quickstart V2 (partial → original shown, no error), V3 (content language == native → single-language path, Apify fallback intact), V4 (und → no cloud request).

### Tests for User Story 2

- [x] T016 [P] [US2] Unit test in `test/features/transcript/transcript_repository_multi_lang_test.dart`: TWO partial cases — (a) `missingLanguages:[native]` and `transcripts:[source]` → stores original, sets primary, leaves secondary unset, returns `success`; (b) source-missing `missingLanguages:[source]` and `transcripts:[native]` → stores the translation, does NOT assign a primary from a non-existent source row (falls back to existing primary sort), leaves secondary, returns `success` (neither case returns `error`)
- [x] T017 [P] [US2] Unit test in `test/features/transcript/transcript_repository_multi_lang_test.dart`: worker `failed` → returns `error` outcome and does not delete previously stored rows
- [x] T018 [P] [US2] Unit test in `test/features/transcript/transcript_repository_multi_lang_test.dart`: source language `und`/empty → `skipped` and no `pollTranscripts`/`pollTranscript` call is made

### Implementation for User Story 2

- [x] T019 [US2] Handle `partial` in the bilingual branch in `lib/features/transcript/data/transcript_repository.dart`: store whatever `response['transcripts']` contains via `_storeWorkerTranscriptList`, log `response['missingLanguages']` through `logNamed`, and return `success` with the stored count (depends T012). **Source-missing guard**: when the source/original language is among `missingLanguages`, do NOT call `updatePrimaryTranscriptForTarget` with a non-existent source-row id — fall back to the existing `ensurePrimaryTranscript` source-priority sort so the learner still gets a readable primary.
- [x] T020 [US2] Confirm the `source==native`/unknown-native case routes to the existing single-language path (Apify fallback preserved) and that `und`/empty source returns `skipped` before any request, in `lib/features/transcript/data/transcript_repository.dart` (the `und` guard already exists in `_workerCaptionLanguage`; add a test that pins it)
- [x] T021 [US2] On worker `failed`, record the `error` fetch-state outcome via `_persistFetchOutcome` and preserve any already-stored tracks (no wipe) in `lib/features/transcript/data/transcript_repository.dart`
- [ ] T022 [US2] Manual verification + evidence for quickstart V2, V3, V4; attach to PR

**Checkpoint**: User Stories 1 AND 2 both work independently; degradation is covered.

---

## Phase 5: User Story 3 - Lighter, faster, more reliable fetching (Priority: P3)

**Goal**: Replace the fixed `2s × 30` client sleep loop with the worker's server-side `wait_ms` long-poll and a `Retry-After`-aligned backoff, markedly reducing requests per video while keeping prompt captions. Reopen stays network-free.

**Independent Test**: quickstart V6 (captions still generating → resolves in a handful of POSTs, not ~30), V5 (reopen → zero transcript requests), V7 (manual refresh re-pulls both with `forceRefresh`).

> Implementation note: the worker always emits `Retry-After: 5` when `waitMs>0`. `ApiClient.postJson` returns only the decoded body (no headers), so use a constant 5s backoff aligned with the worker's header rather than reading the header — this avoids changing `ApiClient`.

### Tests for User Story 3

- [x] T023 [P] [US3] Unit test in `test/features/transcript/transcript_repository_multi_lang_test.dart`: each poll sends a non-zero `waitMs` (server-side long-poll); on `generating` the loop re-polls after the backoff interval and stops at the attempt budget
- [x] T024 [P] [US3] Unit test in `test/features/transcript/transcript_repository_multi_lang_test.dart`: an already-fetched target (non-error `TranscriptFetchState`) yields `skipped` with zero worker calls on reopen

### Implementation for User Story 3

- [x] T025 [US3] Replace the fixed-interval poll loop in `_fetchYoutubeWorkerTranscripts` in `lib/features/transcript/data/transcript_repository.dart`: send `waitMs: 20000` on each POST; on HTTP-202 `generating`, wait a 5s backoff (worker `Retry-After` value) then re-POST; keep a bounded attempt budget sized for ~60–75s total (depends T011)
- [x] T026 [US3] Apply the same `waitMs` long-poll to the single-language path in `lib/features/transcript/data/transcript_repository.dart` so both paths share the lighter loop
- [ ] T027 [US3] Capture before/after evidence for quickstart V6 (request count) and time-to-first-caption parity, and record it in the PR / plan; verify V5 (0-request reopen) and V7 (forceRefresh bilingual re-pull)
- [ ] T035 [US3] Verify QR-006 / SC-006 dual-caption scroll performance on a long video (≥20 min, both original + translation timelines loaded): confirm no dropped frames / scroll jank during transcript scrolling on Android, iOS, macOS, and Windows. Large payloads already decode off the main isolate via `ApiClient.compute`; this is a read-only platform verification — record evidence (e.g. performance overlay / frame timings) in the PR. Depends on US1 (dual captions exist).

**Checkpoint**: All user stories are independently functional; fetching is lighter and faster.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Documentation, traceability, and full verification gates.

- [x] T028 [P] Update the Transcripts section of `docs/features/youtube.md` to describe bilingual fetch (original + native translation in one request, primary/secondary assignment) and the `wait_ms` long-poll
- [x] T029 [P] Update `docs/features/transcript.md` with the bilingual primary/secondary behaviour and partial/missing resilience
- [x] T030 [P] Create ADR `docs/decisions/0036-youtube-bilingual-transcripts.md`: multi-language worker contract adoption, conditional single-vs-multi path (preserve Apify fallback), and long-poll-now / ETag-SSE-later decision (reference worker route `apps/worker/src/routes/youtube.ts`)
- [x] T031 Run `dart run build_runner build` (expected no-op — no new `@riverpod`/Drift annotations; confirm generated files unchanged)
- [x] T032 Run `flutter analyze` (must be clean)
- [x] T033 Run `flutter test` (all green, including the new tests)
- [ ] T034 Run the `specs/008-youtube-bilingual-captions/quickstart.md` validation scenarios V1–V7 and record results

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately.
- **Foundational (Phase 2)**: Depends on Setup — **BLOCKS** all user stories (the shared `pollTranscripts` API method).
- **User Stories (Phase 3–5)**: Each depends on Foundational. US2 and US3 additionally build on US1's repository structure (same file).
- **Polish (Phase 6)**: Documentation can start anytime marked `[P]`; verification gates depend on all desired stories being complete.

### User Story Dependencies

- **US1 (P1)**: Starts after Foundational. No dependency on other stories. (Edits `transcript_repository.dart` and `transcript_fetch_controller.dart`; `player_open_side_effects.dart` is unchanged — the native-language read moved into the controller's `_runResolve`.)
- **US2 (P2)**: Starts after US1 — extends the bilingual branch and storage helper inside `transcript_repository.dart`. Independently testable.
- **US3 (P3)**: Starts after US1 — rewrites the poll loop inside `transcript_repository.dart` (shared by both language paths). Independently testable.

### Within Each User Story

- Tests written FIRST and FAIL before implementation.
- Repository wiring (T010) before bilingual branch (T011) before storage helper (T012).
- `Retry-After`/`waitMs` work (US3) after the branch it loops over exists (US1).

### Parallel Opportunities

- All Setup tasks marked `[P]` (T002, T003) run in parallel.
- Foundational T004 and T005 are on different files (impl vs. test) → parallel.
- Within a story, the test tasks marked `[P]` run in parallel (e.g., T006, T007, T008, T009).
- `transcript_fetch_controller.dart` (T013/T014 — native-language read + refresh verification) depends on the repository signature (T010); after T010 it can proceed. `player_open_side_effects.dart` is no longer edited for native language (the read moved into the controller).
- Polish docs (T028, T029, T030) are independent files → parallel.

> Note: the three user stories all edit `transcript_repository.dart`, so they are best sequenced US1 → US2 → US3 rather than parallelised.

---

## Parallel Example: User Story 1

```bash
# Launch all US1 tests together (independent assertions, same test file is OK to add as one suite):
Task: "Language-pair selection test in test/features/transcript/transcript_repository_multi_lang_test.dart"
Task: "ready(2) storage + primary/secondary assignment test in test/features/transcript/transcript_repository_multi_lang_test.dart"
Task: "Controller native-language forwarding test in test/features/transcript/transcript_fetch_controller_native_lang_test.dart"

# After the repository signature (T010) lands, wire the controller boundary:
Task: "Read effectiveNativeLanguage inside _runResolve in lib/features/transcript/application/transcript_fetch_controller.dart (covers resolveOnOpen + refreshFromCloud)"
# player_open_side_effects.dart is unchanged — it already passes signedIn.
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup.
2. Complete Phase 2: Foundational (`pollTranscripts` API method).
3. Complete Phase 3: User Story 1 (bilingual happy path + primary/secondary).
4. **STOP and VALIDATE**: quickstart V1 — both captions appear from one request.
5. Demo/ship the MVP.

### Incremental Delivery

1. Setup + Foundational → foundation ready.
2. Add US1 → test V1 → MVP demo.
3. Add US2 → test V2/V3/V4 → ship resilience.
4. Add US3 → test V5/V6/V7 → ship the lighter/faster fetch.
5. Polish docs + ADR + full `flutter analyze` / `flutter test` / quickstart.

### Parallel Team Strategy

- One developer owns `transcript_repository.dart` end-to-end (US1→US2→US3) to avoid file conflicts.
- A second developer can own the API method (T004–T005), the boundary wiring (T013–T014), and all docs/ADR (T028–T030) in parallel.

---

## Notes

- `[P]` tasks = different files, no dependencies on incomplete tasks.
- `[Story]` label maps a task to its user story for traceability.
- Each user story is independently completable and testable.
- Verify tests fail before implementing.
- Commit after each task or logical group.
- Stop at any checkpoint to validate a story independently.
- No DB migration, no new providers, no `build_runner` codegen required for the minimal change (T031 is a confirmation step).
