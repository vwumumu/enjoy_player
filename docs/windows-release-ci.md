# Windows release CI setup

Guide for configuring [`.github/workflows/release_windows.yml`](../.github/workflows/release_windows.yml) on GitHub.

The workflow currently runs on **GitHub-hosted** `windows-latest` (same as [Build Windows smoke](../.github/workflows/build_windows.yml)). When your self-hosted Windows runner is ready, change `runs-on` to `[self-hosted, Windows]` in the workflow file.

## What the release workflow does

1. `flutter analyze` + `flutter test`
2. Builds **Windows release** (`flutter build windows --release`)
3. Syncs **Inno Setup** `AppVersion` from `pubspec.yaml`
4. Builds **EnjoyPlayerSetup.exe** installer (optional on manual runs)
5. Uploads **artifacts** (release folder zip + optional installer) to the GitHub Actions run

**Triggers**

- Push a version tag: `git tag v1.0.0 && git push origin v1.0.0`
- Manual: GitHub → Actions → **Release Windows** → **Run workflow**

---

## Step 1 — Prerequisites

On the machine that runs the workflow (GitHub-hosted or self-hosted):

- **Flutter** (pinned via [`.github/flutter-version`](../.github/flutter-version))
- **NuGet CLI** on `PATH` (WebView2 restore) — smoke workflow runs [`ensure_nuget_feed.ps1`](../.github/scripts/ensure_nuget_feed.ps1)
- **Inno Setup 6** — release workflow installs via Chocolatey on GitHub-hosted runners if `iscc` is missing; on self-hosted, install from [jrsoftware.org](https://jrsoftware.org/isinfo.php) and add `ISCC.exe` to `PATH`

### Optional: bundled FFmpeg

For full embedded-subtitle support, place **`windows/ffmpeg/ffmpeg.exe`** before the build (see [windows/ffmpeg/README.md](../windows/ffmpeg/README.md)). The workflow logs a warning if it is missing but still produces a release.

On a self-hosted runner, copy `ffmpeg.exe` once to `windows/ffmpeg/` on disk. Do not commit large binaries unless using Git LFS.

---

## Step 2 — GitHub Secrets

No secrets are required for unsigned release builds. **Authenticode signing** stays outside this repo — sign `EnjoyPlayerSetup.exe` locally with `signtool` or Inno Sign Tools after downloading the artifact.

---

## Step 3 — Self-hosted runner (optional)

When migrating off `windows-latest`:

1. Register runner with labels `self-hosted`, `Windows` (see [ci-self-hosted-runners.md](ci-self-hosted-runners.md)).
2. Install Flutter, NuGet, Inno Setup, and optionally `windows/ffmpeg/ffmpeg.exe`.
3. Edit [`release_windows.yml`](../.github/workflows/release_windows.yml): `runs-on: [self-hosted, Windows]`.

---

## Step 4 — Run a release

### Manual test (no tag)

1. Bump `version:` in `pubspec.yaml` if needed.
2. GitHub → **Actions** → **Release Windows** → **Run workflow**.
3. Toggle **Build Inno Setup installer** as needed.
4. Download artifacts:
   - `windows-release-vX.Y.Z` — `Release/` folder (portable zip contents)
   - `windows-installer-vX.Y.Z` — `EnjoyPlayerSetup.exe` (when installer step ran)

### Tag release

```bash
git tag v1.0.0
git push origin v1.0.0
```

Tag pushes always build the **installer** and upload both artifact types.

---

## Code signing (manual, post-CI)

After downloading `EnjoyPlayerSetup.exe`:

```powershell
signtool sign /fd SHA256 /a "EnjoyPlayerSetup.exe"
```

Configure certificate thumbprint or HSM details per your vendor. See [windows/installer/README.md](../windows/installer/README.md).

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| *nuget is not on PATH* | Install NuGet CLI on self-hosted runner |
| *iscc not found* | Install Inno Setup 6; re-run or rely on Chocolatey step on GitHub-hosted |
| Missing subtitles on end-user machines | Bundle `windows/ffmpeg/ffmpeg.exe` before `flutter build windows` |
| WebView2 errors at runtime | End users need [WebView2 Runtime](https://developer.microsoft.com/microsoft-edge/webview2/) |

---

## Local release (without CI)

Same commands, documented in [packaging.md](packaging.md):

```bash
flutter build windows --release
iscc windows\installer\enjoy_player.iss
```
