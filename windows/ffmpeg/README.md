# Windows FFmpeg (embedded subtitles)

Enjoy Player uses **FFmpeg** on Windows to demux embedded subtitle streams into SRT text (same role as `ffmpeg_kit_flutter_new` on other platforms). The app looks for:

1. **`ffmpeg.exe` next to `enjoy_player.exe`** (recommended for releases), or  
2. **`ffmpeg` on `PATH`** (e.g. after installing FFmpeg system-wide).

## Adding a bundled binary

1. Download a Windows build that includes `ffmpeg.exe`. The **ffmpeg-release-essentials** build from [Gyan.dev FFmpeg builds](https://www.gyan.dev/ffmpeg/builds/) is a common choice.
2. Extract **`bin/ffmpeg.exe`** from the archive.
3. Copy it to **`windows/ffmpeg/ffmpeg.exe`** in this repo.

When that file exists, **`windows/CMakeLists.txt`** installs it beside the app executable on build.

## Keeping the repo small

The executable is large; many teams **do not commit it**. Options:

- Add **`windows/ffmpeg/ffmpeg.exe`** to the root **`.gitignore`** (already listed there if your team chose this), and copy `ffmpeg.exe` into `windows/ffmpeg/` only on machines or CI jobs that produce Windows builds.
- Or commit it using **Git LFS**.

## License / redistribution

FFmpeg licensing depends on **how it was built** (LGPL vs GPL components). Before you ship `ffmpeg.exe` to end users, confirm that your chosen build and usage comply with FFmpeg’s license and your product’s legal requirements. This project does not provide legal advice.
