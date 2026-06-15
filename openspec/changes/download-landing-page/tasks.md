## 1. Site scaffolding

- [x] 1.1 Create a top-level `landing/` directory (static site root — deliberately **not** `web/`) with `index.html`, `styles.css`, and `main.js`
- [x] 1.2 Add a site config (`landing/config.js`) holding the bundle id `ai.enjoy.player`, the public TestFlight invite URL, the Play test-track opt-in URL, the manifest endpoint path (`/api/latest`), and per-platform fallback download links
- [x] 1.3 Add a favicon and logo by reusing [`assets/logo-light.svg`](../../../assets/logo-light.svg) (copy/export into `landing/`)

## 2. Page content & per-platform actions

- [x] 2.1 Build the page layout: hero (product name + one-line pitch drawn from the README) and a platform grid with one card per OS
- [x] 2.2 Windows card: "Download for Windows" pointing at the `.exe` (`assets.windows.url`)
- [x] 2.3 macOS card: "Download for macOS" pointing at the `.zip` (`assets.macos.url`)
- [x] 2.4 Android card: "Download APK" (`assets.android_arm64_v8a.url`) **and** "Join the Play beta" (config Play opt-in URL), with concise "allow installation from unknown sources" guidance
- [x] 2.5 iOS card: "Join the TestFlight" pointing at the config TestFlight invite URL
- [x] 2.6 Ensure all four cards render and are actionable with JavaScript disabled (static fallback links embedded in the HTML)

## 3. OS detection & manifest integration

- [x] 3.1 Implement OS detection in `main.js` using `navigator.userAgentData` with a `userAgent`/`platform` fallback; disambiguate iPadOS from macOS via `navigator.maxTouchPoints > 1`
- [x] 3.2 Highlight and order the detected platform's card as the primary recommended action while keeping every card visible
- [x] 3.3 Implement the `/api/latest` Pages Function (`landing/functions/api/latest.js`) that fetches `https://dl.enjoy.bot/player/latest.json` and returns it same-origin with short-TTL + stale-while-revalidate edge caching
- [x] 3.4 On load, fetch `/api/latest` and populate the version label plus the Windows / macOS / Android APK URLs from its `assets` map
- [x] 3.5 Implement graceful fallback: on fetch failure or timeout, retain the static fallback links and still present all platforms

## 4. Visual design & metadata

- [x] 4.1 Style a responsive, modern layout (mobile + desktop) consistent with the app's brand and logo
- [x] 4.2 Add SEO + Open Graph/Twitter meta tags, a favicon, and a social preview image
- [x] 4.3 Verify accessibility basics: semantic headings, labelled buttons/links, sufficient color contrast, visible keyboard focus

## 5. Cloudflare Pages hosting

- [x] 5.1 Add a `wrangler` config (`landing/wrangler.toml` or `wrangler.jsonc`) defining the Pages project name and the static output directory
- [x] 5.2 Add `landing/_headers`: HTML revalidate-on-load, fingerprinted static assets immutable/long-cache, and security headers (`Content-Security-Policy`, `X-Content-Type-Options: nosniff`, `Referrer-Policy`)
- [ ] 5.3 Create the Cloudflare Pages project and attach the `get.enjoy.bot` custom domain (DNS CNAME → `*.pages.dev`)

## 6. CI deploy pipeline

- [x] 6.1 Add `.github/workflows/deploy_landing.yml` that installs Wrangler and deploys `landing/` to Pages — preview deploys on PRs touching `landing/**`, production deploy on `main`, plus manual dispatch
- [ ] 6.2 Configure `CLOUDFLARE_API_TOKEN` and the Cloudflare account id as repository secrets; confirm no credentials are committed to the repo

## 7. Verification & docs

- [ ] 7.1 On a preview deploy, verify OS detection for Windows / macOS / Android / iOS (including iPadOS) and that the recommended action matches the visitor's OS
- [ ] 7.2 Verify manifest-driven links resolve to the current `latest.json` assets, and that forcing `/api/latest` to fail falls back without any broken buttons
- [ ] 7.3 Verify caching/security headers via response inspection and confirm the Open Graph link preview renders
- [x] 7.4 Write ADR-0024 (landing hosting + domain + manifest sourcing) and link it from [`docs/decisions/README.md`](../../../docs/decisions/README.md)
- [x] 7.5 Update [`docs/packaging.md`](../../../docs/packaging.md) (and the README if needed) with the public landing URL and how users obtain the app
- [x] 7.6 Confirm no Flutter web target or `web/` scaffolding was introduced and the Flutter app build is unaffected
