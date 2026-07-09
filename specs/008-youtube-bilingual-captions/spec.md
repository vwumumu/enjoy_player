# Feature Specification: YouTube Bilingual Captions

**Feature Branch**: `008-youtube-bilingual-captions`

**Created**: 2026-07-09

**Status**: Draft

**Input**: User description: "The YouTube transcripts API has update ... It support `languages` as param now. In YouTube video, we actually need to pull two caption, the original lang caption, and the translation caption(from user's native language). Help me to confirm the API backend(worker), and update the API in Enjoy Player, pull the primary and secondary subtitles at one request. Also if you find any improvement for this API request, we should consider it."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Bilingual captions in a single fetch (Priority: P1)

When a signed-in learner opens a YouTube video, they want to see **both** the
video's original-language caption **and** a caption translated into their own
native language, side by side, without any extra taps. Today the app fetches only
one caption per video and the learner must manually pick a translation track (if
one even exists locally). This feature requests the original caption and the
native-language translation **together** in one transcript fetch, assigns the
original as the **primary** subtitle and the native translation as the
**secondary** subtitle, and shows both in the transcript/subtitle view
automatically.

**Why this priority**: This is the core value of the change — it is the only
story that delivers the bilingual reading experience the learner is asking for,
and it is usable on its own.

**Independent Test**: Open a supported YouTube video while signed in, with a
profile native language that differs from the video's content language. Within
the normal transcript load, both the original caption and the native-language
translation appear as selectable tracks, the original set as primary and the
translation set as secondary, after a single transcript request.

**Acceptance Scenarios**:

1. **Given** a signed-in user whose native language differs from a YouTube
   video's content language, **When** they open that video, **Then** the app
   issues one transcript request asking for both the original and the native
   translation, and on success stores both as separate caption tracks.
2. **Given** both captions have been fetched, **When** transcript resolution
   finishes, **Then** the original-language caption is the active primary
   subtitle and the native-language caption is the active secondary subtitle.
3. **Given** the worker is still producing the captions (not ready yet),
   **When** the app polls again, **Then** it continues polling the same single
   job until both captions are available (or a terminal state is reached),
   rather than starting a second, separate request.

---

### User Story 2 - Graceful degradation and skip-when-same (Priority: P2)

The bilingual fetch must never make captions *worse*. If the video's content
language is the same as the learner's native language, there is nothing to
translate and the app must fetch only the original caption. If the translation
is unavailable (e.g. the service could not produce it, or only the original
exists), the app must still present the original caption cleanly — never
showing an error or blocking the learner from reading along.

**Why this priority**: Resilience protects the core reading experience; without
it, the P1 flow would regress whenever a translation is missing.

**Independent Test**: Open a YouTube video whose content language equals the
profile native language; confirm only one caption is requested and shown. Open a
video where only the original caption exists; confirm the original appears
without any error state.

**Acceptance Scenarios**:

1. **Given** the video's content language equals the user's native language,
   **When** the app builds the transcript request, **Then** it requests only the
   original language (no translation), so no translation work or wasted request
   occurs.
2. **Given** the transcript service returns the original caption but no usable
   translation, **When** the response is processed, **Then** the original caption
   is stored and shown as the primary subtitle and no error is surfaced to the
   learner.
3. **Given** the service reports a partial result (some languages ready, some
   missing), **When** the app handles it, **Then** every caption that *is* ready
   is stored and shown, and the request is treated as successful for those
   languages.

---

### User Story 3 - Lighter, faster, more reliable fetching (Priority: P3)

The current fetch loop wakes the device every couple of seconds for up to a
minute and starts a fresh request each cycle. The updated transcript service
supports server-side waiting, cheap unchanged polls, and streaming progress, so
the app should adopt whichever strategy minimizes request count, latency, and
battery/network cost while keeping the "captions appear as soon as they're ready"
feel. Reopening a video that was already fetched must still be instant and
network-free.

**Why this priority**: Pure improvement work that compounds with P1/P2 but is
not required for the bilingual experience to function.

