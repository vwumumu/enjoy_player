## Context

Enjoy Player targets Android, iOS, macOS, Windows and **explicitly forbids Flutter web** (AGENTS.md, ADR-0005): no `web/` scaffolding, no `kIsWeb`. Release artifacts are published to `https://dl.enjoy.bot/player/<version>/` with a machine-readable manifest at `https://dl.enjoy.bot/player/latest.json` (ADR-0023). The manifest exposes `version`, `build`, `minSupportedVersion`, `notes`, and an `assets` map keyed by `windows`, `macos`, `android_arm64_v8a`, `android_armeabi_v7a`, `android_x86_64`, each with `{ url, sha256 }` ([`generate_update_feeds.sh`](../../../.github/scripts/generate_update_feeds.sh)). It has **no iOS entry** — iOS distributes only via **TestFlight** today. Android also distributes via a **Play test track**. The app's canonical bundle identifier is `ai.enjoy.player` (ADR-0020) and public URLs live under the `enjoy.bot` family (`dl.enjoy.bot` downloads, `worker.enjoy.bot` API, [`app_links.dart`](../../../lib/core/application/app_links.dart)).

What is missing is a **human-facing entry point**: one URL that detects a visitor's OS and routes them to the right install action. This design covers a standalone marketing/download page, separate from the Flutter app, hosted on Cloudflare.

## Goals / Non-Goals

**Goals:**

- One shareable page that, per OS, offers: **Windows** `.exe`, **macOS** `.zip`, **Android** APK **and** Play beta enrollment, **iOS** TestFlight.
- Detect the visitor OS and present the recommended action first, while keeping every platform reachable.
- Keep direct-download links fresh by reading the existing `latest.json` at runtime; never hand-maintain version numbers in HTML.
- Degrade gracefully: if the manifest is unreachable or JS is disabled, all platforms remain downloadable.
- Stay dependency-light and cheap to host; deploy from CI like the rest of the release pipeline.

**Non-Goals:**

- No Flutter web build of the app and no `web/` directory in the Flutter project (ADR-0005). This is a separate static site.
- No app feature work, no Dart code, no new Dart dependencies.
- No payments, accounts, telemetry backend, or CMS — static content only.
- No change to the `latest.json` / `appcast.xml` feed contract (owned by the in-flight app-update-system change).
- No automated iOS App Store / Play production listing wiring (TestFlight + Play test only for now).

## Decisions

### 1. Standalone static site in `landing/`, not Flutter web

A marketing/download page has nothing to gain from the Flutter engine and would violate the native-only rule. We add a top-level **`landing/`** directory (deliberately **not** `web/`, which is the reserved Flutter web folder) containing plain static assets.
*Alternative considered:* build the Flutter app for web as the landing surface — rejected (forbidden by ADR-0005, heavy payload, poor SEO/first paint for a brochure page).

### 2. Cloudflare Pages for hosting (+ a Pages Function for the manifest)

Cloudflare Pages is purpose-built for static sites, gives free TLS + global CDN, preview deployments per PR, and **Pages Functions** for the small dynamic bit we need. It fits the existing Cloudflare footprint (`dl.enjoy.bot`, `worker.enjoy.bot`).
*Alternative considered:* a plain Worker serving static assets — viable but Pages handles static hosting, previews, and headers with less boilerplate.

### 3. Framework-less HTML/CSS/JS (no SSG to start)

The page is one screen of content. We ship hand-authored `index.html` + one CSS file + a small `main.js`, with **no build step** and no Node framework. The repo's only Node tooling is `tool/` (icon generation), so we avoid an SSG toolchain until the site grows.
*Alternative considered:* Astro/Eleventy — nicer for multi-page growth and components, but adds a build pipeline and dependencies for a single page. Revisit if the site expands (changelog, docs, localized routes).

### 4. Runtime manifest resolution through a same-origin proxy

The client must turn "latest version" into concrete URLs without going stale. A Pages Function at **`/api/latest`** fetches `dl.enjoy.bot/player/latest.json` server-side, caches it at the edge (short TTL + stale-while-revalidate), and returns it **same-origin** — avoiding any CORS coupling to the download host and giving us cache control. The client reads `assets.windows.url`, `assets.macos.url`, `assets.android_arm64_v8a.url`, and `version`.
*Alternatives considered:*
- **CORS-enable `dl.enjoy.bot` and fetch directly** — fewer moving parts, but couples the page to the download host's headers and offers no edge caching of our own.
- **Build-time injection** of links into HTML — requires redeploying the landing site on every app release and risks drift; rejected.

### 5. Dual Android path; static store/TestFlight links

`latest.json` has no iOS or store entries, so those are **site configuration**, not manifest-derived:

| Platform | Primary action | Source |
|----------|----------------|--------|
| Windows | Download `.exe` | `latest.json` `assets.windows.url` |
| macOS | Download `.zip` | `latest.json` `assets.macos.url` |
| Android | Download APK (arm64) **+** "Join the Play beta" | `assets.android_arm64_v8a.url` + config Play opt-in URL |
| iOS | "Join the TestFlight" | config TestFlight invite URL |

