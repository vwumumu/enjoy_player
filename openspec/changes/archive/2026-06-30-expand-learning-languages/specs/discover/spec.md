## ADDED Requirements

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
