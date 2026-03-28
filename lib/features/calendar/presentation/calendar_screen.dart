import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../domain/models/countdown.dart';
import '../../countdowns/application/countdowns_controller.dart';
import '../../countdowns/presentation/countdown_detail_screen.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final countdowns =
        ref.watch(countdownsControllerProvider).valueOrNull ?? [];
    final selectedDay = _selectedDay ?? _focusedDay;
    final selectedItems = _eventsForDay(countdowns, selectedDay);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: TableCalendar<Countdown>(
                firstDay: DateTime.utc(2000, 1, 1),
                lastDay: DateTime.utc(2100, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: (day) => _eventsForDay(countdowns, day),
                startingDayOfWeek: StartingDayOfWeek.monday,
                onFormatChanged: (format) {
                  if (_calendarFormat == format) {
                    return;
                  }
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            DateFormat.yMMMMEEEEd().format(selectedDay),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (selectedItems.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No targets on this day.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          for (final countdown in selectedItems) ...[
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(countdown.title),
                subtitle: Text(
                  countdown.note?.isNotEmpty == true
                      ? countdown.note!
                      : 'Target day',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        CountdownDetailScreen(countdownId: countdown.id),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  List<Countdown> _eventsForDay(List<Countdown> countdowns, DateTime day) {
    return countdowns.where((countdown) {
      final date = countdown.targetDate;
      return date.year == day.year &&
          date.month == day.month &&
          date.day == day.day;
    }).toList();
  }
}
