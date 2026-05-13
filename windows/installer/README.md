# Windows installer (Inno Setup)

1. Install [Inno Setup 6](https://jrsoftware.org/isinfo.php) and ensure `iscc.exe` is on `PATH`.
2. From repo root, build the release runner (optionally place `windows/ffmpeg/ffmpeg.exe` first — see [packaging.md](../../docs/packaging.md)):
   ```bash
   flutter build windows --release
   ```
3. Compile the installer:
   ```bash
   iscc windows\installer\enjoy_player.iss
   ```
4. Output: `build/windows/installer/EnjoyPlayerSetup.exe` (unsigned unless you add signing).

Before shipping, update `AppVersion` in `enjoy_player.iss` to match `pubspec.yaml`.

## Code signing

Configure Inno’s **Sign Tools** or run `signtool` on `EnjoyPlayerSetup.exe` per your certificate vendor. Secrets and thumbprints stay outside this repo.
