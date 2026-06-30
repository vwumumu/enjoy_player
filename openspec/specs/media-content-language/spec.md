# media-content-language Specification

## Purpose

Import-time and post-import editing of audio/video content language, including persistence, sync, and downstream use by transcripts and shadow reading.

## Requirements

### Requirement: Imported media records have user-selected content language

The system SHALL allow the user to set content language when importing local audio, local video, or YouTube video records.

#### Scenario: User imports local media

- **WHEN** the user imports a local audio or video file
- **THEN** the system SHALL present a content language choice before or during import completion
- **AND** SHALL default the choice from the user's focus learning language when no better source is known
- **AND** SHALL persist the chosen language on the created audio or video row

#### Scenario: User imports YouTube media manually

- **WHEN** the user imports a YouTube video by URL or video id
- **THEN** the system SHALL allow the user to choose the video's content language because YouTube metadata used by the app does not provide it
- **AND** SHALL persist the chosen language on the created video row

#### Scenario: User chooses unknown language

- **WHEN** the user explicitly chooses Unknown during import
- **THEN** the system SHALL persist `und` as the content language
- **AND** SHALL keep later language-dependent features gated until a supported language is selected

### Requirement: Existing media records have editable content language

The system SHALL allow the user to edit content language for existing audio, local video, and YouTube video records.

#### Scenario: User edits media content language

- **WHEN** the user changes the content language of an existing media record
- **THEN** the system SHALL update the corresponding Drift row through the media repository
- **AND** SHALL update the row timestamp
- **AND** SHALL refresh library and player-facing metadata

#### Scenario: Signed-in user edits synced media language

- **WHEN** a signed-in user changes the content language of a synced audio or video record
- **THEN** the system SHALL enqueue a sync update for that media entity
- **AND** SHALL preserve the selected language in outbound sync serialization

#### Scenario: Active player media language changes

- **WHEN** the user changes the content language for the media item currently open in the player
- **THEN** the system SHALL either update the active playback session language immediately
- **OR** SHALL tell the user that language-dependent behavior applies after reopening the media

### Requirement: Media language drives new shadow-reading records

The system SHALL stamp new shadow-reading recordings with the current media content language.

#### Scenario: User records a take after setting media language

- **WHEN** the user records a shadow-reading take for media whose content language is set
- **THEN** the system SHALL persist that language on the new recording
- **AND** SHALL use that language for subsequent pronunciation assessment eligibility

#### Scenario: Historical recordings keep original language

- **WHEN** the user changes media language after recordings already exist
- **THEN** the system SHALL NOT rewrite historical recording language values automatically
- **AND** SHALL use each recording's stored language when showing existing assessment metadata
