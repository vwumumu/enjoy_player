# Feature Specification: Login-Only Application Access

**Feature Branch**: `001-login-only-app`

**Created**: 2026-06-30

**Status**: Draft

**Input**: User description: "Since we have refactor the auth flow to make it smooth. We should make the application login only, avoid guest users."

## Clarifications

### Session 2026-06-30

- Q: Is guest-to-account data migration required for this release? → A: No — the app is not in production yet; legacy guest migration is out of scope.
- Q: What is the primary UX goal for the login gate? → A: A friendly welcome experience with a smooth sign-in flow (no friction beyond required authentication).
- Q: What is the welcome screen structure? → A: Single screen — welcome headline, brief value proposition, and sign-in actions together on the existing sign-in hub (no separate intro step).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Sign in before using the app (Priority: P1)

A new or signed-out user opens Enjoy Player and must sign in with their Enjoy account before they can access home, library, discover, player, or settings. The first screen they see is a welcoming sign-in experience that explains the value of signing in and offers the native sign-in hub (Google, Apple, email OTP, or other sign-in options) without extra steps or intimidating language.

**Why this priority**: This is the core product change — eliminating anonymous guest usage so every session is tied to an account and eligible for sync, profile, and cloud features.

**Independent Test**: Launch the app while signed out and verify that only the welcoming sign-in flow is reachable until authentication succeeds.

**Acceptance Scenarios**:

1. **Given** the user is signed out and opens the app, **When** the app finishes loading, **Then** the user is shown the welcoming sign-in screen and cannot reach home, library, discover, player, or settings.
2. **Given** the user is on the sign-in screen, **When** they complete sign-in successfully, **Then** they are taken to the main app (home or their prior intended destination) without unnecessary intermediate screens.
3. **Given** the user is signed out, **When** they attempt to navigate directly to any in-app route (e.g., library, player, settings), **Then** they are redirected to sign-in instead of seeing app content.

---

### User Story 2 - Seamless return for signed-in users (Priority: P1)

A user who previously signed in and still has a valid session opens the app and goes directly to the main experience without being asked to sign in again.

**Why this priority**: Login-only must not regress the smooth auth flow — returning users should feel instant access, not repeated friction.

**Independent Test**: Sign in once, close and reopen the app with a valid session, and confirm the user lands on home without seeing the sign-in gate.

**Acceptance Scenarios**:

1. **Given** the user has a valid stored session, **When** they cold-start the app, **Then** they enter the main app without visiting the sign-in screen.
2. **Given** the user has a valid session, **When** they navigate the app, **Then** all signed-in features remain available as today.

---

### User Story 3 - Sign out returns to login gate (Priority: P2)

A signed-in user chooses to sign out. They are returned to the welcoming sign-in screen and cannot continue using the app without authenticating again.

**Why this priority**: Sign-out must clearly end the session; there must be no fallback path that leaves the user in an anonymous local-only mode.

**Independent Test**: Sign in, sign out from profile or settings, and verify the app shows only sign-in until the user authenticates again.

**Acceptance Scenarios**:

1. **Given** the user is signed in, **When** they sign out, **Then** they are shown the sign-in screen and all main app routes are blocked.
2. **Given** the user just signed out, **When** they press back or try to open a deep link to app content, **Then** they remain on or return to sign-in rather than accessing protected content.

---

### User Story 4 - Preserve intended destination after sign-in (Priority: P2)

A signed-out user tries to open a specific destination (e.g., profile, credits, or a shared link). After signing in, they are taken to that destination instead of always landing on home.

**Why this priority**: Login-only adds a gate; preserving intent avoids extra navigation and supports links shared before sign-in.

**Independent Test**: While signed out, navigate to a protected route, complete sign-in, and confirm arrival at the originally requested screen.

**Acceptance Scenarios**:

1. **Given** the user is signed out and opens a protected route, **When** they complete sign-in, **Then** they are redirected to that route.
2. **Given** the user opens the app without a specific destination, **When** they sign in, **Then** they land on home.

---

### User Story 5 - Friendly welcome and smooth sign-in (Priority: P1)

A first-time or signed-out user sees a welcoming sign-in screen that feels approachable — clear headline, brief value proposition (e.g., sync progress, library, learning features), and prominent sign-in actions — and can complete sign-in in as few taps as the chosen method allows.

**Why this priority**: Login-only makes sign-in the first impression; a friendly welcome reduces abandonment and aligns with the recently refactored smooth auth flow.

**Independent Test**: Observe a signed-out cold start and complete one sign-in method; confirm the welcome copy is visible, actions are obvious, and no guest or skip path is offered.

**Acceptance Scenarios**:

1. **Given** the user is signed out, **When** the sign-in screen appears, **Then** they see welcome headline, value proposition, and clearly labeled sign-in options on one screen without error, blank states, or a separate intro step.
2. **Given** the user selects a sign-in method, **When** they complete or cancel it, **Then** success transitions smoothly to the main app and cancellation returns them to the same welcome screen without alarming errors.
3. **Given** auth is still resolving on launch, **When** the user waits, **Then** they see a brief, neutral loading state — not a flash of main app content and not a jarring blank screen.

---

### Edge Cases

