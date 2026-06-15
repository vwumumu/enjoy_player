## Why

Enjoy Player is approaching its first public/beta release, but there is no human-facing page that tells people how to get the app. Release artifacts already live on `dl.enjoy.bot/player/` and store channels (iOS **TestFlight**, Android **Play test track**), yet a prospective user has no single URL that detects their OS and points them to the correct install path. We need one shareable landing page that turns "where do I download it?" into a one-click action per platform.

## What Changes

- Add a **standalone static landing site** hosted on **Cloudflare Pages**. It is **not** a Flutter web build — no `web/` scaffolding and no `kIsWeb` branches in the app (AGENTS.md, ADR-0005).
- **Detect the visitor's OS** (Windows / macOS / Android / iOS / unknown) and surface the recommended action first, while still listing **all** platforms.
- Per-platform calls to action:
  - **Windows**: direct `.exe` installer download.
  - **macOS**: direct `.zip` download.
  - **Android**: **APK** sideload download **and** a **Play Store beta enrollment** link.
  - **iOS**: **TestFlight** join link (App Store later).
- Resolve the current version and direct-download URLs from the existing release manifest (`dl.enjoy.bot/player/latest.json`) **at runtime** via a same-origin proxy, so links never go stale; fall back to stable links if the manifest is unreachable.
- Ship deployment plumbing: a Cloudflare Pages project on a dedicated subdomain (e.g. `get.enjoy.bot`), Wrangler config, caching/security headers, basic SEO/Open Graph metadata, and a GitHub Actions deploy workflow.

## Capabilities

### New Capabilities

- `download-landing-page`: An OS-aware static landing page that presents per-platform download/install actions — Windows/macOS direct downloads, Android APK + Play beta enrollment, iOS TestFlight — populated with the live version and links from the release manifest, with graceful fallback when the manifest is unavailable.
- `landing-site-deployment`: Hosting and delivery of the static site on Cloudflare Pages — project + custom domain, build/deploy pipeline (Wrangler + CI), caching and security headers, and same-origin access to `latest.json`.

### Modified Capabilities

<!-- None: `update-distribution` is defined in the in-flight app-update-system change and not yet an archived spec; the landing page reads `latest.json` through a same-origin proxy without changing the feed's contract. -->

## Impact

- **New code**: a top-level `landing/` directory (static HTML/CSS/JS — deliberately **not** `web/`, to respect the no-Flutter-web rule) and a Cloudflare Pages Function that proxies `latest.json` same-origin.
- **Infra**: new Cloudflare Pages project, `wrangler` config, and a subdomain (DNS) for the site.
- **CI**: new `.github/workflows/deploy_landing.yml`; a `CLOUDFLARE_API_TOKEN` repository secret (no secrets committed).
- **External links to manage**: the public **TestFlight** invite URL and the **Play test track** opt-in URL (currently absent from `latest.json`).
- **Docs**: new ADR (landing hosting + domain + manifest sourcing) under `docs/decisions/`; link from `docs/decisions/README.md`; update `docs/packaging.md` with how users obtain the app.
- **App code**: none — no Flutter source or Dart dependency changes; reuses existing `dl.enjoy.bot` artifacts ([`app_links.dart`](lib/core/application/app_links.dart)).
- **Constraints**: native-only app rule preserved (separate static site); no `print()` concerns (no Dart); secrets stay in CI, never in repo.
