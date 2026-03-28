import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/notification_service.dart';
import '../../core/services/widget_sync_service.dart';
import '../../data/local/app_database.dart';
import '../../data/repositories/achievement_entry_repository.dart';
import '../../data/repositories/countdown_repository.dart';
import '../../data/repositories/theme_preferences_repository.dart';
import 'reminder_orchestrator.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError();
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final countdownRepositoryProvider = Provider<CountdownRepository>((ref) {
  throw UnimplementedError();
});

final achievementEntryRepositoryProvider =
    Provider<AchievementEntryRepository>((
  ref,
) {
  throw UnimplementedError();
});

final themePreferencesRepositoryProvider =
    Provider<ThemePreferencesRepository>((
  ref,
) {
  throw UnimplementedError();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  throw UnimplementedError();
});

final widgetSyncServiceProvider = Provider<WidgetSyncService>((ref) {
  throw UnimplementedError();
});

final reminderOrchestratorProvider = Provider<ReminderOrchestrator>((ref) {
  throw UnimplementedError();
});
