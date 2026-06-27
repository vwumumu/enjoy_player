# Feature: Shadow reading (echo)

## Summary

Shadow reading is the **record-while-you-listen** flow that lives below the **echo region** in the expanded player. The user listens to a cue, records themselves reading it back via the **shadow reading panel**, optionally runs **Azure pronunciation assessment** on the take, and (now) can **export a shareable practice poster** (see [`echo-mode.md`](echo-mode.md) and [`share-poster.md`](share-poster.md)).

The panel is mounted only when **echo mode is active** and the current media has a usable transcript.

## Recording bus

The recording bus is the single source of truth for "is the user recording right now":

- `ShadowReadingHotkeyBus` (a singleton bus, generated from `shadow_reading_hotkey_bus.dart`) emits typed events (`ShadowRecordingHotkeyEvent`) when the user presses the global shortcut, toggling the panel's idle toolbar state. The bus decouples the hotkey layer (which knows nothing about the panel) from the UI.
- Mic selection is persisted in `SettingsKeys.prefsRecordingInputDeviceId` and re-read on every take via `recordingInputDeviceCtrlProvider`. Unknown / virtual devices are skipped by `pickPreferredInputDeviceId` (GlideX Shared Audio, VoiceMeeter, VB-Audio CABLE, NVIDIA Broadcast, etc.) so Windows defaults don't silently capture only zeros.

## Idle toolbar (centered FAB)

- The panel shows an **idle toolbar** with the **pitch icon**, a centered **FAB** (start recording), **play**, and **pronunciation assess**. Delete moves into a **more** menu gated by a confirmation dialog.
- When recording is in flight, the panel swaps to **recording-only focus**: FAB + countdown vs the active echo segment, with the pitch chart and takes list hidden until the take is committed.
- All idle toolbar controls use **≥44×44** hit targets where possible; the assessment badge control is **44×44** with explicit `Semantics(label, button)` so VoiceOver / TalkBack see it as a control, not only a tooltip.

## Pitch contour

When the user opts in, the panel runs **pitch contour** analysis on the take:

1. `echo_segment_pcm_extractor.dart` extracts the relevant echo segment as PCM via **FFmpeg**.
2. `yin_pitch.dart` runs the **YIN** algorithm over the PCM to produce a pitch envelope.
3. `pitch_contour_chart.dart` renders the envelope; `pitch_contour_section.dart` exposes it as a collapsible section that can be **parent-driven** (`expanded`, `showHeader: false` for chart-only body).

## Pronunciation assessment (Azure)

The optional **pronunciation assessment** path runs after a take lands:

1. `recording_assessment_controller.dart` requests a **Worker Azure speech token** from Enjoy (`POST /ai/pronunciation/token`) and passes it to the native `azure_speech` plugin.
2. The plugin returns a JSON `pronunciationScore` / `accuracyScore` / `fluencyScore` / `completenessScore` plus per-word detail. The result is persisted to the recording row (`pronunciation_score`, `assessment_json`).
3. `AssessmentResultDialog` / sheet reopens the score when the user taps the score badge. The wide layout uses the **rail breakpoint** (900px), not the transcript breakpoint (720px).
4. Take menu shows per-take scores and a **Re-assess** entry when the current take already has `assessment_json`.

Silent FFmpeg WAV normalize is auto-detected and the resample chain is retried (see commit history around Azure assessment). Zero-score runs are persisted and logged.

## Related

- Echo mode (parent context): [`docs/features/echo-mode.md`](echo-mode.md)
- Share practice poster (echo-tailored export): [`docs/features/share-poster.md`](share-poster.md)
- AI capability routes (assessment, chat, translation): [`docs/features/ai.md`](ai.md)
- Native speech package: `packages/azure_speech/`
- ADR: [`docs/decisions/0005-mvp-scope-local-only.md`](../decisions/0005-mvp-scope-local-only.md) (echo + shadow reading scope)