import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:enjoy_player/data/db/app_database.dart';
import 'package:enjoy_player/data/files/file_storage.dart';
import 'package:enjoy_player/features/library/application/library_media_provider.dart';
import 'package:enjoy_player/features/library/application/library_repository_provider.dart';
import 'package:enjoy_player/features/library/application/library_search_provider.dart';
import 'package:enjoy_player/features/library/data/library_repository.dart';
import 'package:enjoy_player/features/library/domain/media.dart';
import 'package:enjoy_player/features/sync/application/sync_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../support/test_path_provider.dart';

typedef _FilteredLists = ({List<Media> audio, List<Media> video});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('library provider dedupe', () {
    late AppDatabase db;
    late Directory root;
    late MediaLibraryRepository repo;

    setUp(() async {
      root = Directory.systemTemp.createTempSync('enjoy_lib_media_prov_test');
      PathProviderPlatform.instance = TestPathProvider(root.path);
      db = AppDatabase(executor: NativeDatabase.memory());
      repo = MediaLibraryRepository(db, FileStorage());
      // Seed two audio + one video so the lists are non-trivial.
      await db.audioDao.insertRow(_audio('a-old', 'Alpha', 'old', DateTime(2026, 1, 1)));
      await db.audioDao.insertRow(_audio('b-new', 'Bravo', 'new', DateTime(2026, 6, 1)));
      await db.videoDao.insertRow(_video('v-mid', 'Charlie', 'mid', DateTime(2026, 3, 1)));
    });

    tearDown(() async {
      await db.close();
      if (root.existsSync()) {
        root.deleteSync(recursive: true);
      }
    });

    ProviderContainer makeContainer() {
      return ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          mediaLibraryRepositoryProvider.overrideWithValue(repo),
          syncEnqueueProvider.overrideWithValue((_, _, _) async {}),
        ],
      );
    }

    test(
      'libraryHomeRecentsProvider skips identical re-emissions',
      () async {
        final container = makeContainer();
        addTearDown(container.dispose);
        final emissions = <int>[];
        final sub = container.listen<List<Media>>(
          libraryHomeRecentsProvider,
          (_, next) => emissions.add(next.length),
          fireImmediately: true,
        );
        // Wait for the initial emission (seeded data).
        await container.read(libraryHomeRecentsProvider.future);
        emissions.clear();

        // Force watchAll to re-query without changing the merged list by
        // touching an unrelated column. Drift's watchAll re-emits on any
        // row update; the merged list is the same so the home recents
        // top-12 must skip the emission.
        final oldRow = await db.audioDao.getById('a-old');
        await db.audioDao.insertRow(
          oldRow!.copyWith(size: Value(2)),
        );
        // Yield enough times for the StreamProvider to flush.
        await Future<void>.delayed(const Duration(milliseconds: 30));
        expect(
          emissions,
          isEmpty,
          reason:
              'Identical top-12 should not re-emit. '
              'Got $emissions emissions after a no-op write.',
        );

        // Real change to the top-12 (a brand-new most-recent item) MUST emit.
        await db.videoDao.insertRow(
          _video('v-newest', 'Delta', 'newest', DateTime(2026, 12, 1)),
        );
        await Future<void>.delayed(const Duration(milliseconds: 30));
        expect(
          emissions,
          isNotEmpty,
          reason:
              'A real top-12 change (newest item) must re-emit. '
              'Got $emissions emissions.',
        );

        sub.close();
      },
    );

    test(
      'libraryFilteredListsProvider skips identical re-emissions '
      'and re-emits on real changes',
      () async {
        final container = makeContainer();
        addTearDown(container.dispose);
        final emissions = <String>[];
        final sub = container.listen<_FilteredLists>(
          libraryFilteredListsProvider,
          (prev, next) {
            final sig = _signature(next);
            if (emissions.isNotEmpty && emissions.last == sig) return;
            emissions.add(sig);
          },
          fireImmediately: true,
        );
        await container.read(libraryFilteredListsProvider.future);
        emissions.clear();

        // No-op write: bumping fileSize on the older audio row changes
        // the merged list but the title-sorted audio half is still
        // [Alpha, Bravo] and the video half is still [Charlie] — so the
        // dedupe must skip this emission.
        final oldRow = await db.audioDao.getById('a-old');
        await db.audioDao.insertRow(
          oldRow!.copyWith(size: Value(9)),
        );
        await Future<void>.delayed(const Duration(milliseconds: 30));
        expect(emissions, isEmpty, reason: 'No-op write should be deduped.');

        // Real change: rename Alpha → Zebra. Now audio list is
        // [Bravo, Zebra], which differs, so we must see an emission.
        final renamedRow = await db.audioDao.getById('a-old');
        await db.audioDao.insertRow(
          renamedRow!.copyWith(title: 'Zebra'),
        );
        await Future<void>.delayed(const Duration(milliseconds: 30));
        expect(
          emissions,
          isNotEmpty,
          reason:
              'A real filter-list change (renamed audio) must re-emit. '
              'Got $emissions emissions.',
        );

        sub.close();
      },
    );

    test(
      'libraryFilteredListsProvider re-emits when search query changes',
      () async {
        final container = makeContainer();
        addTearDown(container.dispose);
        final emissions = <int>[];
        final sub = container.listen<_FilteredLists>(
          libraryFilteredListsProvider,
          (prev, next) =>
              emissions.add(next.audio.length + next.video.length),
          fireImmediately: true,
        );
        await container.read(libraryFilteredListsProvider.future);
        emissions.clear();

        container.read(librarySearchProvider.notifier).setQuery('zz');
        await Future<void>.delayed(const Duration(milliseconds: 30));
        // Empty result set is a real change; should emit.
        expect(emissions, isNotEmpty);
        expect(emissions.last, 0);

        sub.close();
      },
    );
  });
}

String _signature(_FilteredLists v) {
  return '${v.audio.map((m) => m.id).join(',')}|'
      '${v.video.map((m) => m.id).join(',')}';
}

AudioRow _audio(
  String id,
  String title,
  String aid,
  DateTime when,
) {
  return AudioRow(
    id: id,
    aid: aid,
    provider: 'user',
    title: title,
    description: null,
    thumbnailUrl: null,
    durationSeconds: 10,
    language: 'und',
    translationKey: null,
    sourceText: null,
    voice: null,
    source: null,
    localUri: 'file:///$aid.mp3',
    md5: null,
    size: 1,
    mediaUrl: null,
    syncStatus: null,
    serverUpdatedAt: null,
    createdAt: when,
    updatedAt: when,
  );
}

VideoRow _video(
  String id,
  String title,
  String vid,
  DateTime when,
) {
  return VideoRow(
    id: id,
    vid: vid,
    provider: 'user',
    title: title,
    description: null,
    thumbnailUrl: null,
    durationSeconds: 10,
    language: 'und',
    source: null,
    localUri: 'file:///$vid.mp4',
    md5: null,
    size: 1,
    mediaUrl: null,
    syncStatus: null,
    serverUpdatedAt: null,
    createdAt: when,
    updatedAt: when,
  );
}
