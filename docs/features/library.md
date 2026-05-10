# Feature: Library

## MVP behavior

- List media from Drift `videos` / `audios` tables (newest first).
- **Local video thumbnails**: after import, a JPEG poster is written under app documents `media_thumbs/<content-hash>.jpg` and the absolute path is stored in `thumbnail_url`. The frame is taken at **~12% of the container duration** (at least ~2.5s from the start, capped at 90s) so intro blacks, logos, and keyframe-only early seconds are avoided; when duration is not yet known, **~6s** is used. Short clips use a fraction of their length. Seeking uses accurate decode for targets within **45s** of the file start (bounded cost), and fast input seek beyond that. Extraction uses FFmpeg subprocess on Windows (bundled `ffmpeg.exe` or PATH) and FFmpegKit elsewhere. For **https `media_url`** (cloud-only rows), ffmpeg is invoked with an explicit **protocol whitelist** so remote MP4s can yield a poster. If extraction fails or FFmpeg is unavailable, items **without a local thumbnail** show a deterministic **generative cover** (gradient + pattern) seeded by content hash, matching the web library’s `GenerativeCover` behavior. When `thumbnail_url` is already an **`http(s)`** URL from the server, library/home tiles load it with **`Image.network`** (no local JPEG required). If an old JPEG is still wrong, delete `media_thumbs/<md5>.jpg` for that item’s fingerprint and restart once so backfill can retry.
- **Older videos** (imported before thumbnails existed, or after a reinstall if DB was restored without files): on first main-shell frame after launch, the app runs a **one-time backfill** that walks local `videos` rows, skips rows that already use a remote `http(s)` [VideoRow.thumbnailUrl] or a readable local file, then for each remaining row uses [VideoRow.localUri] when set **or** [VideoRow.mediaUrl] (cloud-only / streaming metadata) to build `media_thumbs/<key>.jpg` and patch `thumbnail_url`. Rows with neither URI are unchanged until you relocate or re-import.
- Import: pick a file (`FileType.media`), show a non-dismissible **Importing media…** dialog, copy and hash the file in a **background isolate** via `FileStorage` (UI stays responsive), insert row, dismiss the dialog, then navigate to `/player/:id`. On failure, the dialog closes and a **SnackBar** explains the error. Entry point is the **toolbar +** action on Library and the empty-state primary button.
- **Navigation**: Library and Settings are reached from the persistent shell (`NavigationBar` on compact widths, `NavigationRail` from ~900px when not on the player route).
- **Delete**: Home and Library media cards expose **Delete** (trash icon on tile thumbnails; audio list shows delete beside the chevron) **on pointer hover only**. Choosing delete opens a confirmation dialog; confirming removes the row locally via `MediaLibraryRepository.deleteMedia`, enqueues cloud sync delete when signed in, and closes the expanded player route if that item was open.

## Home

- When **signed in**, the Home screen shows a **Today's Goal** card (practice minutes vs. profile goal from `GET /api/v1/mine/stats` and `UserProfile.goal`, default 30) and a **Community activity** card in a **responsive two-column row** on wide viewports (≈720px+), or a **stacked column** on narrow screens. The block is **above** the recent media grid. Signed-out users do not see these cards.
- **Community activity** loads `GET /api/v1/users/active` with the device timezone.

## Future

- Metadata editing, search filters.
