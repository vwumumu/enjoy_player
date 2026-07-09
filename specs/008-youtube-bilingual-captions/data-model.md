# Data Model: YouTube Bilingual Captions

**Feature**: [spec.md](./spec.md) · **Plan**: [plan.md](./plan.md)

> **No schema migration is required.** This feature reuses the existing Drift
> tables. This document records the entities involved, their relevant fields, the
> deterministic id derivation, and the fetch-state transition for the bilingual
> flow.

## Entities (existing, unchanged schema)

### TranscriptRow — `Transcripts` table

One row per (target, language, source). A bilingual YouTube fetch writes **two**
rows: the original-language caption and the native-language translation.

| Field | Type | Notes |
|-------|------|-------|
| `id` | text (PK) | Deterministic — see *Id derivation* below. |
| `targetType` | text | `'Video'` for YouTube. |
| `targetId` | text | The media item id. |
| `language` | text | Worker base code, e.g. `en`, `zh`. |
| `source` | text | `official` \| `auto` \| `ai` \| `user` (worker produces `official`/`auto`). |
| `timelineJson` | text | JSON array of `{text, start, duration}` (ms). |
| `referenceId` | text? | Set to the worker `rawUrl`. |
| `label` | text | From worker `metadata.title`, else `YouTube captions (<lang>)`. |
| `trackIndex` | int? | `null` for cloud tracks. |
| `syncStatus` | text? | `'synced'` for cloud-fetched rows. |
| `serverUpdatedAt` | datetime? | Worker `generated_at` / response time. |
| `createdAt` / `updatedAt` | datetime | Row timestamps. |

**Id derivation** (`enjoyTranscriptId` in `core/ids/enjoy_ids.dart`):
`uuidV5(NAMESPACE, 'transcript:<targetType>:<targetId>:<language>:<source>')`.
Because language is part of the pre-image, the original and the translation get
**distinct, stable** row ids — re-fetching the same pair upserts in place rather
than duplicating.

### EchoSessionRow — `EchoSessions` table (primary + secondary wiring)

| Field | Type | Notes |
|-------|------|-------|
| `targetType` / `targetId` | text | Identifies the media item. |
| `transcriptId` | text? | **Primary** transcript id (the original-language caption). |
| `secondaryTranscriptId` | text? | **Secondary** transcript id (the native-language translation). |

Both setters already exist on the DAO: `updatePrimaryTranscriptForTarget` and
`updateSecondaryTranscriptForTarget`. The bilingual flow calls both after upsert.

### TranscriptFetchStateRow — `TranscriptFetchStates` table

PK = `(targetType, targetId)`. Records that cloud captions were fetched at least
once so reopen is network-free.

| Field | Type | Notes |
|-------|------|-------|
| `lastFetchedAt` | datetime | When the last cloud fetch resolved. |
| `lastStatus` | text? | `success` \| `empty` \| `error`. |
| `lastError` | text? | User/log-friendly error when `lastStatus == 'error'`. |

## Derived (non-persisted) inputs

| Concept | Source | Used for |
|---------|--------|----------|
| **Source language** | `workerLanguageBase(video.language)` | `languages[0]` / `language`. Skip cloud when empty or `und`. |
| **Native language** | `appPreferencesCtrlProvider` → `AppPreferencesState.effectiveNativeLanguage` → `workerLanguageBase(...)` | `languages[1]` (translation target). |
| **Language pair** | `[source]` if `native == null \|\| native == source` else `[source, native]` | Chooses single- vs multi-language request path. |

## State transitions (bilingual fetch)

```text
                ┌─────────────────────────────────────────────────────┐
 resolveOnOpen  │  fetchCloudTranscripts(mediaId, nativeLanguage)     │
 ─────────────▶ │   tt == 'Video' && YouTube playback id resolvable?  │
 (signed in)    └───────────────┬─────────────────────────────────────┘
                                 │ yes
                                 ▼
            ┌──────────────────────────────────────────────┐
            │ _fetchYoutubeWorkerTranscripts               │
            │  source = workerLanguageBase(video.language) │
            │  native  = workerLanguageBase(nativeLanguage)│
            │  if source empty/und → SKIP (local only)     │
            └───────────────┬──────────────────────────────┘
                            │
            native missing  │   native present & != source
            or == source    │
        ┌───────────────────┴──────────────────────┐
        ▼                                           ▼
 single-language path                      multi-language path
 POST {language: source, waitMs}           POST {languages:[source,native], waitMs}
 (flat response + Apify fallback)          (transcripts[] response)
        │                                           │
        ▼                                           ▼
 status: ready/partial/generating/failed   status: ready/partial/generating/failed
        │                                           │
        └───────────────────┬──────────────────────┘
                            ▼
          upsert rows → set primary(=source) + secondary(=native if stored)
                            │
                            ▼
          TranscriptCloudFetchResult{status, storedCount}
          + persist TranscriptFetchState outcome
```

**Terminal outcomes → `TranscriptCloudFetchResult.status`:**
- Stored ≥1 track (original, or original+translation) → `success`.
- Reached the worker but zero tracks stored → `empty`.
- `failed` from worker or exception → `error` (existing tracks preserved).
- Not applicable (no cloud, already fetched, unsigned) → `skipped`.

**Validation rules encoded**:
- Never send `languages` with duplicate/equal entries (normalise first).
- Never send a request when `source` is unresolved (`und`/empty) → `skipped`.
- `partial` is treated as success for the languages that were stored.
