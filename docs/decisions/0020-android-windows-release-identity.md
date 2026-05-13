# ADR-0020: Android application ID and release signing defaults

## Status

Accepted

## Context

The Android module shipped with `com.example.enjoy_player` and release builds signed with the **debug** keystore. That blocks Google Play upload and is misleading for sideloading. Windows `Runner.rc` used placeholder `com.example` publisher metadata. We need stable, non-example identifiers and a standard way to attach upload keys without committing secrets.

## Decision

1. **Android `applicationId` / `namespace`**: `ai.enjoy.player`, with `MainActivity` in the matching Kotlin package path.
2. **Android release signing**: If `android/key.properties` exists (gitignored), Gradle uses a **`release`** signing config loaded from that file. If it is absent (local dev / CI without secrets), **`release` build type falls back to the debug keystore** so `flutter build apk/appbundle --release` still compiles; **those artifacts must not be uploaded to Play**.
3. **Windows**: Replace placeholder `com.example` **CompanyName** / **LegalCopyright** in `Runner.rc` with neutral **Enjoy** branding; installer packaging uses **Inno Setup** under `windows/installer/` (see [packaging.md](../packaging.md)).

## Consequences

- Changing `applicationId` after any public install is painful; treat `ai.enjoy.player` as stable unless superseded by a new ADR.
- Release engineers must create `key.properties` and the upload keystore on the machine that produces store-bound AABs/APKs.
- CI that omits `key.properties` verifies release **compilation** with debug signing only; Play uploads require a protected workflow with injected secrets.
