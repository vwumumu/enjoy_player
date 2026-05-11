# Feature: Echo mode (shadow reading)

## MVP behavior

- Echo region stores line indices + start/end times (seconds).
- `normalizeEchoWindow`, `clampSeekTimeToEchoWindow`, `decideEchoPlaybackTime` match web `echo-utils.ts` semantics (segment end **pauses** and rewinds to segment start for replay — not auto-loop).
- `PlayerController` applies clamp / pause-and-rewind while echo active.
- State persisted in `echo_sessions` (latest session per `targetType` + `targetId`).
- **Shadow reading**: below the echo region, [`ShadowReadingPanel`](../../lib/features/shadow_reading/presentation/shadow_reading_panel.dart) supports mic recording (saved to `recordings`), **compact UI** (saved-take row only when takes exist; pitch collapsible without redundant labels), **play/pause** on the dedicated **`media_kit`** preview player ([`recording_preview_player`](../../lib/core/audio/recording_preview_player.dart)), optional **pitch contour** analysis (FFmpeg PCM extract + YIN envelope — see `shadow_reading/`), and a **segment-duration countdown ring** around record while capturing (warning only past target; no auto-stop).
- **Transcript**: while echo is active, only cues inside the current echo segment show the “active line” highlight (avoids gap/overlap confusing a cue outside the brown region). Tapping another cue still seeks/plays from that cue and recenters the echo segment on it (`PlayerInteractions._seekLine`).

## Future

- Multi-line echo regions with draggable selection UI.
- Cloud pronunciation assessment (web parity).
