## ADDED Requirements

### Requirement: OS-aware recommended install action

The landing page SHALL detect the visitor's operating system and present the matching platform's install action as the primary, recommended option, while keeping every platform's option reachable.

#### Scenario: Windows visitor is steered to the installer

- **WHEN** the page loads in a browser whose detected OS is Windows
- **THEN** the Windows download SHALL be shown as the primary recommended action

#### Scenario: iPadOS is not mistaken for macOS

- **WHEN** the page loads on a device reporting a Mac platform but with touch support (`navigator.maxTouchPoints` greater than 1)
- **THEN** the page SHALL treat the visitor as iOS/iPadOS and recommend the TestFlight action instead of the macOS download

#### Scenario: All platforms remain reachable

- **WHEN** any visitor opens the page, including an unknown OS or a browser with JavaScript disabled
- **THEN** install actions for Windows, macOS, Android, and iOS SHALL all remain visible and actionable

### Requirement: Desktop direct downloads

The landing page SHALL offer Windows and macOS users a direct download of the current release artifact resolved from the release manifest.

#### Scenario: Windows installer download

- **WHEN** the visitor activates the Windows action
- **THEN** the browser SHALL download the `.exe` installer at the URL from the manifest's `assets.windows` entry

#### Scenario: macOS archive download

- **WHEN** the visitor activates the macOS action
- **THEN** the browser SHALL download the `.zip` archive at the URL from the manifest's `assets.macos` entry

### Requirement: Android sideload and Play beta enrollment

The landing page SHALL offer Android users both a direct APK sideload download and a link to enroll in the Google Play beta test track.

#### Scenario: APK sideload download

- **WHEN** the visitor activates the Android "Download APK" action
- **THEN** the browser SHALL download the arm64 APK at the URL from the manifest's `assets.android_arm64_v8a` entry

#### Scenario: Play beta enrollment

- **WHEN** the visitor activates the Android "Join the Play beta" action
- **THEN** the page SHALL open the configured Play test track opt-in URL for application `ai.enjoy.player`

#### Scenario: Sideload guidance is shown

- **WHEN** the Android option is presented
- **THEN** the page SHALL show concise guidance that installing the APK requires allowing installation from unknown sources

### Requirement: iOS TestFlight enrollment

The landing page SHALL direct iOS users to join the public TestFlight program, since iOS has no direct-download artifact.

#### Scenario: TestFlight invite link

- **WHEN** the visitor activates the iOS action
- **THEN** the page SHALL open the configured public TestFlight invitation URL

### Requirement: Live version and links from the release manifest

The landing page SHALL source the displayed version and the desktop/Android direct-download URLs from the release manifest (`latest.json`) at runtime, so they reflect the latest published release without editing the page.

#### Scenario: Current version is displayed

- **WHEN** the manifest is fetched successfully
- **THEN** the page SHALL display the manifest `version` and use its `assets` URLs for the Windows, macOS, and Android APK actions

#### Scenario: New release requires no page edit

- **WHEN** a new release updates `latest.json`
- **THEN** the page SHALL present the new version and links on next load without any change to the page's source

### Requirement: Graceful fallback when the manifest is unavailable

The landing page SHALL remain usable when the release manifest cannot be fetched, without showing broken actions.

#### Scenario: Manifest fetch fails

- **WHEN** the manifest request fails or times out
- **THEN** the direct-download actions SHALL fall back to stable download links and the page SHALL still present all platform options

#### Scenario: JavaScript disabled

- **WHEN** the page is rendered without JavaScript
- **THEN** all platform install actions SHALL still be present using their fallback links
