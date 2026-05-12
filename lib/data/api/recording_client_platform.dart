/// Resolves `client_platform` for recording API payloads.
library;

import 'recording_client_platform_stub.dart'
    if (dart.library.io) 'recording_client_platform_io.dart'
    as recording_platform;

/// Lowercase OS key for [RecordingApi.clientPlatform] (`windows`, `macos`, …).
String recordingClientPlatformValue() =>
    recording_platform.recordingClientPlatformValue();
