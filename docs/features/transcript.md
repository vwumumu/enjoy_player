# Feature: Transcript

## MVP behavior

- Primary transcript = `echo_sessions.transcript_id` for the latest session on `(targetType, targetId)` (same id as library media row).
- Import `.srt` / `.vtt` via `SubtitleParserFacade` storing JSON in `transcripts.timeline_json`.
- Tap line → seek + optional echo region update (via `PlayerInteractions`).
- **Track / import entry**: Use the player **CC** control (opens subtitle sheet). The transcript panel has no duplicate header row.
- Subtitle track picker uses shared bottom-sheet theming and spacing from `EnjoyThemeTokens`.
- **Windows embedded subtitles**: Demux uses **`ffmpeg.exe`** next to `enjoy_player.exe` (installed from [`windows/ffmpeg/ffmpeg.exe`](../../windows/ffmpeg/ffmpeg.exe) when present at build time) or **`ffmpeg` on PATH**. If neither is available, embedded auto-extraction no-ops; users can still import `.srt` / `.vtt`. Details: [`windows/ffmpeg/README.md`](../../windows/ffmpeg/README.md).
- **On-video subtitles**: Disabled by default (`SubtitleTrack.no()` after open + `SubtitleViewConfiguration.visible: false` on [`Video`](../../lib/features/player/presentation/layouts/video_player_layout.dart)); cues are shown in the transcript panel instead.
- **Markup**: SSA/HTML-like cues (`<font color="…">`, `<b>`, `<i>`, `<br>`, etc.) are parsed in the transcript panel via `parseSubtitleMarkup` (`lib/data/subtitle/subtitle_markup_parser.dart`); colors and styles render as rich text instead of raw tags.
- **Line UI**: Each cue has a **header row** (timestamp first; room for more labels). Body text follows on the next lines. Row backgrounds are **transparent** by default; **hover**, **active playback**, **echo-range**, and **active inside echo** use distinct tints (playback within the echo region blends echo orange with primary vs plain active vs echo-only lines).
- **Auto-follow**: While the engine is **playing**, the list scrolls the **active cue** into view when it would be off-screen (`Scrollable.ensureVisible` on the active line). When paused, the list does not auto-scroll.
- **Echo region controls** (echo mode on): **Expand / shrink** bars appear above the first and below the last cue in the echo segment (mirrors web `EchoRegionControls`); they update `EchoMode` line bounds and times only (full A–B loop / seek sync with the engine is future work).
- **Shadow reading zone** (echo mode on): A **placeholder** card below the echo block shows a short hint and an optional **reference** snippet from the echo-range text; recording and analysis are not implemented yet.

## Future

- Multiple languages, editing timelines, auto-translate, export — parity with web `TranscriptDisplay`.
