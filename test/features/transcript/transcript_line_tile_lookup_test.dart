import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:enjoy_player/data/subtitle/transcript_line.dart';
import 'package:enjoy_player/features/transcript/presentation/transcript_line_tile.dart';
import 'package:enjoy_player/l10n/app_localizations.dart';

Widget transcriptTileHarness(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('selectable transcript line uses SelectableText', (tester) async {
    await tester.pumpWidget(
      transcriptTileHarness(
        TranscriptLineTile(
          line: const TranscriptLine(
            text: 'Hello world',
            startMs: 0,
            durationMs: 2000,
          ),
          secondaryText: null,
          isActive: true,
          inEcho: false,
          groupedInEcho: false,
          selectable: true,
          onLookupRequested: (_) {},
          onTap: () {},
        ),
      ),
    );

    expect(find.byType(SelectableText), findsOneWidget);
  });

  testWidgets('non-selectable transcript line uses plain Text.rich', (
    tester,
  ) async {
    await tester.pumpWidget(
      transcriptTileHarness(
        TranscriptLineTile(
          line: const TranscriptLine(
            text: 'Hello world',
            startMs: 0,
            durationMs: 2000,
          ),
          secondaryText: null,
          isActive: false,
          inEcho: false,
          groupedInEcho: false,
          selectable: false,
          onTap: () {},
        ),
      ),
    );

    expect(find.byType(SelectableText), findsNothing);
    expect(find.byType(InkWell), findsOneWidget);
  });

  testWidgets('grouped echo line remains tappable when not selectable', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      transcriptTileHarness(
        TranscriptLineTile(
          line: const TranscriptLine(
            text: 'Hello world',
            startMs: 0,
            durationMs: 2000,
          ),
          secondaryText: null,
          isActive: false,
          inEcho: true,
          groupedInEcho: true,
          selectable: false,
          onTap: () => tapped = true,
        ),
      ),
    );

    expect(find.byType(SelectableText), findsNothing);
    expect(find.byType(InkWell), findsOneWidget);

    await tester.tap(find.text('Hello world'));

    expect(tapped, isTrue);
  });

  testWidgets('lookup runs from selection toolbar after explicit tap', (
    tester,
  ) async {
    String? lookedUp;
    await tester.pumpWidget(
      transcriptTileHarness(
        TranscriptLineTile(
          line: const TranscriptLine(
            text: 'Hello world',
            startMs: 0,
            durationMs: 2000,
          ),
          secondaryText: null,
          isActive: true,
          inEcho: false,
          groupedInEcho: false,
          selectable: true,
          onLookupRequested: (t) => lookedUp = t,
          onTap: () {},
        ),
      ),
    );

    final textCenter = tester.getCenter(find.text('Hello world'));
    await tester.tapAt(textCenter);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(textCenter);
    await tester.pumpAndSettle();

    expect(lookedUp, isNull);

    final lookUp = find.text('Look up');
    expect(lookUp, findsOneWidget);
    await tester.tap(lookUp);
    await tester.pumpAndSettle();

    expect(lookedUp, equals('Hello'));
  });
}
