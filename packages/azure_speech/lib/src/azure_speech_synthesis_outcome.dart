import 'dart:typed_data';

import 'package:meta/meta.dart';

/// Result of Azure Speech text-to-speech (RIFF WAV bytes).
@immutable
final class AzureSpeechSynthesisOutcome {
  const AzureSpeechSynthesisOutcome({
    required this.audioBytes,
    this.format = 'wav',
  });

  final Uint8List audioBytes;
  final String format;
}