- What happens when auth state is still loading on launch? The app shows a neutral loading state and does not flash main app content before the login gate resolves.
- What happens when the session expires while the user is in the app? The user is signed out and redirected to sign-in; unsaved in-memory state may be lost, but persisted data remains tied to their account after re-authentication.
- What happens when the user is offline at launch with an expired session? Sign-in is required; the user sees sign-in with a clear, friendly message if network is needed to authenticate.
- What happens when the user cancels a provider sign-in (Google, Apple, browser)? They remain on the welcome sign-in screen with no access to main app routes and without an error snackbar unless the platform reports an unexpected failure.
- What happens when the user opens a deep link while signed out? They see sign-in first, then proceed to the linked destination after successful authentication.
- What happens on Android, iOS, macOS, and Windows? The login gate applies on all supported platforms; platform-specific sign-in options remain as documented for each platform.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST require a valid signed-in Enjoy account session before allowing access to home, library, discover, player, settings, sync status, and all other primary app experiences.
- **FR-002**: The system MUST present a single-screen welcoming sign-in hub as the default entry point whenever the user is not signed in — welcome copy and sign-in actions on one screen with no preceding intro step.
- **FR-003**: The system MUST NOT offer a "continue as guest," "skip sign-in," or equivalent path that grants app usage without an Enjoy account.
- **FR-004**: The system MUST redirect unsigned users away from protected routes to sign-in, preserving the intended destination for use after successful authentication where technically feasible.
- **FR-005**: The system MUST allow users with a valid existing session to enter the main app without re-authenticating on cold start.
- **FR-006**: The system MUST route users to sign-in upon explicit sign-out and block unauthenticated usage afterward.
- **FR-007**: The system MUST route users to sign-in when the session becomes invalid (expired or revoked tokens that cannot be refreshed).
- **FR-008**: The system MUST NOT include guest-to-account data migration flows; the app has no production users requiring legacy guest data upgrade.
- **FR-009**: The system MUST keep YouTube account login as a separate flow for YouTube playback; requiring an Enjoy account MUST NOT replace or conflate YouTube cookie-based login.
- **FR-010**: The system MUST show a loading state during initial auth resolution so users do not briefly see protected content before the login gate applies.
- **FR-011**: The single welcome sign-in screen MUST combine a clear headline, brief value proposition, and accessible sign-in actions using existing shared UI patterns and localized strings — all visible without navigating to a separate screen.
- **FR-012**: Completing sign-in MUST transition the user to the main app in one continuous flow without redundant confirmation steps.

### Quality, UX, and Performance Requirements

- **QR-001**: Implementation MUST preserve Enjoy Player's feature-first architecture and avoid feature-to-feature shortcuts unless the plan documents an exception.
- **QR-002**: Changed behavior MUST have automated tests or a documented manual verification reason.
- **QR-003**: User-facing strings, controls, haptics, tooltips, and keyboard affordances MUST follow existing localization and shared UI patterns.
- **QR-004**: Cold start for users with a valid session MUST NOT add perceptible delay beyond current auth initialization; sign-in gate resolution MUST complete within 2 seconds on typical devices under normal conditions.
- **QR-005**: Feature behavior changes MUST update the matching documentation under `docs/features/`.
- **QR-006**: The welcome sign-in screen MUST meet the same accessibility and localization standards as other primary app surfaces (readable contrast, localized copy, tappable targets).

### Key Entities

- **Enjoy account session**: The authenticated state tying the user to profile, sync, credits, and per-user local data; required for all app usage after this change.
- **Sign-in gate**: The enforced boundary that limits unsigned users to sign-in-related screens until authentication succeeds.
- **Welcome sign-in experience**: A single first screen unsigned users see — welcome headline, brief value proposition, and native sign-in actions together — designed to make required login feel approachable rather than punitive.
- **Intended destination**: The route or deep link the user attempted to reach before sign-in, restored after successful authentication when possible.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of cold starts by signed-out users land on the welcome sign-in screen or auth loading — zero reach main app content without authentication in acceptance testing.
- **SC-002**: 95% of cold starts by users with valid sessions reach the main app without seeing the sign-in screen.
- **SC-003**: Users with valid sessions complete cold start to interactive home in under 3 seconds on reference devices (same budget as pre-change signed-in startup).
- **SC-004**: After sign-in from a deep link or protected route, at least 90% of test cases arrive at the originally requested destination without manual re-navigation.
- **SC-005**: In moderated first-use testing, at least 80% of participants describe the sign-in screen as "welcoming" or "clear" and complete sign-in on first attempt without assistance.
- **SC-006**: Sign-in cancellation returns users to the welcome screen without error messaging in at least 95% of provider-cancel test cases (unexpected failures excepted).

## Assumptions

- The app is **pre-production**; no legacy guest users or guest-data migration paths need to be supported for this release.
- The native sign-in hub (Google, Apple, email OTP, OAuth PKCE fallback) delivered in the recent auth refactor is the sole sign-in entry; no new auth methods are in scope.
- The welcome experience is a **single enhanced sign-in hub** — welcome headline, value proposition, and sign-in actions on one screen; no separate intro or onboarding step precedes sign-in.
- Offline playback and local library access remain available **after** sign-in when content is already on the device; only the **initial gate** requires authentication.
- Users without network at first launch after install must connect to sign in at least once; fully offline-first anonymous use is out of scope.
- Per-user local data isolation for signed-in users is unchanged; eliminating guest mode means all new local data is stored under a signed-in account from first use.
- Removing guest mode does not change MVP boundaries for cloud sync, YouTube imports, or echo mode — those behaviors apply once signed in as they do today.
