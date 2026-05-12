# ADR-0016: Enjoy account sign-in via in-app WebView

## Status

Accepted

## Context

[ADR-0006](0006-auth-and-profile-sync.md) specified that after `POST /api/v1/sessions/start_auth`, the user completes sign-in in the **system browser** (`url_launcher`), while the app polls `GET /api/v1/sessions/poll`.

Keeping users inside the app reduces context switching and avoids relying on the OS to return to the player after OAuth. The project already depends on `flutter_inappwebview` (YouTube playback).

## Decision

1. **Primary UX:** Load `verificationUrl` from `start_auth` inside an **`InAppWebView`** on the sign-in screen. Use WebView settings aligned with [YouTube login](../features/youtube.md) (JavaScript, third-party cookies, Chrome-like mobile `userAgent`) so common OAuth providers accept the session.

2. **Unchanged contract:** The same `start_auth` + `poll` loop and token storage (`flutter_secure_storage`) as ADR-0006 / ADR-0012. No change to Rails session APIs.

3. **Escape hatch:** The sign-in toolbar offers **Open in system browser** (still `url_launcher`) if an IdP blocks embedded WebViews or the user prefers an external browser. Polling continues either way until approval or timeout.

## Consequences

- **Supersedes** ADR-0006 §Decision point 2 (“system browser only”) for *where* the verification page runs; tokens, profile, and polling semantics stay as before.

- Some providers may still block or degrade WebView logins on certain devices; the external-browser option and **Reload sign-in page** mitigate that without a second auth protocol.

- WebView shares no cookie jar requirement with YouTube sign-in; Enjoy account auth is independent of YouTube cookies.
