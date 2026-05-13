/// Opens the dictionary / translation sheet from transcript selection.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:enjoy_player/core/application/app_language_catalog.dart';
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
import 'package:enjoy_player/features/transcript/application/active_transcript_provider.dart';
import 'package:enjoy_player/features/transcript/application/all_transcripts_provider.dart';
import 'package:enjoy_player/features/transcript/domain/transcript_track.dart';

void openTranscriptLookup({
  required WidgetRef ref,
  required BuildContext context,
  required String selectedText,
  required List<TranscriptLine> lines,
}) {
  final chrome = ref.read(playerControllerProvider.select(playbackChromeOf));
  final prefs = ref.read(appPreferencesCtrlProvider).valueOrNull;
  final learnTag =
      prefs?.effectiveLearningLanguage ?? kDefaultLearningLanguageTag;
  final echo = ref.read(echoModeProvider);
  final posAsync = ref.read(displayPositionProvider);
  final tSec = switch (posAsync) {
    AsyncData(:final value) => value.inMilliseconds / 1000.0,
    _ => 0.0,
  };

  final mediaId = chrome?.mediaId;
  TranscriptTrack? activeTrack;
  if (mediaId != null) {
    final activeId = ref.read(activeTranscriptIdProvider(mediaId)).valueOrNull;
    final tracks =
        ref.read(allTranscriptsForMediaProvider(mediaId)).valueOrNull ??
        const <TranscriptTrack>[];
    if (activeId != null) {
      for (final t in tracks) {
        if (t.id == activeId) {
          activeTrack = t;
          break;
        }
      }
    }
  }

  final src = resolveLookupSource(activeTrack?.language, learningTag: learnTag);
  final ctx = buildVocabularyContext(
    lines: lines,
    echo: echo,
    currentTimeSeconds: tSec,
    primaryLanguage: src,
  );
  final request = LookupRequest(
    selectedText: selectedText,
    sourceLanguage: src,
    targetLanguage: resolveLookupTarget(
      prefs?.nativeLanguage,
      learningTag: learnTag,
    ),
    contextualContext: ctx,
  );
  unawaited(
    ref.read(lookupCoordinatorProvider.notifier).open(context, request),
  );
}
