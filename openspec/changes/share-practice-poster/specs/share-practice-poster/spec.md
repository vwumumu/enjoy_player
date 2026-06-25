## ADDED Requirements

### Requirement: Practice poster eligibility

The app SHALL offer a share-practice-poster action only for the currently open media when that target has at least one local recording row in Drift.

#### Scenario: Action visible with practice data

- **WHEN** the user opens the player for a media item that has one or more recordings for its `targetType` and `targetId`
- **THEN** the app SHALL expose a share-practice-poster entry in player UI

#### Scenario: Action hidden without practice data

- **WHEN** the user opens the player for a media item with zero recordings
- **THEN** the app SHALL NOT expose the share-practice-poster entry

### Requirement: Poster content

The generated practice poster SHALL include, for the selected media item: resolved cover art (local thumbnail, network thumbnail, or generative fallback), media title, a hero sentence, practice statistics, Enjoy Player branding, and a QR code encoding `https://player.enjoy.bot`.

#### Scenario: Poster includes cover and title

- **WHEN** the user previews or exports a practice poster for a media item with a resolvable title
- **THEN** the poster SHALL display the media title and cover art or generative fallback

#### Scenario: Hero sentence from most-practiced line

- **WHEN** transcript lines and recordings exist for the media item
- **THEN** the poster SHALL display the transcript line text with the highest overlapping recording count, breaking ties by longer line text

#### Scenario: Hero sentence fallback without transcript overlap

- **WHEN** recordings exist but no transcript line has overlapping recordings
- **THEN** the poster SHALL display the longest non-empty `referenceText` among recordings, or omit the quote block if none exist

#### Scenario: Practice statistics on poster

- **WHEN** the poster is generated
- **THEN** the poster SHALL display the count of recordings (takes), the count of transcript line indices with at least one overlapping recording (sentences practiced), and total spoken duration computed as the sum of recording durations for the target

#### Scenario: QR code destination

- **WHEN** the poster is generated
- **THEN** the poster SHALL include a scannable QR code whose payload is exactly `https://player.enjoy.bot`

### Requirement: Mobile-first poster layout

The practice poster SHALL use a 9:16 portrait layout sized for mobile social sharing, with safe margins so primary content remains legible when cropped by WeChat or similar apps.

#### Scenario: Portrait aspect ratio

- **WHEN** the poster is rendered for export
- **THEN** the canvas SHALL use a 9:16 width-to-height ratio

#### Scenario: Branding present

- **WHEN** the poster is rendered
- **THEN** the poster SHALL include the Enjoy Player logo and visual styling consistent with app brand tokens (dark gradient background, brand accent)

### Requirement: Preview before share

The app SHALL show a preview of the practice poster and require explicit user confirmation before invoking share or save.

#### Scenario: Preview sheet opens

- **WHEN** the user activates share-practice-poster from the player
- **THEN** the app SHALL present a preview sheet showing the poster layout

#### Scenario: Share disabled while loading

- **WHEN** cover art or poster capture is still in progress
- **THEN** the app SHALL disable the primary share/save action until the poster is ready or show a loading state

### Requirement: Mobile share via system sheet

On iOS and Android, the app SHALL export the poster as a PNG and open the platform share sheet so the user can share to WeChat or other installed apps.

#### Scenario: iOS or Android share

- **WHEN** the user confirms share on iOS or Android and poster PNG bytes are available
- **THEN** the app SHALL invoke the system share sheet with an `image/png` file suitable for WeChat and other share targets

#### Scenario: Share failure

- **WHEN** the share sheet fails to open
- **THEN** the app SHALL show a localized error notice and SHALL NOT crash

### Requirement: Desktop save fallback

On Windows and macOS, the app SHALL save the poster PNG via a file save dialog when the user confirms export.

#### Scenario: Desktop save

- **WHEN** the user confirms export on Windows or macOS
- **THEN** the app SHALL prompt for a save location and write a PNG file

#### Scenario: Desktop save cancelled

- **WHEN** the user dismisses the save dialog without choosing a path
- **THEN** the app SHALL return silently without error notice

### Requirement: Offline generation

Practice poster generation SHALL NOT require network connectivity beyond optional thumbnail URL fetch; aggregation of recordings and transcript data SHALL use local Drift data.

#### Scenario: Offline with local data

- **WHEN** the device is offline and local recordings and transcript exist for the media item
- **THEN** the app SHALL still generate and preview the poster using local data and generative cover if needed

### Requirement: Localized poster chrome

User-visible labels on the preview sheet and poster chrome (stat labels, tagline, button labels, errors) SHALL be localized via `flutter gen-l10n` for supported app locales.

#### Scenario: English and Chinese strings

- **WHEN** the app locale is English or Chinese
- **THEN** poster chrome and share UI strings SHALL appear in that locale
