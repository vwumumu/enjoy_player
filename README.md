# Enjoy Player

Cross-platform **language-learning player** (Android, iOS, Windows, macOS) built with Flutter. MVP focuses on **local** audio/video, **transcripts** (SRT/VTT), and **echo mode** (line-bounded shadow reading), aligned with the Enjoy web app player concepts.

## Prerequisites

- Flutter SDK (stable, 3.x)
- Dart SDK ^3.9
- **macOS desktop builds**: [Homebrew](https://brew.sh) plus FFmpeg kit deps — `brew bundle install --file=macos/Brewfile` (see [packaging.md](docs/packaging.md#ffmpeg-ffmpeg_kit_flutter_new-and-homebrew)). Without this, `flutter run -d macos` can fail at launch with a missing `libz.1.dylib` / DYLD error.
- **Windows desktop builds**: [NuGet CLI](https://learn.microsoft.com/en-us/nuget/install-nuget-client-tools?tabs=windows#nugetexe-cli) on your `PATH` (`nuget` / `nuget.exe`). Required by [`flutter_inappwebview`](https://inappwebview.dev/docs/intro#setup-windows) to pull WebView2 native dependencies during CMake/MSBuild. After installing, open a **new** terminal and run `nuget` to verify.
  - NuGet must have **at least one package source** (normally `nuget.org`). If `nuget sources list` is empty or MSBuild fails with `primarySources` / “Feeds used:” and then an error, add it once:  
    `nuget sources Add -Name "nuget.org" -Source "https://api.nuget.org/v3/index.json"`

## Setup

```bash
flutter pub get
dart run build_runner build   # after changing Drift / Riverpod annotations
```

### App icon & logo assets

The in-app logo uses [`assets/logo-light.svg`](assets/logo-light.svg). Launcher icons are generated from a raster export:

```bash
npm install --prefix tool
node tool/svg_to_png.mjs           # writes assets/logo.png from the SVG
dart run flutter_launcher_icons    # uses flutter_launcher_icons.yaml
```

## Run

```bash
flutter run
```

## Test / analyze

```bash
flutter analyze
flutter test
```

## Docs

| Doc | Purpose |
|-----|---------|
| [AGENTS.md](AGENTS.md) | Rules for contributors & AI agents |
| [docs/architecture.md](docs/architecture.md) | Structure & flows |
| [docs/decisions/](docs/decisions/) | Architecture Decision Records |
| [docs/features/](docs/features/) | Feature specs |

## Tech highlights

- **Player**: [media_kit](https://pub.dev/packages/media_kit) (+ `media_kit_video`, `media_kit_libs_video`)
- **State**: [Riverpod 3](https://pub.dev/packages/flutter_riverpod) + `riverpod_annotation`
- **DB**: [Drift](https://pub.dev/packages/drift) + `drift_flutter`

## License

Private / unpublished (`publish_to: 'none'`).
