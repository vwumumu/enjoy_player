import 'package:drift/native.dart';
import 'package:enjoy_player/data/db/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppDatabase can insert and read media', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final now = DateTime.now();
    const id = 'test-id';
    await db.mediaDao.insertRow(
      MediaRow(
        id: id,
        kind: 'audio',
        title: 'Test',
        sourceUri: 'file:///tmp/x.mp3',
        thumbnailPath: null,
        durationMs: 0,
        language: 'en',
        fileHash: 'abc',
        fileSize: 1,
        createdAt: now,
        updatedAt: now,
      ),
    );

    final row = await db.mediaDao.getById(id);
    expect(row, isNotNull);
    expect(row!.title, 'Test');
  });
}
