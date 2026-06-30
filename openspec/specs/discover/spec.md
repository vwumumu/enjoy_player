# discover Specification

## Purpose

In-app YouTube content discovery so users can browse channel feeds and add videos to their practice library without finding and pasting URLs externally.

## Requirements

### Requirement: Discover surface is reachable from the app shell

The system SHALL provide a Discover route accessible from the main navigation shell.

#### Scenario: User opens Discover tab

- **WHEN** the user selects Discover in the shell navigation
- **THEN** the system SHALL navigate to the Discover screen
- **AND** SHALL display recommended channels and the user's subscription feed

#### Scenario: User opens Discover from Home empty state

- **WHEN** the user's library has no media on Home
- **THEN** the Home empty state SHALL offer an action to open Discover
- **AND** selecting it SHALL navigate to the Discover screen

### Requirement: Recommended channels catalog is bundled and displayed

The system SHALL ship a bundled catalog of recommended YouTube channels oriented toward language-learning practice and SHALL display them on the Discover screen.

#### Scenario: Discover screen loads recommended channels

- **WHEN** the Discover screen is shown
- **THEN** the system SHALL load the recommended channels catalog from bundled assets
- **AND** SHALL display each channel with at least a display name
- **AND** SHALL allow the user to open that channel's feed view

### Requirement: User can subscribe to YouTube channels locally

The system SHALL allow users to subscribe to YouTube channels as Enjoy-local subscriptions without requiring YouTube OAuth.

#### Scenario: Subscribe from recommended channel

- **WHEN** the user chooses to subscribe to a recommended channel
- **THEN** the system SHALL persist a channel subscription locally with the channel's YouTube `channel_id`
- **AND** SHALL include the channel in subsequent feed refreshes

#### Scenario: Subscribe by channel URL or handle

- **WHEN** the user submits a valid YouTube channel URL or handle for subscription
- **THEN** the system SHALL resolve it to a `channel_id` when possible
- **AND** SHALL persist the subscription locally
- **OR** SHALL show a clear error if resolution fails

#### Scenario: Unsubscribe from channel

- **WHEN** the user unsubscribes from a channel they previously subscribed to
- **THEN** the system SHALL remove the local subscription record
- **AND** SHALL stop including that channel in future feed refreshes
- **AND** MAY retain cached feed entries until the next cache cleanup or refresh policy removes them

### Requirement: Channel feeds are fetched via public RSS and cached locally

The system SHALL fetch recent uploads for subscribed channels using YouTube's public Atom RSS feed and SHALL cache results locally separate from library `videos` rows.

#### Scenario: Feed refresh for subscribed channel

- **WHEN** a feed refresh runs for a subscribed channel with a known `channel_id`
- **THEN** the system SHALL fetch `https://www.youtube.com/feeds/videos.xml?channel_id=<channel_id>`
- **AND** SHALL parse video id, title, thumbnail URL, and published date for each entry
- **AND** SHALL upsert feed entries into local cache keyed by video id and channel id

#### Scenario: Merged timeline across subscriptions

- **WHEN** the user views the Discover timeline
- **THEN** the system SHALL show cached feed entries from all subscribed channels
- **AND** SHALL order them by published date descending

#### Scenario: Periodic and manual refresh

- **WHEN** the app launches or the user performs pull-to-refresh on Discover
- **THEN** the system SHALL refresh feeds for eligible subscribed channels subject to a minimum refresh interval
- **AND** SHALL update loading and error presentation while refresh is in progress

#### Scenario: RSS fetch failure

- **WHEN** RSS fetch or parse fails for a channel
- **THEN** the system SHALL retain previously cached entries when available
- **AND** SHALL surface an error state that allows retry

### Requirement: User can add feed videos to the library

The system SHALL allow users to add a feed entry to their library using the existing YouTube import path.

#### Scenario: Add new video to library

- **WHEN** the user chooses Add to library on a feed entry not yet in the library
- **THEN** the system SHALL import the video via the existing YouTube import flow using the entry's video id
- **AND** SHALL create or update the corresponding local `videos` row
- **AND** SHALL enqueue cloud sync when the user is signed in, consistent with manual YouTube URL import

#### Scenario: Video already in library

- **WHEN** the user views a feed entry whose video id already exists in the library
- **THEN** the system SHALL indicate the video is already in the library
- **AND** SHALL NOT create a duplicate library row

#### Scenario: Optional play when already imported

- **WHEN** a feed entry is already in the library and the user chooses to play it from Discover
- **THEN** the system SHALL open the existing library item in the player using the standard navigation flow

### Requirement: Discover feed is distinct from library media lists

The system SHALL NOT add feed cache entries to Library or Home recents until the user explicitly adds them to the library.

#### Scenario: Feed-only entries excluded from library

- **WHEN** feed entries exist in the discover cache but have not been imported
- **THEN** those entries SHALL NOT appear in Library media lists or Home recents

### Requirement: Recommended channels are language-tagged

The system SHALL use language metadata from the bundled recommended channel catalog when presenting Discover recommendations.

#### Scenario: Recommended catalog contains multiple learning languages

- **WHEN** the recommended channel catalog is loaded
- **THEN** the system SHALL preserve each channel's language tag and editorial tags
- **AND** SHALL support channels for English, Japanese, Korean, Spanish, and French recommendations

#### Scenario: User views recommended channels for focus language

- **WHEN** the user opens Discover channel management with a focus learning language selected
- **THEN** the system SHALL prioritize or filter recommended channels matching that language
- **AND** SHALL provide a way to view all recommended channels across languages

### Requirement: Subscriptions preserve language metadata

The system SHALL retain known channel language metadata when the user subscribes to a recommended YouTube channel.

#### Scenario: User subscribes to recommended channel

- **WHEN** the user subscribes to a recommended channel with a known language
- **THEN** the system SHALL persist the subscription with that language
- **AND** SHALL use that language for Discover filtering and import defaults

#### Scenario: User subscribes by pasted channel URL

- **WHEN** the user subscribes to a channel that is not in the recommended catalog
- **THEN** the system SHALL assign Unknown or the user's chosen channel language
- **AND** SHALL allow the channel language to be corrected later

### Requirement: Discover feed imports default media language from channel metadata

The system SHALL use known Discover channel or subscription language as the default content language when adding a feed video to the library.

#### Scenario: Add feed entry from language-tagged subscription

- **WHEN** the user adds a Discover feed entry from a subscription with a known language
- **THEN** the system SHALL import the YouTube video with that language as the default media content language
- **AND** SHALL allow the media language to be edited later from Library or player surfaces

#### Scenario: Add feed entry from unknown-language subscription

- **WHEN** the user adds a Discover feed entry from a subscription whose language is unknown
- **THEN** the system SHALL prompt for media content language or use the user's focus learning language as an explicit default
- **AND** SHALL NOT silently assume English

### Requirement: Discover language filtering does not alter library contents

The system SHALL keep Discover language filters scoped to recommendations and feed presentation until the user explicitly adds a video to the library.

#### Scenario: User changes Discover language filter

- **WHEN** the user changes the Discover language filter
- **THEN** the system SHALL update recommended channels and feed presentation
- **AND** SHALL NOT modify existing library media language values
