import 'package:sqflite/sqflite.dart';

import '../../core/utils/countdown_calculator.dart';
import '../../domain/models/countdown.dart';
import 'achievement_entry_repository.dart';
import '../local/app_database.dart';

class CountdownRepository {
  CountdownRepository(this._database, this._achievementEntryRepository);

  final AppDatabase _database;
  final AchievementEntryRepository _achievementEntryRepository;

  Future<List<Countdown>> fetchAll() async {
    final db = await _database.database;
    final rows = await db.query('countdowns');
    final countdowns = rows.map(Countdown.fromMap).toList();
    countdowns.sort((left, right) {
      if (left.isPinned != right.isPinned) {
        return left.isPinned ? -1 : 1;
      }

      final leftDays = CountdownCalculator.daysLeft(left.targetDate);
      final rightDays = CountdownCalculator.daysLeft(right.targetDate);
      return leftDays.compareTo(rightDays);
    });
    return countdowns;
  }

  Future<void> save(Countdown countdown) async {
    final db = await _database.database;
    await db.insert(
      'countdowns',
      countdown.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(String countdownId) async {
    final db = await _database.database;
    await db.delete('countdowns', where: 'id = ?', whereArgs: [countdownId]);
    await _achievementEntryRepository.deleteForCountdown(countdownId);
  }

  Future<void> deleteMany(Iterable<String> countdownIds) async {
    final ids = countdownIds.toList(growable: false);
    if (ids.isEmpty) {
      return;
    }

    final db = await _database.database;
    final placeholders = List.filled(ids.length, '?').join(', ');
    await db.delete(
      'countdowns',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
    for (final countdownId in ids) {
      await _achievementEntryRepository.deleteForCountdown(countdownId);
    }
  }
}
