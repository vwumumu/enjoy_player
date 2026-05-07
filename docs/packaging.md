# Packaging & platforms

## Android

### Gradle cannot download from `dl.google.com` (TLS handshake)

Symptoms: configuring `:file_picker` (or other plugins) fails resolving `com.android.tools.build:*` from Google Maven, with “TLS protocol versions” or “Remote host terminated the handshake”. That is almost always **network path** to Google (firewall, proxy, region, or broken WSL2 DNS), not a wrong Flutter version. Follow-on errors like `Configuration with name 'implementation' not found` are **cascading** after classpath resolution failed.

Mitigations:

1. **Already in repo**: [`settings.gradle.kts`](../android/settings.gradle.kts) and [`build.gradle.kts`](../android/build.gradle.kts) list **Aliyun mirrors** before `google()` so Gradle can fetch AGP artifacts without hitting `dl.google.com` first.
2. Fix the underlying network: VPN, correct proxy `gradle.properties`, or on WSL2 try a reliable DNS (e.g. `8.8.8.8` in `/etc/resolv.conf`).
3. Ensure the JDK Gradle uses is current (Java **17** matches this project).

---

- `minSdk 21` set in [`android/app/build.gradle.kts`](../android/app/build.gradle.kts).
- `INTERNET` permission declared for `media_kit` / plugin baseline ([`AndroidManifest.xml`](../android/app/src/main/AndroidManifest.xml)).
- Java 17 toolchain already configured.

## iOS

- Deployment target **13.0** in Xcode project (≥ plan minimum 12).
- Local file playback uses copied files under app sandbox.

## macOS

- Sandbox **on**; entitlements include:
  - `com.apple.security.files.user-selected.read-write` (file picker)
  - `com.apple.security.network.client` (future streaming)
- Files: [`macos/Runner/DebugProfile.entitlements`](../macos/Runner/DebugProfile.entitlements), [`Release.entitlements`](../macos/Runner/Release.entitlements).

## Windows

- Default Flutter Windows runner; `media_kit_libs_video` ships native libs.

## Release builds

```bash
flutter build apk
flutter build ios
flutter build macos
flutter build windows
```

Signing & store listings are project-specific — document secrets outside this repo.
