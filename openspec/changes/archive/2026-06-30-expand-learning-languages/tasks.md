## 1. Language Catalog And Preferences

- [x] 1.1 Expand `app_language_catalog.dart` into a shared catalog with labels, aliases, broad-tag matching, focus-language options, media-language options, and provider capability metadata.
- [x] 1.2 Replace English-only learning-language coercion in `app_preferences_provider.dart` with validation against supported focus languages.
- [x] 1.3 Update profile/settings language controls to allow changing the focus learning language and syncing it when signed in.
- [x] 1.4 Add localized strings for first-wave language labels, Unknown language, focus-language copy, and feature-unavailable messages.
- [x] 1.5 Add unit tests for language normalization, `ko`/`kor` alias handling, broad-tag matching, and focus/native language coercion.

## 2. Media Language Persistence

- [x] 2.1 Add repository/DAO methods to update video and audio content language with `updatedAt` changes and sync enqueue behavior.
- [x] 2.2 Update local media import to accept a selected content language and persist it on created `videos`/`audios` rows.
- [x] 2.3 Update manual YouTube import to collect a content language and persist it on created `videos` rows.
- [x] 2.4 Add or update media edit UI entry points so existing local audio, local video, and YouTube records can change language.
- [x] 2.5 Ensure active player metadata/session behavior is refreshed or clearly notifies the user after changing the open media language.
- [x] 2.6 Add repository and widget tests covering import-time language persistence, existing-row edits, sync enqueue, and unknown-language behavior.

## 3. Transcript And Shadow Reading Behavior

- [x] 3.1 Update YouTube transcript language resolution to use media content language and avoid treating `und` as confirmed English.
- [x] 3.2 Reset or invalidate transcript fetch state when a YouTube media language changes so corrected-language fetches can retry.
- [x] 3.3 Preserve existing transcript row language values when media language changes.
- [x] 3.4 Ensure new shadow-reading recordings are stamped with the active media language and historical recordings are not rewritten.
- [x] 3.5 Add tests for YouTube worker language selection, unknown-language fetch handling, retry after language correction, and recording language stamping.

## 4. Azure Pronunciation Assessment Capabilities

- [x] 4.1 Replace fallback-based Azure locale mapping with explicit supported-locale resolution from the shared language catalog.
- [x] 4.2 Update pronunciation assessment flow and controls to disable or explain assessment when media/recording language has no supported Azure locale.
- [x] 4.3 Preserve exact supported regional locales such as `en-US`, `en-GB`, `es-ES`, `es-MX`, `fr-FR`, and `fr-CA` when calling Azure Speech.
- [x] 4.4 Add tests proving unknown, invalid, and unsupported languages do not assess as `en-US`.

## 5. Discover Language Support

- [x] 5.1 Expand `recommended_channels.json` with curated first-wave English, Japanese, Korean, Spanish, and French channel entries and editorial tags.
- [x] 5.2 Persist language metadata on recommended-channel subscriptions and provide an edit/default path for user-pasted subscriptions.
- [x] 5.3 Add Discover recommendation/feed filtering or prioritization by focus learning language with an All languages escape hatch.
- [x] 5.4 Propagate known subscription/channel language into Discover add-to-library imports as the media language default.
- [x] 5.5 Add tests for catalog loading, subscription language persistence, Discover filtering, and add-to-library language defaults.

## 6. Documentation And Product Copy

- [x] 6.1 Update `docs/features/settings.md` for focus learning language behavior and provider capability limitations.
- [x] 6.2 Update `docs/features/library.md` and `docs/features/youtube.md` for import/edit media language behavior.
- [x] 6.3 Update `docs/features/transcript.md` for YouTube transcript language selection and retry after language correction.
- [x] 6.4 Update `docs/features/discover.md` for language-tagged recommendations and subscription/import defaults.
- [x] 6.5 Update `docs/features/shadow-reading.md` or `docs/features/ai.md` for Azure pronunciation assessment locale gating.

## 7. Verification

- [x] 7.1 Run code generation after Drift or Riverpod changes: `dart run build_runner build`.
- [x] 7.2 Run `flutter analyze`.
- [x] 7.3 Run focused tests for language catalog, library repository/imports, transcript loading, Azure assessment, Discover, and settings.
- [x] 7.4 Run the full Flutter test suite with `flutter test`.
- [ ] 7.5 Manually smoke-test local import, YouTube import, existing media language edit, Discover add-to-library, transcript retry, and assessment unavailable/supported states.