**Independent Test**: Open a video whose captions are still being generated and
observe that captions appear promptly with markedly fewer network round-trips
than the prior fixed-interval loop; reopen the same video and confirm captions
appear instantly from local storage with zero transcript requests.

**Acceptance Scenarios**:

1. **Given** captions are still generating, **When** the app waits for them,
   **Then** it relies on the service's wait/progress mechanism rather than a
   fixed client-side sleep loop, reducing the number of requests per video.
2. **Given** a video was successfully fetched before, **When** the user reopens
   it, **Then** both caption tracks load instantly from local storage and no new
   transcript request is sent.
3. **Given** the service signals an unchanged state on a follow-up check,
   **When** the app re-checks, **Then** it reuses the previously received result
   instead of reprocessing the full payload.

---

### Edge Cases

- What happens when the video's content language is unknown/unspecified (no
  reliable source language to request)? The app should fall back to current
  behavior (local/sidecar tracks only) rather than sending an unusable request.
- What happens when the user is **not** signed in? Cloud/bilingual fetch is
  skipped (same as today); only local/cached tracks are shown.
- What happens when the translation language the app asks for is not one the
  service can translate into? Treated as "translation missing" — original only,
  no error (see US2).
- What happens when the **source/original** language is the one missing in a
  partial result (only the translation came back ready)? The app stores the ready
  translation track, MUST NOT set a primary from a non-existent source row, and
  falls back to the existing source-priority primary sort — never erroring and
  never leaving the learner without a readable caption.
- What happens with very long videos / large dual timelines? Transcript
  rendering and scrolling must stay responsive; large payloads should be decoded
  off the main UI thread where the app already does this.
- What happens across Android, iOS, macOS, and Windows? Both tracks must be
  selectable in the subtitle picker and the bilingual display must behave
  consistently regardless of input method.
- What happens when the user later changes their profile native language and
  re-fetches (cloud refresh)? The new native translation is requested and the
  secondary track is updated.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: When a signed-in user opens a YouTube video whose content language
  differs from their profile native language, the system MUST request the
  original-language caption and a caption translated into the user's native
  language **in a single transcript request**.
- **FR-002**: The original-language caption MUST be stored as the **primary**
  subtitle track for the video.
- **FR-003**: The native-language translation caption, when available, MUST be
  stored as a separate track and set as the **secondary** subtitle track
  automatically (no manual picker action required).
- **FR-004**: When the video's content language matches the user's native
  language, the system MUST request only the original-language caption (no
  translation language is sent).
- **FR-005**: When the translation caption is unavailable or only some languages
  are ready (a partial result), the system MUST still store and display every
  caption that is ready, without surfacing an error to the user. This includes
  the unusual case where the **source/original** language itself is the missing
  one: the system MUST NOT assign a primary from a non-existent source row;
  instead it stores the ready tracks and lets the existing source-priority sort
  select a primary, still without error (see Edge Cases).
- **FR-006**: The system MUST treat the original language as the *source*
  language of the request (the caption that is actually fetched from the video)
  and the native language as a *translation* target.
- **FR-007**: The system MUST persist both caption tracks locally so that
  reopening a previously fetched video shows both tracks instantly without a new
  network request.
- **FR-008**: The system MUST continue to honor the existing per-video fetch
  state so a successfully fetched video is not re-fetched on every reopen.
- **FR-009**: The system MUST NOT send a translation request when the source
  language cannot be determined (unknown/`und` content language); it falls back
  to local tracks only.
- **FR-010**: A manual "refresh from cloud" action MUST re-request both the
  original and the native-language translation (when they differ) using the same
  single-request flow.

### Quality, UX, and Performance Requirements

- **QR-001**: Implementation MUST preserve Enjoy Player's feature-first
  architecture and avoid feature-to-feature shortcuts unless the plan documents
  an exception.
- **QR-002**: Changed behavior MUST have automated tests (unit tests for the
  language-pair selection, request building, and response parsing; the polling
  degradation and partial-result handling) or a documented manual verification
  reason.
