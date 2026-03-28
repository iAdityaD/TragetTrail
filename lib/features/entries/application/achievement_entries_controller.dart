import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/models/achievement_entry.dart';
import '../../shared/providers.dart';

final achievementEntriesControllerProvider = AsyncNotifierProvider.family<
    AchievementEntriesController, List<AchievementEntry>, String>(
  AchievementEntriesController.new,
);

class AchievementEntriesController
    extends FamilyAsyncNotifier<List<AchievementEntry>, String> {
  static const _uuid = Uuid();

  @override
  Future<List<AchievementEntry>> build(String arg) async {
    return ref.read(achievementEntryRepositoryProvider).fetchByCountdown(arg);
  }

  Future<void> create({
    required String countdownId,
    required DateTime entryDate,
    required String content,
  }) async {
    final now = DateTime.now();
    final entry = AchievementEntry(
      id: _uuid.v4(),
      countdownId: countdownId,
      entryDate: DateTime(entryDate.year, entryDate.month, entryDate.day),
      content: content.trim(),
      createdAt: now,
      updatedAt: now,
    );
    await ref.read(achievementEntryRepositoryProvider).save(entry);
    state = AsyncData(
      await ref.read(achievementEntryRepositoryProvider).fetchByCountdown(arg),
    );
  }

  Future<void> updateEntry(AchievementEntry entry) async {
    await ref.read(achievementEntryRepositoryProvider).save(
          entry.copyWith(
            entryDate: DateTime(
              entry.entryDate.year,
              entry.entryDate.month,
              entry.entryDate.day,
            ),
            updatedAt: DateTime.now(),
          ),
        );
    state = AsyncData(
      await ref.read(achievementEntryRepositoryProvider).fetchByCountdown(arg),
    );
  }

  Future<void> deleteEntry(String entryId) async {
    await ref.read(achievementEntryRepositoryProvider).delete(entryId);
    state = AsyncData(
      await ref.read(achievementEntryRepositoryProvider).fetchByCountdown(arg),
    );
  }
}
