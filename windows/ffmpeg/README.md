# Windows FFmpeg (embedded subtitles)

Enjoy Player uses **FFmpeg** on Windows to demux embedded subtitle streams into SRT text (same role as `ffmpeg_kit_flutter_new` on other platforms). The app looks for:

1. **`ffmpeg.exe` next to `enjoy_player.exe`** (recommended for releases), or  
2. **`ffmpeg` on `PATH`** (e.g. after installing FFmpeg system-wide).

## Bundled binary (recommended)

From the repository root:

```powershell
pwsh windows/scripts/fetch_ffmpeg.ps1
```

The script downloads the **ffmpeg-release-essentials** build from [Gyan.dev FFmpeg builds](https://www.gyan.dev/ffmpeg/builds/), verifies the published SHA-256 checksum, and writes **`windows/ffmpeg/ffmpeg.exe`**. Re-run with `-Force` to refresh. CI runs the same script before Windows builds.

When that file exists, **`windows/CMakeLists.txt`** installs it beside the app executable on build.

## Manual fallback

If you cannot use the script (offline, mirror policy, etc.):

1. Download a Windows build that includes `ffmpeg.exe` (essentials build from Gyan.dev is a common choice).
2. Extract **`bin/ffmpeg.exe`** from the archive.
3. Copy it to **`windows/ffmpeg/ffmpeg.exe`** in this repo.

## Keeping the repo small

The executable is large; many teams **do not commit it**. Options:

- **`windows/ffmpeg/ffmpeg.exe`** is listed in the root **`.gitignore`** — fetch it locally or let CI download it before release builds.
- Or commit it using **Git LFS**.

## License / redistribution

FFmpeg licensing depends on **how it was built** (LGPL vs GPL components). Before you ship `ffmpeg.exe` to end users, confirm that your chosen build and usage comply with FFmpeg’s license and your product’s legal requirements. This project does not provide legal advice.
