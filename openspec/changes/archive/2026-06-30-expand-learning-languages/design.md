## Context

Enjoy Player currently stores language in several places, but the product behavior still assumes English learning:

- `lib/core/application/app_language_catalog.dart` supports display locales plus native-language lookup labels, but `kDefaultLearningLanguageTag` is `en-US` and learning language is effectively fixed.
- `lib/core/application/app_preferences_provider.dart` coerces stored and profile learning language back to `en-US`.
- `lib/data/db/tables/videos.dart` and `lib/data/db/tables/audios.dart` already have `language`, but `lib/features/library/data/library_repository.dart` writes `und` for local and YouTube imports.
- `lib/features/transcript/data/transcript_repository.dart` requests English captions when a YouTube row language is missing or `und`.
- `assets/discover/recommended_channels.json` and `RecommendedChannel` already contain `language` and `tags`, but Discover does not use them.
- `lib/features/ai/data/azure_language_mapper.dart` maps many short tags to Azure Speech locales, but it fabricates fallback locales for unknown two-letter tags. Azure pronunciation assessment is locale-specific and supports a finite list.

The design must preserve native Android/iOS/macOS/Windows support, keep domain models UI-free, use Drift DAOs for persistence, and avoid feature-to-feature imports where shared language behavior belongs in `lib/core`.

## Goals / Non-Goals

**Goals:**

- Let users learn more than English, beginning with English, Japanese, Korean, Spanish, and French while keeping the model extensible to future BCP-47 tags.
- Support multilingual libraries where each media item can have its own content language.
- Make the user's learning language a focus/default for Discover and import suggestions, not a rule that all media must match.
- Ensure YouTube transcript requests, shadow-reading recordings, and Azure pronunciation assessment use the media language when available.
- Prevent Azure pronunciation assessment from running with unsupported or invented locales.
- Make Discover recommendations language-aware and propagate known Discover language metadata into imported YouTube media.

**Non-Goals:**

- No automatic language detection from audio, transcripts, or YouTube metadata.
- No server-hosted Discover catalog or remote editorial update pipeline.
- No guarantee that lookup, translation, transcripts, or pronunciation assessment support every valid media language.
- No Flutter web target or `kIsWeb` branching.
- No migration of historical recording assessment results from a prior wrong language.

## Decisions

### 1. Separate focus learning language from media content language

Users can keep one focus learning language in preferences/profile, but each media item stores its own content language.

```text
learning focus language
  ├─ Discover default filter
  ├─ import picker default
  └─ lookup fallback target/source defaults

media content language
  ├─ videos.language / audios.language
  ├─ YouTube transcript request language
  ├─ recording.language for new takes
  └─ Azure pronunciation assessment locale resolution
```

Rationale: the product promise is broad language learning, but a single active focus keeps onboarding and Discover simple. Users can still import and practice mixed-language media in the same library.

Rejected alternative: store multiple global learning languages immediately. That would complicate settings, Discover filtering, sync/profile semantics, and defaults before there is a clear UI need. It can be added later without changing per-media language storage.

### 2. Use a shared language catalog with capability metadata

Create or expand a core language catalog that exposes:

- canonical display label and native label;
- preferred app tag for UI/storage;
- matching aliases (`en`, `en-US`, `en-GB`, `ja`, `ja-JP`, `ko`, `kor`, `es`, `fr`);
- transcript worker base tag (`en`, `ja`, `ko`, `es`, `fr`);
- Azure pronunciation assessment locale availability;
- lookup/translation support availability when known.

Initial catalog entries should include:

| Language | Preferred tags | Azure assessment locales |
| --- | --- | --- |
| English | `en-US`, `en-GB`, `en-AU`, `en-CA`, `en-IN` | same |
| Japanese | `ja-JP` | `ja-JP` |
| Korean | `ko-KR` | `ko-KR` |
| Spanish | `es-ES`, `es-MX` | same |
| French | `fr-FR`, `fr-CA` | same |

The catalog may accept broad tags like `ja`, `ko`, `es`, and `fr` for media metadata and Discover matching. Provider calls must normalize to the provider-specific form. Korean should use canonical BCP-47/ISO 639-1 `ko`; `kor` is accepted only as an alias from user input or legacy data.

Rationale: a central catalog avoids scattered maps in settings, lookup, Discover, transcript loading, and AI assessment.

Rejected alternative: let every feature maintain its own language map. That repeats logic and makes it easy for YouTube transcripts, Azure assessment, and UI labels to disagree.

### 3. Treat provider features as capabilities, not language validity

A valid media language does not imply every downstream service supports it. Pronunciation assessment must resolve to one of Azure's supported locales before the button can run. Unsupported locales should produce a disabled action or clear unavailable notice, not a fallback to English or a fabricated locale.

Rationale: Azure documentation lists a finite set of pronunciation assessment locales and says the default is `en-US`; running Japanese media through `en-US` gives misleading scores.