Android shows **both** because each has trade-offs: the APK is the newest build but needs "install unknown apps"; Play beta is managed/auto-updating but lags the direct channel. Store/TestFlight URLs (and bundle id `ai.enjoy.player`) live in a single site config file documented in the ADR, so non-engineers can update them.

### 6. OS detection with progressive enhancement

Detect via `navigator.userAgentData` (Client Hints) with a `userAgent`/`platform` fallback. Disambiguate **iPadOS masquerading as macOS** using `navigator.maxTouchPoints > 1`. The detected platform's card is highlighted/ordered first; **all** platform cards always render so the page works with JS disabled and for users on a different device than they'll install on.

### 7. Deploy via Wrangler + GitHub Actions

A `wrangler` config defines the Pages project; a new `.github/workflows/deploy_landing.yml` runs `wrangler pages deploy landing` — preview deployments on PRs touching `landing/**` and production deploys on `main` (plus manual dispatch). Auth uses a `CLOUDFLARE_API_TOKEN` repo secret + account id; nothing secret is committed. This matches the repo's "CI runs the same scripts" convention.
*Alternative considered:* Pages Git integration (auto-build on push) — fine, but Wrangler-in-CI keeps deploy logic in-repo and reviewable.

### 8. Caching, headers, and metadata

A `_headers` file sets: HTML `Cache-Control: no-cache` (always revalidate), fingerprinted/static assets `immutable` long-cache, and security headers (`Content-Security-Policy`, `X-Content-Type-Options: nosniff`, `Referrer-Policy`). The page includes Open Graph/Twitter meta and a favicon/logo reused from [`assets/logo-light.svg`](../../../assets/logo-light.svg) for good link previews.

## Risks / Trade-offs

- **iPadOS reports as macOS** → user sees a `.zip` instead of TestFlight. Mitigation: `maxTouchPoints` heuristic; always render the iOS card; never hard-redirect on detection.
- **Manifest/proxy unavailable** → broken download buttons. Mitigation: `/api/latest` failure falls back to stable links (the `dl.enjoy.bot/player/` index or a documented `latest` alias) and the page still lists all platforms.
- **No iOS/store data in `latest.json`** → links are hand-configured and can rot (TestFlight 10k cap, invite expiry, Play track propagation delay). Mitigation: single config file + ADR note; easy to update; clear fallback copy.
- **Edge cache staleness after a release** → users briefly see the prior version. Mitigation: short TTL + stale-while-revalidate on `/api/latest`; immutable versioned asset URLs mean a stale link is still valid, just not newest.
- **Android "unknown sources" friction** → confusion installing the APK. Mitigation: concise inline install steps + offer Play beta as the managed alternative.
- **Toolchain creep** → resist adding an SSG/bundler prematurely; framework-less keeps the deploy trivial.
- **Domain/DNS coordination** → `get.enjoy.bot` must be provisioned in Cloudflare DNS before the custom domain attaches; until then the `*.pages.dev` URL works.

## Migration Plan

1. Create the Cloudflare Pages project and point **`get.enjoy.bot`** DNS at it (CNAME → `pages.dev`); the generated `*.pages.dev` URL works immediately for verification.
2. Add `landing/` (static `index.html`, CSS, `main.js`), `landing/functions/api/latest.js` (manifest proxy), and `_headers`.
3. Add `wrangler` config + `deploy_landing.yml` (PR previews, prod on `main`, manual dispatch); set `CLOUDFLARE_API_TOKEN` + account id as CI secrets.
4. Configure the TestFlight invite URL and Play beta opt-in URL in the site config.
5. Verify on a preview deploy: OS detection across platforms, manifest-driven links, fallback when `/api/latest` is forced to fail, and link previews; then attach the custom domain.
6. Write the ADR (hosting + domain + manifest sourcing) and update `docs/packaging.md` with how users get the app.

**Rollback:** Cloudflare Pages retains deployment history — promote any prior deployment to roll back instantly. The site is fully independent of the app, so reverting the `landing/` change has zero impact on builds or releases.

## Open Questions

- Final hostname — `get.enjoy.bot` (proposed) vs `download.enjoy.bot` / `app.enjoy.bot`, and whether the root `enjoy.bot` should also link here.
- Confirm the manifest strategy: same-origin Pages Function proxy (proposed) vs simply enabling CORS on `dl.enjoy.bot`. Should we also add stable `latest` alias URLs on the download host so the page could be fully static?
- Localization now (en + zh, matching the app) or English-only first?
- Where the TestFlight/Play URLs are owned and updated (committed site config vs CI env var), and who is responsible.
- Do we want lightweight, privacy-respecting analytics (e.g., Cloudflare Web Analytics) to measure downloads-by-platform, or stay zero-tracking?
