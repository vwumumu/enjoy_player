## ADDED Requirements

### Requirement: YouTube transcript requests use media content language
The system SHALL request YouTube transcripts using the media record's content language when that language is known and valid.

#### Scenario: YouTube media has known content language
- **WHEN** transcript resolution runs for a YouTube media record with a valid content language
- **THEN** the system SHALL send the corresponding worker language code to the YouTube transcript worker
- **AND** SHALL NOT replace that language with English solely because the global focus learning language is English

#### Scenario: YouTube media language is unknown
- **WHEN** transcript resolution runs for a YouTube media record whose content language is unknown or `und`
- **THEN** the system SHALL avoid treating English as a confirmed original language
- **AND** SHALL surface a way for the user to set the media language before retrying language-specific transcript fetches

### Requirement: YouTube transcript fetch can retry after language correction
The system SHALL allow YouTube transcript resolution to run again when a user changes the media content language.

#### Scenario: User corrects YouTube media language after an empty or failed fetch
- **WHEN** a user changes the content language of a YouTube media record after transcript resolution has completed with empty or error status
- **THEN** the system SHALL allow a new transcript fetch for the corrected language
- **AND** SHALL preserve existing transcript rows until the user deletes or replaces them

#### Scenario: Existing transcript tracks use their own language
- **WHEN** a media record's content language changes
- **THEN** the system SHALL NOT rewrite existing transcript row language values
- **AND** SHALL continue to display each transcript track with its stored language