Rejected alternative: fallback to `en-US` for unsupported language. This preserves button availability but violates user trust and hides incorrect assessments.

### 4. Prompt and edit media language through existing media surfaces

Import flows should ask for language before inserting local media or YouTube media:

- local file import: default to focus learning language, allow "Unknown" when the user is not sure;
- YouTube URL import: require or strongly prompt for language because YouTube APIs used by the app do not provide original language;
- Discover add-to-library: default to channel/subscription language when available and allow override later.

Existing records need an edit action from Library and/or the player metadata surface. Updating language should:

- write through `VideoDao`/`AudioDao` partial update methods;
- bump `updatedAt`;
- enqueue sync update when signed in;
- refresh visible media streams;
- update the active playback session or clearly require reopening if an item is already open.

Rationale: wrong language mostly hurts downstream behavior after import, so users need both import-time and correction-time control.

Rejected alternative: only add a settings-level learning language picker. That does not solve mixed libraries, YouTube transcript language, or old records.

### 5. Preserve transcript row language separately from media language

Transcript rows keep their own `transcripts.language`; changing media language does not rewrite existing transcript IDs. The media language controls future YouTube worker requests and default language suggestions. User-imported subtitle language remains explicit per track.

If a YouTube row language changes, transcript fetch state should allow retry for the new language. Existing transcript tracks can remain until the user deletes or switches them.

Rationale: transcripts are concrete artifacts with their own source and language. Re-keying them on media edit risks data loss and broken echo-session references.

Rejected alternative: migrate all transcript rows when media language changes. That conflates metadata correction with transcript provenance.

### 6. Make Discover language-aware at channel/subscription level

The bundled recommended catalog remains the source of editorial recommendations in this change. The existing `language` and `tags` fields become active:

- recommended channel lists can filter/group by focus learning language;
- subscriptions created from recommended channels persist `language`;
- feed entries can inherit subscription/channel language for filtering and import defaults;
- user-pasted subscriptions may default to unknown or the current focus language, with an edit path if needed.

Rationale: YouTube RSS does not provide reliable per-video language. Channel-level metadata is a pragmatic first layer, with manual media edit as the correction mechanism.

Rejected alternative: scrape or infer video-level language from YouTube pages. That would be fragile, platform-sensitive, and outside the local-first RSS design in ADR-0021.

## Risks / Trade-offs

- [Risk] Users may expect "learn any language" to mean all AI services work for every language. → Mitigation: surface capability labels and unavailable states for pronunciation assessment, lookup, translation, and transcript sources.
- [Risk] Existing rows with `und` continue to request English captions. → Mitigation: prompt users to set language on YouTube media with unknown language before transcript fetch or when fetch returns empty.
- [Risk] Broad tags like `es` hide regional pronunciation differences. → Mitigation: store exact locale when the user chooses one, default broad tags to a documented preferred locale only when a provider requires it, and expose regional options for Azure-sensitive languages.
- [Risk] Changing a media language while the player is open can leave stale `PlaybackSession.language`. → Mitigation: update session state when possible; otherwise show a lightweight notice that new language behavior applies after reopening.
- [Risk] Discover channel language may be wrong for multilingual channels. → Mitigation: treat channel language as a default, not a final truth; allow per-media override after import.
- [Risk] Server profile or cloud sync may reject new learning language values. → Mitigation: coordinate profile API expectations before enabling server sync for non-English focus languages; keep local preference authoritative if server support lags.

## Migration Plan

1. Add the shared language catalog and replace scattered label/mapping constants where needed.
2. Expand preference/profile handling so `learningLanguage` can store the selected focus language instead of being coerced to `en-US`.
3. Add media language update DAO/repository methods for videos and audios; run Drift codegen if schema or DAO annotations require it.
4. Add import-time language pickers and existing-record edit entry points.
5. Replace YouTube transcript fallback behavior with media-language-driven requests and retry behavior when language changes.
6. Replace Azure pronunciation mapping fallback with explicit supported-locale resolution and unavailable states.
7. Extend Discover recommended catalog entries, subscription persistence, feed filtering/import defaults, and UI language filters.
8. Update docs/features for settings, library, YouTube, transcript, Discover, and shadow reading.

Rollback is mostly behavioral: disable new pickers/filters and keep persisted language tags in place. Schema additions to Discover subscriptions/feed metadata should be nullable or default to `und` so older rows remain valid.

## Open Questions

- Should YouTube import require a language selection, or allow "Unknown" with a later prompt before transcript fetch?
- Should the focus language picker expose regional variants immediately for English/Spanish/French, or keep a simple language-first list with advanced locale choices only for pronunciation assessment?
- Should lookup/translation capability be expanded in the same implementation pass or only capability-gated until backend support is confirmed?
- Should Discover support multi-language filters now, or only filter by the single focus learning language plus "All"?
