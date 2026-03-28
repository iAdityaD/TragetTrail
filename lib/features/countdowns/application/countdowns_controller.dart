import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/models/countdown.dart';
import '../../shared/providers.dart';

final countdownsControllerProvider =
    AsyncNotifierProvider<CountdownsController, List<Countdown>>(
  CountdownsController.new,
);

class CountdownsController extends AsyncNotifier<List<Countdown>> {
  static const _uuid = Uuid();

  @override
  Future<List<Countdown>> build() async {
    return ref.read(countdownRepositoryProvider).fetchAll();
  }

  Future<void> create({
    required String title,
    required DateTime targetDate,
    required bool reminderEnabled,
    required int reminderHour,
    required int reminderMinute,
    String? note,
    bool isPinned = false,
  }) async {
    if (reminderEnabled) {
      await ref.read(notificationServiceProvider).requestPermissions();
    }

    final now = DateTime.now();
    final countdown = Countdown(
      id: _uuid.v4(),
      title: title.trim(),
      targetDate: targetDate,
      createdAt: now,
      updatedAt: now,
      reminderEnabled: reminderEnabled,
      reminderHour: reminderHour,
      reminderMinute: reminderMinute,
      note: note?.trim().isEmpty ?? true ? null : note?.trim(),
      isPinned: isPinned,
    );

    await ref.read(countdownRepositoryProvider).save(countdown);
    await _refreshState();
  }

  Future<void> updateCountdown(Countdown countdown) async {
    if (countdown.reminderEnabled) {
      await ref.read(notificationServiceProvider).requestPermissions();
    }

    await ref.read(countdownRepositoryProvider).save(
          countdown.copyWith(updatedAt: DateTime.now()),
        );
    await _refreshState();
  }

  Future<void> delete(String countdownId) async {
    await ref.read(countdownRepositoryProvider).delete(countdownId);
    await _refreshState();
  }

  Future<void> deleteMany(Iterable<String> countdownIds) async {
    final ids = countdownIds.toList(growable: false);
    if (ids.isEmpty) {
      return;
    }

    await ref.read(countdownRepositoryProvider).deleteMany(ids);
    await _refreshState();
  }

  Future<void> togglePinned(Countdown countdown) async {
    await updateCountdown(
      countdown.copyWith(
        isPinned: !countdown.isPinned,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> _refreshState() async {
    state = AsyncData(await ref.read(countdownRepositoryProvider).fetchAll());
    unawaited(
      ref.read(reminderOrchestratorProvider).sync().catchError((_) {
        // Best-effort sync; saving local state should not block the UI.
      }),
    );
  }
}

final countdownByIdProvider = Provider.family<Countdown?, String>((ref, id) {
  final countdowns = ref.watch(countdownsControllerProvider).valueOrNull ?? [];
  for (final countdown in countdowns) {
    if (countdown.id == id) {
      return countdown;
    }
  }
  return null;
});
