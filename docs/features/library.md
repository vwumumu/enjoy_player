# Feature: Library

## MVP behavior

- List media from Drift `videos` / `audios` tables (newest first).
- **Local video thumbnails**: after import, a JPEG poster is written under app documents `media_thumbs/<content-hash>.jpg` and the absolute path is stored in `thumbnail_url`. The frame is taken at **~12% of the container duration** (at least ~2.5s from the start, capped at 90s) so intro blacks, logos, and keyframe-only early seconds are avoided; when duration is not yet known, **~6s** is used. Short clips use a fraction of their length. Seeking uses accurate decode for targets within **45s** of the file start (bounded cost), and fast input seek beyond that. Extraction uses FFmpeg subprocess on Windows (bundled `ffmpeg.exe` or PATH) and FFmpegKit elsewhere. If extraction fails or FFmpeg is unavailable, items **without a local thumbnail** show a deterministic **generative cover** (gradient + pattern) seeded by content hash, matching the web library’s `GenerativeCover` behavior. If an old JPEG is still wrong, delete `media_thumbs/<md5>.jpg` for that item’s fingerprint and restart once so backfill can retry.
- **Older videos** (imported before thumbnails existed, or after a reinstall if DB was restored without files): on first main-shell frame after launch, the app runs a **one-time backfill** that walks local `videos` rows with `local_uri` + `md5`, skips remote `thumbnail_url` and rows whose local thumb file already exists, and attempts the same JPEG extraction. Rows without a local file (`local_uri` missing) are unchanged until you relocate or re-import.
- Import: pick a file (`FileType.media`), show a non-dismissible **Importing media…** dialog, copy and hash the file in a **background isolate** via `FileStorage` (UI stays responsive), insert row, dismiss the dialog, then navigate to `/player/:id`. On failure, the dialog closes and a **SnackBar** explains the error. Entry point is the **toolbar +** action on Library and the empty-state primary button.
- **Navigation**: Library and Settings are reached from the persistent shell (`NavigationBar` on compact widths, `NavigationRail` from ~900px when not on the player route).

## Home

- When **signed in**, the Home screen shows a **Today's Goal** card (practice minutes vs. profile goal from `GET /api/v1/mine/stats` and `UserProfile.goal`, default 30) and a **Community activity** card in a **responsive two-column row** on wide viewports (≈720px+), or a **stacked column** on narrow screens. The block is **above** the recent media grid. Signed-out users do not see these cards.
- **Community activity** loads `GET /api/v1/users/active` with the device timezone.

## Future

- Metadata editing, delete swipe, search filters.
