## Why

Enjoy Player's product promise is to help users learn any language from videos and audio, but the current app still treats English as the only learning language in several core flows. YouTube imports default to unknown language and then request English captions, Discover recommendations are not language-aware, and pronunciation assessment can silently fall back to the wrong Azure Speech locale.

## What Changes

- Expand the learner language model from English-only to a language catalog that can represent English, Japanese, Korean, Spanish, French, and future valid BCP-47 tags.
- Make media content language editable during local media import, YouTube import, and after a record already exists.
- Use media content language as the source of truth for YouTube transcript requests, shadow-reading recordings, and pronunciation assessment locale selection.
- Add explicit Azure Speech pronunciation assessment capability gating so unsupported locales do not fall back to fabricated or incorrect locale codes.
- Make Discover recommendations and subscriptions language-aware, including tagged recommended channels and language defaults when adding Discover videos to the library.
- Keep user libraries multilingual: the global learning language becomes a default/focus for recommendations and import suggestions, not a constraint that all media must share one language.
- Non-goal: building full machine translation, automatic language detection, or a server-hosted recommendation catalog in this change.
- Non-goal: supporting Flutter web targets.

## Capabilities

### New Capabilities

- `learning-languages`: Supported learning language catalog, user focus language, language labels, and capability availability across lookup and pronunciation assessment.
- `media-content-language`: Import-time and post-import editing of audio/video content language, including persistence and sync behavior.

### Modified Capabilities

- `discover`: Recommended YouTube channels and subscriptions become language-tagged, filterable, and able to default imported media language.
- `transcript-loading`: YouTube transcript resolution uses the media language instead of assuming English when the app cannot infer language from YouTube APIs.

## Impact

- Affects Flutter/Riverpod settings, library import flows, YouTube import, media edit surfaces, Discover catalog loading, Discover subscription/feed models, transcript loading, shadow reading, and Azure pronunciation assessment.
- Requires Drift DAO changes and likely schema migration/codegen for Discover subscription language metadata and media language update helpers.
- Uses existing `videos.language`, `audios.language`, `transcripts.language`, `recordings.language`, and sync serializers; new behavior should preserve valid BCP-47 tags instead of raw `und` defaults where the user has chosen a language.
- Requires localized UI strings for language pickers, media edit actions, Discover filters, and assessment-unavailable states.
- Backend/API dependency: Azure Speech pronunciation assessment supports a finite locale list; Enjoy API/worker calls must receive normalized language values and surface unsupported capability states clearly.
- Related product boundaries: ADR-0015 for YouTube playback, ADR-0019 for dictionary lookup, ADR-0021 for Discover RSS, and ADR-0013 for local-first sync.
