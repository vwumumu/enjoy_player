# Contract: Auto-Translate Per-Line Requests

**Feature**: [spec.md](../spec.md) · **Plan**: [plan.md](../plan.md) · **Data model**: [data-model.md](../data-model.md)

Application-level contract for `AutoTranslateCtrl` and its use of the existing
translation capability. No new public HTTP surface is added; this documents the
**client orchestration** contract tests must pin.

## Translation capability (existing)

Each line uses the existing service façade:

```text
translationService.translate(
  text: <primary line plain text>,
  sourceLanguage: <primary track language>,
  targetLanguage: <effective native language>,
  forceRefresh: <true only on explicit Re-translate line pass when needed>,
)
```

- Wire path remains Enjoy `POST /translations` or BYOK translation capability
  per modality routing (ADR-0014, ADR-0033).
- Languages sent to Enjoy worker MUST use base codes via `workerLanguageBase`.
- Markup: strip subtitle markup to plain text before translate; store plain
  translated text in the AI timeline (v1).

## Request rules (viewport-driven)

| Rule | Requirement |
|------|-------------|
| S1 | Selecting Auto translate only ensures the AI track + sets secondary; it does **not** sweep the whole transcript |
| S2 | The transcript list calls `requestTranslateLine(index)` when a built row has empty AI text |
| S3 | `requestTranslateLine` is idempotent: no-op if cached, in-flight, failed, or Auto translate inactive |
| S4 | Max **2** concurrent in-flight translate calls per media |
| S5 | Per-line: up to **2** attempts (initial + one quiet retry); then mark failed until explicit re-translate |
| S6 | `AuthFailure` / `CreditsFailure` set status `blocked` with friendly reason; stop new requests |
| S7 | Successful line → write text into AI `timelineJson` at that index → upsert |
| S8 | Empty text = pending; non-empty = ready (UI). Show “Translating…” only while that index is in-flight |
| S9 | Selecting away from Auto translate clears secondary; in-flight completions no-op if secondary ≠ AI |
| S10 | Stale primary (`referenceId` / fingerprint mismatch) must not present old AI text as valid without rebuild |
| S11 | No media-close / reopen job lifecycle — cache in Drift is enough for display |

## Progressive persistence

1. Ensure AI row + full timing skeleton before first display as secondary.
2. Upsert after each success so process death loses at most the in-flight set.
3. Reopen: load AI timeline; request translate only for empty lines that enter the viewport again.

## Observability

- Log via `logNamed` (block reasons, retry exhaustion) — never `print`.
- Do not surface raw exception strings as primary UI copy.

## Test doubles

Unit tests MUST inject a fake `TranslationCapability` / `TranslationService`
that can:

- delay, fail transiently, fail permanently, or succeed per line index;
- assert concurrency never exceeds 2;
- assert a second `requestTranslateLine` for an in-flight or ready line does not double-call.
