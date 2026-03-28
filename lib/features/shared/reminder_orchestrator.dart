import '../../core/services/notification_service.dart';
import '../../core/services/widget_sync_service.dart';
import '../../data/repositories/countdown_repository.dart';

class ReminderOrchestrator {
  ReminderOrchestrator({
    required CountdownRepository countdownRepository,
    required NotificationService notificationService,
    required WidgetSyncService widgetSyncService,
  })  : _countdownRepository = countdownRepository,
        _notificationService = notificationService,
        _widgetSyncService = widgetSyncService;

  final CountdownRepository _countdownRepository;
  final NotificationService _notificationService;
  final WidgetSyncService _widgetSyncService;

  Future<void> sync() async {
    final countdowns = await _countdownRepository.fetchAll();
    await _notificationService.syncDailySummary(countdowns: countdowns);
    await _widgetSyncService.sync(countdowns);
  }
}
