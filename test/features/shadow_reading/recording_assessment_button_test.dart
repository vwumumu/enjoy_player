import 'dart:convert';

import 'package:drift/native.dart';
import 'package:enjoy_player/core/theme/enjoy_tokens.dart';
import 'package:enjoy_player/data/db/app_database.dart';
import 'package:enjoy_player/data/db/app_database_provider.dart';
import 'package:enjoy_player/features/shadow_reading/presentation/recording_assessment_button.dart';
import 'package:enjoy_player/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

const _kAssessmentJson = '''
{
  "RecognitionStatus": "Success",
  "Offset": 0,
  "Duration": 10000000,
  "DisplayText": "Hi.",
  "NBest": [
    {
      "Confidence": 0.9,
      "Lexical": "hi",
      "ITN": "hi",
      "MaskedITN": "hi",
      "Display": "Hi.",
      "PronunciationAssessment": {
        "AccuracyScore": 90,
        "FluencyScore": 88,
        "CompletenessScore": 95,
        "PronScore": 91,
        "ProsodyScore": 80
      },
      "Words": [
        {
          "Word": "hi",
          "Offset": 0,
          "Duration": 10000000,
          "PronunciationAssessment": {
            "AccuracyScore": 92,
            "ErrorType": "None"
          }
        }
      ]
    }
  ]
}''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('RecordingAssessmentButton opens dialog when scored', (
    WidgetTester tester,
  ) async {
    final db = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(db.close);

    final id = const Uuid().v4();
    final now = DateTime.now();
    await db.recordingDao.insertRow(
      RecordingRow(
        id: id,
        targetType: 'Audio',
        targetId: 'm1',
        referenceStart: 0,
        referenceDuration: 5000,
        referenceText: 'Hi',
        language: 'en',
        duration: 1000,
        md5: null,
        audioUrl: null,
        pronunciationScore: 91,
        assessmentJson: jsonEncode(
          jsonDecode(_kAssessmentJson) as Map<String, dynamic>,
        ),
        localPath: '/tmp/fake.wav',
        syncStatus: 'local',
        serverUpdatedAt: null,
        createdAt: now,
        updatedAt: now,
      ),
    );

    final row = (await db.recordingDao.getById(id))!;

    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF1144AA));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: ThemeData(
            colorScheme: scheme,
            extensions: [EnjoyThemeTokens.build(scheme)],
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Center(
              child: RecordingAssessmentButton(row: row, echoActive: true),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('91'), findsOneWidget);

    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();

    expect(find.text('Pronunciation assessment'), findsOneWidget);
  });
}
