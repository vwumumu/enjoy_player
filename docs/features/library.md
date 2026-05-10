# Feature: Library

## MVP behavior

- List media from Drift `videos` / `audios` tables (newest first).
- **Local video thumbnails**: after import, a JPEG poster (~1s) is written under app documents `media_thumbs/<content-hash>.jpg` and the absolute path is stored in `thumbnail_url`. Extraction uses FFmpeg subprocess on Windows (bundled `ffmpeg.exe` or PATH) and FFmpegKit elsewhere. If extraction fails or FFmpeg is unavailable, items **without a local thumbnail** show a deterministic **generative cover** (gradient + pattern) seeded by content hash, matching the web library’s `GenerativeCover` behavior.
- Import: pick a file (`FileType.media`), show a non-dismissible **Importing media…** dialog, copy and hash the file in a **background isolate** via `FileStorage` (UI stays responsive), insert row, dismiss the dialog, then navigate to `/player/:id`. On failure, the dialog closes and a **SnackBar** explains the error. Entry point is the **toolbar +** action on Library and the empty-state primary button.
- **Navigation**: Library and Settings are reached from the persistent shell (`NavigationBar` on compact widths, `NavigationRail` from ~900px when not on the player route).

## Home

- When **signed in**, the Home screen shows a **Today's Goal** card (practice minutes vs. profile goal from `GET /api/v1/mine/stats` and `UserProfile.goal`, default 30) and a **Community activity** card in a **responsive two-column row** on wide viewports (≈720px+), or a **stacked column** on narrow screens. The block is **above** the recent media grid. Signed-out users do not see these cards.
- **Community activity** loads `GET /api/v1/users/active` with the device timezone.

## Future

- Metadata editing, delete swipe, search filters.
