/// Opens the dictionary / translation sheet from transcript selection.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:enjoy_player/core/application/app_preferences_provider.dart';
import 'package:enjoy_player/core/riverpod/async_value_x.dart';
import 'package:enjoy_player/data/subtitle/transcript_line.dart';
import 'package:enjoy_player/features/lookup/application/lookup_coordinator.dart';
import 'package:enjoy_player/features/lookup/application/lookup_target_languages.dart';
import 'package:enjoy_player/features/lookup/application/vocabulary_context_builder.dart';
import 'package:enjoy_player/features/lookup/domain/lookup_request.dart';
import 'package:enjoy_player/features/player/application/display_position_provider.dart';
import 'package:enjoy_player/features/player/application/echo_mode_provider.dart';
import 'package:enjoy_player/features/player/application/player_controller.dart';
import 'package:enjoy_player/features/player/domain/playback_session.dart';

void openTranscriptLookup({
  required WidgetRef ref,
  required BuildContext context,
  required String selectedText,
  required List<TranscriptLine> lines,
}) {
  final chrome = ref.read(playerControllerProvider.select(playbackChromeOf));
  final prefs = ref.read(appPreferencesCtrlProvider).valueOrNull;
  final native = prefs?.effectiveNativeLanguage ?? 'en';
  final echo = ref.read(echoModeProvider);
  final posAsync = ref.read(displayPositionProvider);
  final tSec = switch (posAsync) {
    AsyncData(:final value) => value.inMilliseconds / 1000.0,
    _ => 0.0,
  };
  final src = lookupSourceLanguage(chrome?.language);
  final ctx = buildVocabularyContext(
    lines: lines,
    echo: echo,
    currentTimeSeconds: tSec,
    primaryLanguage: src,
  );
  final request = LookupRequest(
    selectedText: selectedText,
    sourceLanguage: src,
    targetLanguage: lookupTargetLanguage(native),
    contextualContext: ctx,
  );
  unawaited(ref.read(lookupCoordinatorProvider.notifier).open(context, request));
}
