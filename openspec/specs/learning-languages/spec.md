# learning-languages Specification

## Purpose

Supported learning language catalog, user focus language, localized labels, and provider capability gating for lookup and pronunciation assessment across the app.

## Requirements

### Requirement: User can choose a focus learning language

The system SHALL allow the user to choose a focus learning language from the supported language catalog instead of forcing English.

#### Scenario: User changes focus learning language

- **WHEN** the user selects a supported focus learning language in settings or profile language controls
- **THEN** the system SHALL persist that language locally
- **AND** SHALL use it as the default language for Discover recommendations and import language suggestions

#### Scenario: Signed-in profile language sync

- **WHEN** the signed-in user's profile contains a supported learning language
- **THEN** the system SHALL apply that language as the local focus learning language
- **AND** SHALL NOT coerce it back to English solely because it is non-English

### Requirement: Language catalog supports provider capability metadata

The system SHALL maintain a shared language catalog that includes display labels, canonical tags, aliases, and provider capability metadata for supported learning workflows.

#### Scenario: Supported first-wave languages are listed

- **WHEN** the app presents learning or media language choices
- **THEN** the system SHALL include English, Japanese, Korean, Spanish, and French
- **AND** SHALL represent Korean with canonical BCP-47 tags based on `ko`, not `kor`

#### Scenario: Broad language tag is normalized for display

- **WHEN** the system receives a valid broad language tag such as `ja`, `ko`, `es`, or `fr`
- **THEN** the system SHALL display a localized human-readable language label
- **AND** SHALL preserve enough information to resolve provider-specific tags when needed

### Requirement: Pronunciation assessment is capability-gated by Azure locale

The system SHALL run Azure Speech pronunciation assessment only when the media language resolves to a supported Azure pronunciation assessment locale.

#### Scenario: Media language has a supported Azure locale

- **WHEN** the user requests pronunciation assessment for a recording whose media language resolves to a supported Azure locale
- **THEN** the system SHALL call Azure Speech with that exact supported locale
- **AND** SHALL NOT replace it with the global focus learning language

#### Scenario: Media language has no supported Azure locale

- **WHEN** the user views a recording for media whose language does not resolve to a supported Azure pronunciation assessment locale
- **THEN** the system SHALL disable or hide the run-assessment action
- **AND** SHALL explain that pronunciation assessment is unavailable for that language

#### Scenario: Unknown language is not assessed as English

- **WHEN** the media language is unknown, invalid, or `und`
- **THEN** the system SHALL NOT run pronunciation assessment by falling back to `en-US`
- **AND** SHALL ask the user to set the media language before assessment can run

### Requirement: Unsupported provider features are surfaced honestly

The system SHALL treat language validity separately from feature availability for provider-backed capabilities such as lookup, translation, transcript fetching, and pronunciation assessment.

#### Scenario: Valid language lacks a provider capability

- **WHEN** a media item has a valid language tag but a requested provider feature does not support that language
- **THEN** the system SHALL preserve the media language
- **AND** SHALL show a feature-specific unavailable state instead of changing the language
