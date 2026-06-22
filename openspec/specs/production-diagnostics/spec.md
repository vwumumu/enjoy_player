# production-diagnostics Specification

## Purpose

Local-only diagnostic logging and export for production support handoff. Phase 1 covers rotating redacted logs, opt-in verbose allowlist, zip export from Settings → About, and default-tier YouTube stall warnings — no remote upload.

## Requirements

### Requirement: Rotating local log file

The application SHALL persist log records to a rotating file under the application support directory in all build modes (debug, profile, and release). The sink MUST apply size-based rotation with a bounded total footprint (target: approximately 2 MB per file, up to 3 files). Records at INFO level and above MUST be written by default; records below INFO MUST NOT be written unless diagnostic verbose mode is enabled for allowlisted loggers.

#### Scenario: Release build writes INFO logs to disk

- **WHEN** the application runs a release build and a component logs at INFO or higher
- **THEN** the message is appended to the rotating log file on disk

#### Scenario: Log rotation prevents unbounded growth

- **WHEN** the active log file exceeds the configured size limit
- **THEN** the system rotates to a new file and discards the oldest rotated file beyond the retention count

### Requirement: Log redaction before persistence

The system SHALL redact sensitive content from log lines before writing them to disk. Redaction MUST cover authorization headers or bearer tokens, cookie values if present in log text, and SHOULD truncate absolute file paths to basename-only where practical.

#### Scenario: HTTP authorization not stored

- **WHEN** a log line would contain an Authorization header or bearer token
- **THEN** the persisted line contains a redacted placeholder instead of the secret value

### Requirement: Session header on startup

On each application cold start, the system SHALL write a session header to the log file containing application version, target platform, distribution channel, locale, and whether diagnostic verbose logging is enabled.

#### Scenario: Support identifies build from log alone

- **WHEN** a user exports a log file after launching the app once
- **THEN** the log contains a startup header with version and platform metadata

### Requirement: Diagnostic verbose logging toggle

The application SHALL provide an opt-in setting (default off) that elevates logging verbosity for an allowlisted set of diagnostic loggers (including YouTube player/WebView, sync, API client, auth, and update). Enabling the toggle MUST NOT change API endpoints, routing, or playback behavior. The toggle state MUST persist across app restarts.

#### Scenario: User enables verbose diagnostics

- **WHEN** the user turns on diagnostic logging in Settings → About
- **THEN** allowlisted loggers emit FINE-level records to the log file until the user turns the toggle off

#### Scenario: Non-allowlisted loggers stay at default verbosity

- **WHEN** diagnostic verbose logging is enabled
- **THEN** loggers outside the allowlist continue to follow the default root level (INFO in release)

### Requirement: Export diagnostic report

The application SHALL provide an action in Settings → About to export a diagnostic report as a zip archive. The archive MUST include all available rotated log files and a `manifest.json` with version, platform, distribution channel, export timestamp, and diagnostic toggle state. The user MUST be able to save the zip to a user-chosen location or platform-default downloads location without manually navigating application support directories.

#### Scenario: User exports report for support

- **WHEN** the user taps Export diagnostic report
- **THEN** the system creates a zip containing logs and manifest and presents a save/share flow

#### Scenario: Export works without verbose mode

- **WHEN** diagnostic verbose logging is off
- **THEN** export still includes default-tier logs and session metadata

### Requirement: YouTube playback stall warning

When YouTube watch-page load completes (`load_stop`) but playback never reaches a first playing state within a bounded timeout (target 30 seconds), the YouTube player engine SHALL log a single WARNING indicating a playback stall, including the video id. This warning MUST be emitted at default log verbosity without requiring diagnostic verbose mode.

#### Scenario: Stall visible in default release logs

- **WHEN** the WebView reports load stop for a YouTube video and no playing state occurs within the timeout
- **THEN** the log contains a WARNING describing the stalled playback

#### Scenario: Successful playback does not stall-warning

- **WHEN** the YouTube engine reports first playing before the timeout
- **THEN** no playback stall WARNING is logged for that open

### Requirement: Privacy disclosure for diagnostics

Settings → About MUST display brief copy explaining that diagnostic reports may contain app version, error messages, and media identifiers; that reports stay on device until exported; and that diagnostic verbose mode increases detail written locally.

#### Scenario: User sees privacy note before enabling verbose mode

- **WHEN** the user views the diagnostic logging control
- **THEN** explanatory privacy text is visible adjacent to the toggle or export action
