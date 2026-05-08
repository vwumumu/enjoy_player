# Feature: Transcript

## MVP behavior

- Primary transcript = first row returned by `TranscriptDao.watchForMedia`.
- Import `.srt` / `.vtt` via `SubtitleParserFacade` storing JSON in `lines_json`.
- Tap line → seek + optional echo region update (via `PlayerInteractions`).
- **Track / import entry**: Use the player **CC** control (opens subtitle sheet). The transcript panel has no duplicate header row.
- Subtitle track picker uses shared bottom-sheet theming and spacing from `EnjoyThemeTokens`.
- **Windows fallback**: Embedded subtitle auto-extraction is disabled on Windows in current builds (ffmpeg plugin gap); users can still import external `.srt` / `.vtt`.
- **Markup**: SSA/HTML-like cues (`<font color="…">`, `<b>`, `<i>`, `<br>`, etc.) are parsed in the transcript panel via `parseSubtitleMarkup` (`lib/data/subtitle/subtitle_markup_parser.dart`); colors and styles render as rich text instead of raw tags.
- **Line UI**: Each cue shows a **timestamp** (cue start). Row backgrounds are **transparent** by default; **hover** and **active playback** (and echo-range highlighting) apply tinted backgrounds only for those states.

## Future

- Multiple languages, editing timelines, auto-translate, export — parity with web `TranscriptDisplay`.
