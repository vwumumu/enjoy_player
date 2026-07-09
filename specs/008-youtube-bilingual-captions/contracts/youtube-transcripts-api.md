# Contract: YouTube Transcripts Worker API

**Feature**: [spec.md](../spec.md) · **Source of truth**: worker route
`apps/worker/src/routes/youtube.ts` (confirmed against local clone).

This is the external interface the Enjoy Player client consumes. The Flutter
`ApiClient` performs **camelCase ↔ snake_case** conversion automatically:

- **Request body**: Dart code uses camelCase keys; `ApiClient.convertKeysToSnake`
  sends snake_case on the wire (`videoId`→`video_id`, `captionFetch`→
  `caption_fetch`, `forceRefresh`→`force_refresh`, `waitMs`→`wait_ms`).
- **Response body**: the worker sends snake_case; `ApiClient.decodeJsonToCamel`
  returns camelCase to Dart (`raw_url`→`rawUrl`, `job_id`→`jobId`,
  `missing_languages`→`missingLanguages`, `debug_request_id`→`debugRequestId`).

Base URL: the configured worker base (default `https://worker.enjoy.bot`, see
`kDefaultAiApiBaseUrl`). Auth: bearer token (handled by `ApiClient`).

---

## `POST /youtube/transcripts`

Single endpoint; behaviour branches on whether `languages` is present.

### Request body

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `videoId` | string | **yes** | 11-char YouTube id (`^[a-zA-Z0-9_-]{11}$`). 400 otherwise. |
| `language` | string | single-lang path | Real BCP-47 base code (not `auto`). Used when `languages` absent. |
| `languages` | string[] | multi-lang path | First entry = **source**; rest = **translation** targets. Max 5, deduped, order preserved; `auto`/non-strings ignored. Triggers the batched workflow (fetch once, translate in-step). |
| `captionFetch` | `'auto'` \| `'official'` | no (default `'auto'`) | Caption selection strategy. (Worker also accepts legacy `source`.) |
| `forceRefresh` | bool | no (default `false`) | Invalidates cached artifacts / restarts workflow. |
| `waitMs` | int | no (default `0`) | Server-side long-poll, clamped to `[0, 25000]`. When `>0` and not yet terminal, the worker waits up to that many ms before responding, and sets `Retry-After: 5`. |

> Send **either** `language` (monolingual) **or** `languages` (bilingual), not
> both. When `languages` is present, `language` is ignored.

### Bilingual request (this feature)

```jsonc
// Wire body (snake_case). Dart sends camelCase; ApiClient converts.
{
  "video_id": "dQw4w9WgXcQ",
  "languages": ["en", "zh"],
  "caption_fetch": "auto",
  "force_refresh": false,
  "wait_ms": 20000
}
```

### Responses (multi-language path)

All response objects are arrays under `transcripts`. Each entry:

```jsonc
{
  "videoId": "...",
  "language": "en",          // base code
  "source": "official",      // official | auto
  "format": "enjoy",
  "cached": true,            // true on R2 cache hit
  "timeline": [ { "text": "...", "start": 0, "duration": 1000 } ],
  "rawUrl": "youtube/<vid>/<lang>/<source>/raw.json",
  "metadata": { "title": "...", "channel": "...", "durationMs": 0,
                "translatedFrom": "en", "translatedTo": "zh" }
}
```

| HTTP | `status` | Body (camelCased for Dart) | Client action |
|------|----------|------------------------------|---------------|
| 200 | `ready` | `{ status, videoId, transcripts: [...] }` | Upsert all; assign primary=source, secondary=native. Return **success**. |
| 200 | `partial` | `{ status, videoId, transcripts: [...ready only...], missingLanguages: ["zh"], debugRequestId }` | Upsert what is present; assign primary; set secondary only if native present. Return **success** (not error). Log `missingLanguages`. |
| 202 | `generating` | `{ status, jobId, stage, created }`; header `Retry-After: 5` (when `waitMs>0`) | Sleep `Retry-After` (default 5s), re-POST with `waitMs`. Continue until terminal or attempt budget hit. |
| 500 | `failed` | `{ status, jobId, error, debugRequestId }` | Record `error` fetch-state; keep stored tracks. |
| 4xx | — | `{ error, code?, debugRequestId }` (e.g. credits-exhausted / malformed) | Map to `error` outcome; surface friendly message. |

### Single-language path (unchanged, for `source == native` / unknown native)

Request omits `languages` and sends `language: <source>` plus the same
`captionFetch` / `forceRefresh` / `waitMs`. Response is **flat** (no
`transcripts[]`):

```jsonc
// ready
{ "status": "ready", "videoId": "...", "language": "en", "source": "official",
  "format": "enjoy", "cached": true, "timeline": [...], "rawUrl": "...",
  "metadata": {...} }
```

`generating` (202) and `failed` (500) shapes are identical to the multi-language
path (minus `missingLanguages`). This path **retains the Apify fallback** for
`captionFetch: 'auto'` when the workflow completes but no artifact exists.

---

## Related (not adopted in this feature — documented for completeness)

- `GET /youtube/transcripts/:jobId` — cheap status read with `ETag` /
  `If-None-Match` (304 when unchanged) and optional `?waitMs=`. *(Deferred — see
  research.md R1.)*
- `GET /youtube/transcripts/:jobId/events` — SSE stream
  (`event: status` / `event: error` / `event: end`). *(Deferred.)*

## Client invariants this feature enforces

1. Send `languages` only when a valid, **different** native language is known;
   otherwise use the single `language` path.
2. Always send `waitMs` (≥ a few seconds) on each poll to engage server-side
   long-poll; honour `Retry-After` between calls.
3. Treat `partial` as success for the languages stored; never error when only the
   translation is missing.
4. Idempotent upsert via `enjoyTranscriptId(targetType, targetId, language,
   source)` so re-fetches update in place.
