import '../../domain/models/countdown.dart';

class CountdownCalculator {
  static int daysLeft(
    DateTime targetDate, {
    DateTime? relativeTo,
  }) {
    final start = _atMidnight(relativeTo ?? DateTime.now());
    final end = _atMidnight(targetDate);
    return end.difference(start).inDays;
  }

  static Countdown? featuredCountdown(
    Iterable<Countdown> countdowns, {
    DateTime? relativeTo,
  }) {
    final reference = relativeTo ?? DateTime.now();
    final sorted = [...countdowns]..sort(
        (left, right) {
          if (left.isPinned != right.isPinned) {
            return left.isPinned ? -1 : 1;
          }

          final leftDays = daysLeft(left.targetDate, relativeTo: reference);
          final rightDays = daysLeft(right.targetDate, relativeTo: reference);
          return leftDays.compareTo(rightDays);
        },
      );

    for (final countdown in sorted) {
      if (daysLeft(countdown.targetDate, relativeTo: reference) >= 0) {
        return countdown;
      }
    }

    return sorted.isEmpty ? null : sorted.first;
  }

  static DateTime _atMidnight(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
