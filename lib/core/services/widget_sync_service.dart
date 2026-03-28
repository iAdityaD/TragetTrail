import 'dart:convert';
import 'dart:io';

import 'package:home_widget/home_widget.dart';

import '../constants/widget_constants.dart';
import '../utils/countdown_calculator.dart';
import '../../domain/models/countdown.dart';

class WidgetSyncService {
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
    if (Platform.isIOS) {
      try {
        await HomeWidget.setAppGroupId(WidgetConstants.iosAppGroupId);
      } catch (_) {
        // The iOS WidgetKit target is configured during release setup.
      }
    }
  }

  Future<void> sync(List<Countdown> countdowns) async {
    await initialize();
    final featured = CountdownCalculator.featuredCountdown(countdowns);
    final title = featured?.title ?? 'No active countdown';
    final days = featured == null
        ? '--'
        : CountdownCalculator.daysLeft(featured.targetDate).toString();
    final subtitle = featured == null
        ? 'Create a countdown to see it here'
        : _subtitleFor(featured);

    await HomeWidget.saveWidgetData<String>(WidgetConstants.titleKey, title);
    await HomeWidget.saveWidgetData<String>(WidgetConstants.daysKey, days);
    await HomeWidget.saveWidgetData<String>(
      WidgetConstants.subtitleKey,
      subtitle,
    );
    await HomeWidget.saveWidgetData<String>(
      WidgetConstants.countdownsJsonKey,
      jsonEncode(
        countdowns.map((countdown) {
          return {
            'id': countdown.id,
            'title': countdown.title,
            'days': CountdownCalculator.daysLeft(countdown.targetDate),
            'subtitle': _subtitleFor(countdown),
          };
        }).toList(),
      ),
    );

    try {
      await HomeWidget.updateWidget(
        name: WidgetConstants.androidProviderName,
        iOSName: WidgetConstants.iosWidgetName,
        qualifiedAndroidName: WidgetConstants.androidQualifiedName,
      );
    } catch (_) {
      // Widget syncing is best-effort when the native extension is unavailable.
    }
  }

  String _subtitleFor(Countdown countdown) {
    final daysLeft = CountdownCalculator.daysLeft(countdown.targetDate);
    if (daysLeft < 0) {
      return 'Passed ${daysLeft.abs()} days ago';
    }
    if (daysLeft == 0) {
      return 'Happening today';
    }
    if (daysLeft == 1) {
      return '1 day left';
    }
    return '$daysLeft days left';
  }
}
