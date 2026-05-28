# Windows installer (Inno Setup)

1. Install [Inno Setup 6+](https://jrsoftware.org/isinfo.php). During setup, enable **“Add Inno Setup directory to the PATH”**, or from repo root run:
   ```powershell
   pwsh .github/scripts/ensure_inno_setup.ps1
   ```
   (adds the compiler directory to PATH for the current session; restart the terminal for a permanent user PATH change via Windows Settings if you skipped the installer checkbox).
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