- **QR-003**: User-facing strings, controls, haptics, tooltips, and keyboard
  affordances MUST follow existing localization and shared UI patterns. No new
  user-visible strings are expected for the automatic assignment, but any added
  labels must live in ARB files.
- **QR-004**: The bilingual fetch MUST define a measurable performance budget:
  it MUST NOT more than marginally increase time-to-first-caption versus the
  current single-caption fetch, and it MUST reduce total request count per video
  by adopting the service's server-side wait/progress support.
- **QR-005**: Feature behavior changes MUST update the matching documentation
  under `docs/features/` (YouTube + transcript pages).
- **QR-006**: Large dual-caption timelines on long videos MUST decode off the
  main isolate (as the app already does for large payloads) and scroll without
  dropped frames on all supported platforms.

### Key Entities *(include if feature involves data)*

- **Caption Track (transcript)**: A language-specific subtitle timeline for a
  video. Each video may now carry a *primary* (original language) and a
  *secondary* (native-language translation) track. Tracks retain their existing
  attributes: language, source kind, label, and a stored timeline.
- **User Language Profile**: The signed-in user's `learningLanguage` and
  `nativeLanguage`. The native language drives which translation is requested.
- **Video Content Language**: The language recorded for a YouTube video at
  import; it is the *source* language of the transcript request.
- **Transcript Fetch State**: The per-video record of whether captions were
  already fetched, extended so a single successful bilingual fetch is not
  repeated.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Signed-in learners see both the original and the native-language
  caption tracks for a supported YouTube video within the same open as the
  primary caption appears, with no additional user action.
- **SC-002**: Both captions are obtained via a single transcript request per
  poll cycle (the request count for fetching original + translation is no higher
  than the previous single-caption fetch).
- **SC-003**: 100% of videos whose content language equals the learner's native
  language fetch only the original caption (zero wasted translation requests).
- **SC-004**: When a translation is unavailable, at least 95% of opens still
  present the original caption without showing an error state.
- **SC-005**: Reopening a previously fetched video displays both caption tracks
  instantly from local storage with zero transcript network requests.
- **SC-006**: Transcript scrolling with two caption tracks remains responsive on
  Android, iOS, macOS, and Windows for long videos.

## Assumptions

- **Backend confirmed.** The Enjoy worker's transcript endpoint accepts a
  `languages` array: the **first** entry is the *source* language (the original
  caption actually fetched from the video) and any remaining entries are
  *translation* targets, fetched once and translated in-step. Up to 5 languages,
  de-duplicated, order-preserved. The multi-language response returns a list of
  caption objects (not the flat single-caption shape) and may report a `partial`
  status with `missing_languages` when some are unavailable. (Verified against
  the worker source at `C:\Users\me\dev\enjoy`.)
- **Wire format is handled by the existing client.** The Flutter API client
  already converts request bodies to snake_case and response bodies to
  camelCase, so feature code may keep using camelCase keys (e.g. `languages`,
  `captionFetch`) and read camelCased response fields (e.g. `transcripts`,
  `rawUrl`, `missingLanguages`).
- **Language pair.** "Primary" = the video's stored content language (original
  caption); "secondary" = a caption in the user's profile **native** language.
  The learning language is not part of this pair unless it happens to be the
  video's content language.
- **Auto-pull both.** Both captions are requested automatically on open when the
  user is signed in and the two languages differ — consistent with today's
  automatic single-caption pull. No new opt-in toggle is introduced.
- **Caption fetch mode.** The default caption selection strategy remains `auto`
  (prefer official/manual tracks, then auto-generated).
- **Signed-in only.** Cloud/bilingual fetch requires sign-in; unsigned users see
  local/cached tracks only, exactly as today.
- **Improvements in scope.** The client will adopt the service's server-side wait
  / progress support (and, where practical, cheap unchanged-poll or streaming) to
  replace the fixed client-side sleep loop. The exact mechanism is chosen during
  planning; the user-facing outcome (fewer requests, prompt captions) is fixed.
- **Source-language fallback.** If the video's content language is unknown
  (`und`/empty), no cloud request is sent; the app falls back to local/sidecar
  tracks, matching current behavior.
