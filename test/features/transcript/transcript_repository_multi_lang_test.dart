import 'package:drift/native.dart';
import 'package:enjoy_player/core/ids/enjoy_ids.dart';
import 'package:enjoy_player/data/api/services/ai/youtube_transcripts_api.dart';
import 'package:enjoy_player/data/db/app_database.dart';
import 'package:enjoy_player/features/transcript/data/transcript_repository.dart';
import 'package:enjoy_player/features/transcript/domain/transcript_fetch_status.dart';
import 'package:flutter_test/flutter_test.dart';

/// Flexible YouTube client fake for the multi-language path: records the last
/// call shape and returns a configured response (or a sequenced stream).
class _MultiYoutubeClient implements YoutubeTranscriptsClient {
  _MultiYoutubeClient({this.transcripts, this.single, this.sequence});

  final Map<String, dynamic>? transcripts;
  final Map<String, dynamic>? single;
  final List<Map<String, dynamic>>? sequence;

  String? lastVideoId;
  String? lastLanguage;
  List<String>? lastLanguages;
  int? lastWaitMs;
  bool? lastForceRefresh;
  int pollTranscriptsCalls = 0;
  int pollTranscriptCalls = 0;
  var _seqIndex = 0;

  @override
  Future<Map<String, dynamic>> pollTranscripts({
    required String videoId,
    required List<String> languages,
    String? captionFetch,
    bool? forceRefresh,
    int? waitMs,
  }) async {
    lastVideoId = videoId;
    lastLanguages = List<String>.from(languages);
    lastWaitMs = waitMs;
    lastForceRefresh = forceRefresh;
    pollTranscriptsCalls++;
    if (sequence != null) {
      final idx = _seqIndex < sequence!.length
          ? _seqIndex
          : sequence!.length - 1;
      _seqIndex++;
      return Map<String, dynamic>.from(sequence![idx]);
    }
    return Map<String, dynamic>.from(transcripts ?? const {});
  }

  @override
  Future<Map<String, dynamic>> pollTranscript({
    required String videoId,
    required String language,
    String? captionFetch,
    bool? forceRefresh,
    int? waitMs,
  }) async {
    lastVideoId = videoId;
    lastLanguage = language;
    lastWaitMs = waitMs;
    lastForceRefresh = forceRefresh;
    pollTranscriptCalls++;
    return Map<String, dynamic>.from(single ?? const {});
  }
}

Map<String, dynamic> _cue(String language, {String source = 'official'}) => {
  'videoId': 'vid',
  'language': language,
  'source': source,
  'format': 'enjoy',
  'cached': true,
  'timeline': [
    {'text': 'hi', 'start': 0, 'duration': 1000},
  ],
  'rawUrl': 'youtube/vid/$language/$source/raw.json',
  'metadata': {'title': 'Cap ($language)'},
};

