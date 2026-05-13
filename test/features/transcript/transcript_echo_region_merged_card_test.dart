import 'package:enjoy_player/data/subtitle/transcript_line.dart';
import 'package:enjoy_player/features/player/application/echo_mode_provider.dart';
import 'package:enjoy_player/features/transcript/presentation/transcript_echo_region_merged_card.dart';
import 'package:enjoy_player/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('echo card lays out inside a scrollable', (tester) async {
    const lines = [
      TranscriptLine(text: 'First echo line', startMs: 0, durationMs: 1000),
      TranscriptLine(text: 'Second echo line', startMs: 1000, durationMs: 1000),
    ];
    const echo = EchoState(
      active: true,
      startLineIndex: 0,
      endLineIndex: 1,
      startTimeSeconds: -1,
      endTimeSeconds: -1,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ListView(
              children: const [
                EchoRegionMergedCard(
                  mediaId: 'media-1',
                  lines: lines,
                  echo: echo,
                  activeCueIndex: 0,
                  secondaryLines: [],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('First echo line'), findsOneWidget);
    expect(find.text('Second echo line'), findsOneWidget);
  });
}
