# Feature: Dictionary lookup (transcript)

## Summary

While playback is open, the user can **select 1–100 characters** on the **active** transcript cue or on any cue inside the **echo window**. A **bottom sheet** opens automatically (debounced) with:

1. **Translation** — `POST /translations` via `translationServiceProvider`.
2. **Contextual translation** — LLM markdown via `POST /chat/completions` through `contextualTranslationServiceProvider` (system prompts aligned with web `contextual-translation`); includes optional **surrounding transcript context** from `buildVocabularyContext`.
3. **Dictionary** — `POST /dictionary/query` via `dictionaryServiceProvider` (word = selected text only).

## UX rules

- **Tap-to-seek** is **disabled** on selectable rows (active + echo cues); other rows behave as before.
- **Selection toolbar** is suppressed on transcript selections; the sheet is the primary affordance.
- **Translation** section is expanded on first open and fetches immediately. **Contextual** and **Dictionary** start **collapsed** — expand once to fetch (saves credits vs eager triple fetch).

## Code map

| Area | Path |
|------|------|
| Open sheet from transcript | [`lib/features/lookup/application/transcript_lookup_open.dart`](../../lib/features/lookup/application/transcript_lookup_open.dart) |
| Context builder | [`lib/features/lookup/application/vocabulary_context_builder.dart`](../../lib/features/lookup/application/vocabulary_context_builder.dart) |
| Sheet UI | [`lib/features/lookup/presentation/dictionary_lookup_sheet.dart`](../../lib/features/lookup/presentation/dictionary_lookup_sheet.dart) |
| Section async providers | [`lib/features/lookup/application/lookup_section_providers.dart`](../../lib/features/lookup/application/lookup_section_providers.dart) |
| Selectable cue row | [`lib/features/transcript/presentation/transcript_line_tile.dart`](../../lib/features/transcript/presentation/transcript_line_tile.dart) |

## Related

- ADR: [`docs/decisions/0019-transcript-dictionary-lookup.md`](../decisions/0019-transcript-dictionary-lookup.md)
- AI routes: [`docs/features/ai.md`](ai.md)
- Transcript panel: [`docs/features/transcript.md`](transcript.md)