void main() {
  group('TranscriptRepository bilingual', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(executor: NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    Future<void> insertYoutubeVideo({
      required String mediaId,
      required String vid,
      String language = 'und',
    }) async {
      final now = DateTime.now();
      await db.videoDao.insertRow(
        VideoRow(
          id: mediaId,
          vid: vid,
          provider: 'youtube',
          title: 'Test',
          description: null,
          thumbnailUrl: null,
          durationSeconds: 0,
          language: language,
          source: 'youtube',
          localUri: null,
          md5: null,
          size: null,
          mediaUrl: 'https://www.youtube.com/watch?v=$vid',
          syncStatus: null,
          serverUpdatedAt: null,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    test('T006: native null routes to single-language path', () async {
      const vid = 'abcdefghijk';
      final mediaId = enjoyVideoId(provider: 'youtube', vid: vid);
      await insertYoutubeVideo(mediaId: mediaId, vid: vid, language: 'en');

      final client = _MultiYoutubeClient(
        single: {'status': 'ready', ..._cue('en')},
      );
      final repo = TranscriptRepository(db, null, client);
      await repo.resolveOnOpen(mediaId, fetchCloud: true);

      expect(client.pollTranscriptCalls, 1);
      expect(client.pollTranscriptsCalls, 0);
      expect(client.lastLanguage, 'en');
    });

    test(
      'T006: native base == source routes to single-language path',
      () async {
        const vid = 'abcdefghijk';
        final mediaId = enjoyVideoId(provider: 'youtube', vid: vid);
        await insertYoutubeVideo(mediaId: mediaId, vid: vid, language: 'en-US');

        final client = _MultiYoutubeClient(
          single: {'status': 'ready', ..._cue('en')},
        );
        final repo = TranscriptRepository(db, null, client);
        await repo.resolveOnOpen(
          mediaId,
          fetchCloud: true,
          nativeLanguage: 'en-GB',
        );

        expect(client.pollTranscriptCalls, 1);
        expect(client.pollTranscriptsCalls, 0);
      },
    );

    test(
      'T006: differing native uses multi-language path with base codes',
      () async {
        const vid = 'abcdefghijk';
        final mediaId = enjoyVideoId(provider: 'youtube', vid: vid);
        await insertYoutubeVideo(mediaId: mediaId, vid: vid, language: 'en-US');

        final client = _MultiYoutubeClient(
          transcripts: {
            'status': 'ready',
            'videoId': vid,
            'transcripts': [_cue('en'), _cue('zh')],
          },
        );
        final repo = TranscriptRepository(db, null, client);
        await repo.resolveOnOpen(
          mediaId,
          fetchCloud: true,
          nativeLanguage: 'zh-CN',
        );

        expect(client.pollTranscriptsCalls, 1);
        expect(client.pollTranscriptCalls, 0);
        expect(client.lastLanguages, ['en', 'zh']);
      },
    );

    test(
      'T007/T008: ready(2) upserts two rows and assigns primary/secondary',
      () async {
        const vid = 'abcdefghijk';
        final mediaId = enjoyVideoId(provider: 'youtube', vid: vid);
        await insertYoutubeVideo(mediaId: mediaId, vid: vid, language: 'en');

        final client = _MultiYoutubeClient(
          transcripts: {
            'status': 'ready',
            'videoId': vid,
            'transcripts': [_cue('en'), _cue('zh')],
          },
        );
        final repo = TranscriptRepository(db, null, client);
        final result = await repo.resolveOnOpen(
          mediaId,
          fetchCloud: true,
          nativeLanguage: 'zh-CN',
        );

        expect(result.cloud.status, TranscriptCloudFetchStatus.success);
        expect(result.cloud.storedCount, 2);

        final enId = enjoyTranscriptId(
          targetType: 'Video',
          targetId: mediaId,
          language: 'en',
          source: 'official',
        );
        final zhId = enjoyTranscriptId(
          targetType: 'Video',
          targetId: mediaId,
          language: 'zh',
          source: 'official',
        );

        expect(await db.transcriptDao.getById(enId), isNotNull);
        expect(await db.transcriptDao.getById(zhId), isNotNull);

        final session = await db.echoSessionDao.getLatestForTarget(
          'Video',
          mediaId,
        );
        expect(session?.transcriptId, enId); // primary = source/original
        expect(session?.secondaryTranscriptId, zhId); // secondary = native
      },
    );

    test(
      'T016a: partial missing translation stores original, success, no error',
      () async {
        const vid = 'abcdefghijk';
        final mediaId = enjoyVideoId(provider: 'youtube', vid: vid);
        await insertYoutubeVideo(mediaId: mediaId, vid: vid, language: 'en');

        final client = _MultiYoutubeClient(
          transcripts: {
            'status': 'partial',
            'videoId': vid,
            'transcripts': [_cue('en')],
            'missingLanguages': ['zh'],
          },
        );
        final repo = TranscriptRepository(db, null, client);
        final result = await repo.resolveOnOpen(
          mediaId,
          fetchCloud: true,
          nativeLanguage: 'zh-CN',
        );

        expect(result.cloud.status, TranscriptCloudFetchStatus.success);
        expect(result.cloud.storedCount, 1);

        final enId = enjoyTranscriptId(
          targetType: 'Video',
          targetId: mediaId,
          language: 'en',
          source: 'official',
        );
        final session = await db.echoSessionDao.getLatestForTarget(
          'Video',
          mediaId,
        );
        expect(session?.transcriptId, enId); // original still primary
        expect(session?.secondaryTranscriptId, isNull); // translation missing
      },
    );

    test(
      'T016b: partial missing source stores translation, no invented primary',
      () async {
        const vid = 'abcdefghijk';
        final mediaId = enjoyVideoId(provider: 'youtube', vid: vid);
        await insertYoutubeVideo(mediaId: mediaId, vid: vid, language: 'en');

        final client = _MultiYoutubeClient(
          transcripts: {
            'status': 'partial',
            'videoId': vid,
            'transcripts': [_cue('zh')],
            'missingLanguages': ['en'],
          },
        );
        final repo = TranscriptRepository(db, null, client);
        final result = await repo.resolveOnOpen(
          mediaId,
          fetchCloud: true,
          nativeLanguage: 'zh-CN',
        );

        // Still a success: the learner gets a readable caption, never an error.
        expect(result.cloud.status, TranscriptCloudFetchStatus.success);
        expect(result.cloud.storedCount, 1);

        final zhId = enjoyTranscriptId(
          targetType: 'Video',
          targetId: mediaId,
          language: 'zh',
          source: 'official',
        );
        expect(await db.transcriptDao.getById(zhId), isNotNull);

        final session = await db.echoSessionDao.getLatestForTarget(
          'Video',
          mediaId,
        );
        // Primary must point to an existing row (the translation), not a
        // non-existent source row — ensurePrimaryTranscript sort fallback.
        expect(session?.transcriptId, zhId);
        expect(session?.secondaryTranscriptId, isNull);
      },
    );

    test('T017: worker failed returns error and preserves stored rows', () async {
      const vid = 'abcdefghijk';
      final mediaId = enjoyVideoId(provider: 'youtube', vid: vid);
      await insertYoutubeVideo(mediaId: mediaId, vid: vid, language: 'en');

      // Pre-store a track so we can prove a `failed` response does not wipe it.
      final preId = enjoyTranscriptId(
        targetType: 'Video',
        targetId: mediaId,
        language: 'en',
        source: 'user',
      );
      final now = DateTime.now();
      await db.transcriptDao.upsert(
        TranscriptRow(
          id: preId,
          targetType: 'Video',
          targetId: mediaId,
          language: 'en',
          source: 'user',
          timelineJson: '[{"text":"x","start":0,"duration":1000}]',
          referenceId: null,
          label: 'pre',
          trackIndex: null,
          syncStatus: null,
          serverUpdatedAt: null,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final client = _MultiYoutubeClient(
        transcripts: {'status': 'failed', 'error': 'boom'},
      );
      final repo = TranscriptRepository(db, null, client);
      final result = await repo.resolveOnOpen(
        mediaId,
        fetchCloud: true,
        nativeLanguage: 'zh-CN',
      );

      expect(result.cloud.status, TranscriptCloudFetchStatus.error);
      // The previously stored row survives the failure.
      expect(await db.transcriptDao.getById(preId), isNotNull);
    });

    test('T018: und source language skips cloud (no worker calls)', () async {
      const vid = 'abcdefghijk';
      final mediaId = enjoyVideoId(provider: 'youtube', vid: vid);
      await insertYoutubeVideo(mediaId: mediaId, vid: vid, language: 'und');

      final client = _MultiYoutubeClient(
        transcripts: {
          'status': 'ready',
          'transcripts': [_cue('en')],
        },
      );
      final repo = TranscriptRepository(db, null, client);
      final result = await repo.resolveOnOpen(
        mediaId,
        fetchCloud: true,
        nativeLanguage: 'zh-CN',
      );

      expect(result.cloud.status, TranscriptCloudFetchStatus.skipped);
      expect(client.pollTranscriptsCalls, 0);
      expect(client.pollTranscriptCalls, 0);
    });

    test(
      'T023: long-poll sends non-zero waitMs and retries until ready',
      () async {
        const vid = 'abcdefghijk';
        final mediaId = enjoyVideoId(provider: 'youtube', vid: vid);
        await insertYoutubeVideo(mediaId: mediaId, vid: vid, language: 'en');

        final client = _MultiYoutubeClient(
          sequence: [
            {
              'status': 'generating',
              'jobId': 'j',
              'stage': 'running',
              'created': true,
            },
            {
              'status': 'generating',
              'jobId': 'j',
              'stage': 'running',
              'created': false,
            },
            {
              'status': 'ready',
              'videoId': vid,
              'transcripts': [_cue('en'), _cue('zh')],
            },
          ],
        );
        // 3 attempts, zero backoff so the test does not sleep.
        final repo = TranscriptRepository(db, null, client, 3, Duration.zero);
        final result = await repo.resolveOnOpen(
          mediaId,
          fetchCloud: true,
          nativeLanguage: 'zh-CN',
        );

        expect(result.cloud.status, TranscriptCloudFetchStatus.success);
        expect(client.pollTranscriptsCalls, 3); // generating, generating, ready
        expect(client.lastWaitMs, isNotNull);
        expect(client.lastWaitMs! > 0, isTrue); // server-side long-poll engaged
      },
    );

    test(
      'T023: generating exhausts the attempt budget and records error',
      () async {
        const vid = 'abcdefghijk';
        final mediaId = enjoyVideoId(provider: 'youtube', vid: vid);
        await insertYoutubeVideo(mediaId: mediaId, vid: vid, language: 'en');

        final client = _MultiYoutubeClient(
          sequence: [
            {
              'status': 'generating',
              'jobId': 'j',
              'stage': 'running',
              'created': true,
            },
          ],
        );
        final repo = TranscriptRepository(db, null, client, 2, Duration.zero);
        final result = await repo.resolveOnOpen(
          mediaId,
          fetchCloud: true,
          nativeLanguage: 'zh-CN',
        );

        expect(result.cloud.status, TranscriptCloudFetchStatus.error);
        expect(client.pollTranscriptsCalls, 2); // bounded by the attempt budget
      },
    );

    test(
      'T024: already-fetched target is skipped with zero worker calls',
      () async {
        const vid = 'abcdefghijk';
        final mediaId = enjoyVideoId(provider: 'youtube', vid: vid);
        await insertYoutubeVideo(mediaId: mediaId, vid: vid, language: 'en');

        // Seed a successful fetch state so reopen is network-free.
        await db.transcriptFetchStateDao.upsertOutcome(
          targetType: 'Video',
          targetId: mediaId,
          lastFetchedAt: DateTime.now(),
          lastStatus: 'success',
          lastError: null,
        );

        final client = _MultiYoutubeClient(
          transcripts: {
            'status': 'ready',
            'transcripts': [_cue('en')],
          },
        );
        final repo = TranscriptRepository(db, null, client);
        final result = await repo.resolveOnOpen(
          mediaId,
          fetchCloud: true,
          nativeLanguage: 'zh-CN',
        );

        expect(result.cloud.status, TranscriptCloudFetchStatus.skipped);
        expect(client.pollTranscriptsCalls, 0);
        expect(client.pollTranscriptCalls, 0);
      },
    );

    test(
      'forceRefresh bypasses the already-fetched skip on the multi path',
      () async {
        const vid = 'abcdefghijk';
        final mediaId = enjoyVideoId(provider: 'youtube', vid: vid);
        await insertYoutubeVideo(mediaId: mediaId, vid: vid, language: 'en');

        await db.transcriptFetchStateDao.upsertOutcome(
          targetType: 'Video',
          targetId: mediaId,
          lastFetchedAt: DateTime.now(),
          lastStatus: 'success',
          lastError: null,
        );

        final client = _MultiYoutubeClient(
          transcripts: {
            'status': 'ready',
            'videoId': vid,
            'transcripts': [_cue('en'), _cue('zh')],
          },
        );
        final repo = TranscriptRepository(db, null, client);
        final result = await repo.resolveOnOpen(
          mediaId,
          forceCloud: true,
          fetchCloud: true,
          nativeLanguage: 'zh-CN',
        );

        expect(result.cloud.status, TranscriptCloudFetchStatus.success);
        expect(client.pollTranscriptsCalls, 1);
        expect(client.lastForceRefresh, isTrue); // FR-010 refresh re-pulls both
      },
    );
  });
}
