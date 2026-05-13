# ADR-0019: Transcript dictionary lookup (selection + bottom sheet)

## Status

Accepted

## Context

Language learners need quick **translation**, **contextual explanation**, and **dictionary** entries while reading transcripts, matching the web app’s `TextSelectionPanel` behavior. The Enjoy worker already exposes `/translations`, `/chat/completions`, and `/dictionary/query` (see ADR-0014).

## Decision

1. **Selection scope** — Only the **currently active** transcript cue and cues inside the **echo window** are selectable. Other cues keep **tap-to-seek** and non-selectable text (web parity: `select-none` elsewhere).
2. **Interaction** — `SelectableText.rich` with markup parity; **no `InkWell` seek** when selectable. After the user finishes a selection (`SelectionChangedCause.drag` or `longPress`), a **200 ms debounce** fires; trimmed length must be **1–100** characters before opening the sheet.
3. **Context for LLM** — `buildVocabularyContext` mirrors the web vocabulary builder: echo region with **≥ 2 lines** uses joined cue text; otherwise **±3 line expansion** plus **sentence-boundary** trimming for contextual translation only.
4. **Presentation** — Results open in a **modal bottom sheet** (`DraggableScrollableSheet` + shared drag handle) with three **expandable** sections: **Translation** (loads immediately when expanded), **Contextual translation** (markdown via `flutter_markdown`; collapsed by default to save credits), **Dictionary** (collapsed by default). Dictionary calls use **selected text only** (no extra context payload), matching web.
5. **Languages** — **Source** = `PlaybackSession.language` (BCP-47 from media / transcript). **Target** = learner **native language** from `AppPreferencesCtrl` (`effectiveNativeLanguage`).
6. **Architecture** — New `lib/features/lookup/` feature slice (`application` / `domain` / `presentation`). Contextual translation is a dedicated **capability** over existing `LlmCapability` (`EnjoyContextualTranslationCapability`) plus `contextualTranslationServiceProvider`.

## Consequences

- **Credits / latency**: Lazy expansion for contextual + dictionary reduces accidental spend; users must expand those sections once per lookup.
- **Toolbar**: Default selection **context menu is suppressed** on transcript selections (sheet auto-opens); users can still use selection handles.
- **Follow-ups**: External links, add-to-vocabulary, TTS on selection, and pausing playback when the sheet opens are intentionally **out of scope** for this ADR.
