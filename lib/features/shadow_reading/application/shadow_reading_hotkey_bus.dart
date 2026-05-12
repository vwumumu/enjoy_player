/// Tick-based intents from global hotkeys → shadow-reading widgets (recording / pitch / assessment).
library;

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shadow_reading_hotkey_bus.g.dart';

@immutable
class ShadowReadingHotkeyTicks {
  const ShadowReadingHotkeyTicks({
    required this.recording,
    required this.recordingCancel,
    required this.playback,
    required this.pitchContour,
    required this.assessment,
    required this.isRecordingActive,
  });

  final int recording;
  final int recordingCancel;
  final int playback;
  final int pitchContour;
  final int assessment;
  final bool isRecordingActive;

  static const initial = ShadowReadingHotkeyTicks(
    recording: 0,
    recordingCancel: 0,
    playback: 0,
    pitchContour: 0,
    assessment: 0,
    isRecordingActive: false,
  );

  ShadowReadingHotkeyTicks copyWith({
    int? recording,
    int? recordingCancel,
    int? playback,
    int? pitchContour,
    int? assessment,
    bool? isRecordingActive,
  }) {
    return ShadowReadingHotkeyTicks(
      recording: recording ?? this.recording,
      recordingCancel: recordingCancel ?? this.recordingCancel,
      playback: playback ?? this.playback,
      pitchContour: pitchContour ?? this.pitchContour,
      assessment: assessment ?? this.assessment,
      isRecordingActive: isRecordingActive ?? this.isRecordingActive,
    );
  }
}

@Riverpod(keepAlive: true)
class ShadowReadingHotkeyBus extends _$ShadowReadingHotkeyBus {
  @override
  ShadowReadingHotkeyTicks build() => ShadowReadingHotkeyTicks.initial;

  void pulseRecording() {
    state = state.copyWith(recording: state.recording + 1);
  }

  void pulsePlayback() {
    state = state.copyWith(playback: state.playback + 1);
  }

  void pulsePitchContour() {
    state = state.copyWith(pitchContour: state.pitchContour + 1);
  }

  void pulseAssessment() {
    state = state.copyWith(assessment: state.assessment + 1);
  }

  void setRecordingActive(bool active) {
    if (state.isRecordingActive == active) return;
    state = state.copyWith(isRecordingActive: active);
  }

  void pulseRecordingCancel() {
    state = state.copyWith(recordingCancel: state.recordingCancel + 1);
  }
}
