import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../utils/countdown_calculator.dart';
import '../../domain/models/countdown.dart';

class NotificationService {
  static const _channelId = 'daily_countdown_channel';
  static const _channelName = 'Daily countdown reminders';
  static const _channelDescription = 'Daily summaries for active countdowns';
  static const _managedNotificationBaseId = 9000;
  static const _rollingWindowDays = 30;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  Future<void>? _initialization;

  Future<void> initialize() async {
    final existing = _initialization;
    if (existing != null) {
      return existing;
    }

    _initialization = _initializeInternal();
    return _initialization!;
  }

  Future<void> _initializeInternal() async {
    tz_data.initializeTimeZones();
    final timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      ),
    );

    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.defaultImportance,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  Future<void> requestPermissions() async {
    await initialize();
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> syncDailySummary({
    required List<Countdown> countdowns,
  }) async {
    await initialize();
    await _cancelManagedNotifications();

    final now = DateTime.now();
    final reminderCountdowns = countdowns.where((item) => item.reminderEnabled);

    var nextId = _managedNotificationBaseId;
    for (final countdown in reminderCountdowns) {
      for (var offset = 0; offset < _rollingWindowDays; offset++) {
        final notificationDate = DateTime(
          now.year,
          now.month,
          now.day + offset,
          countdown.reminderHour,
          countdown.reminderMinute,
        );

        if (!notificationDate.isAfter(now)) {
          continue;
        }

        final content = _contentFor(
          countdown: countdown,
          relativeTo: notificationDate,
        );
        if (content == null) {
          continue;
        }

        await _plugin.zonedSchedule(
          nextId,
          content.title,
          content.body,
          tz.TZDateTime.from(notificationDate, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              _channelId,
              _channelName,
              channelDescription: _channelDescription,
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
            ),
            iOS: DarwinNotificationDetails(
              interruptionLevel: InterruptionLevel.passive,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        nextId++;
      }
    }
  }

  Future<void> _cancelManagedNotifications() async {
    for (var index = 0; index < 10000; index++) {
      await _plugin.cancel(_managedNotificationBaseId + index);
    }
  }

  _NotificationContent? _contentFor({
    required Countdown countdown,
    required DateTime relativeTo,
  }) {
    final daysLeft = CountdownCalculator.daysLeft(
      countdown.targetDate,
      relativeTo: relativeTo,
    );
    if (daysLeft < 0) {
      return null;
    }

    final title = switch (daysLeft) {
      0 => '${countdown.title} is today',
      1 => '${countdown.title} is tomorrow',
      _ => '${countdown.title} in $daysLeft days',
    };

    final body = switch (daysLeft) {
      0 => 'Today is the day for ${countdown.title}.',
      1 => 'Final 24 hours left. Keep the momentum going.',
      _ => '$daysLeft days remain until ${countdown.title}.',
    };

    return _NotificationContent(title: title, body: body);
  }
}

class _NotificationContent {
  const _NotificationContent({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}
