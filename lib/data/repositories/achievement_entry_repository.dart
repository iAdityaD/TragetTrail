import 'package:sqflite/sqflite.dart';

import '../../domain/models/achievement_entry.dart';
import '../local/app_database.dart';

class AchievementEntryRepository {
  AchievementEntryRepository(this._database);

  final AppDatabase _database;

  Future<List<AchievementEntry>> fetchByCountdown(String countdownId) async {
    final db = await _database.database;
    final rows = await db.query(
      'achievement_entries',
      where: 'countdown_id = ?',
      whereArgs: [countdownId],
      orderBy: 'entry_date DESC, created_at DESC',
    );
    return rows.map(AchievementEntry.fromMap).toList();
  }

  Future<void> save(AchievementEntry entry) async {
    final db = await _database.database;
    await db.insert(
      'achievement_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(String entryId) async {
    final db = await _database.database;
    await db.delete(
      'achievement_entries',
      where: 'id = ?',
      whereArgs: [entryId],
    );
  }

  Future<void> deleteForCountdown(String countdownId) async {
    final db = await _database.database;
    await db.delete(
      'achievement_entries',
      where: 'countdown_id = ?',
      whereArgs: [countdownId],
    );
  }
}
