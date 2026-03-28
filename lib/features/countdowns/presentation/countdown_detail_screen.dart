import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/island_notice.dart';
import '../../../core/utils/countdown_calculator.dart';
import '../../../domain/models/achievement_entry.dart';
import '../application/countdowns_controller.dart';
import '../../entries/application/achievement_entries_controller.dart';
import '../../entries/presentation/achievement_entry_form_screen.dart';
import 'countdown_form_screen.dart';

class CountdownDetailScreen extends ConsumerWidget {
  const CountdownDetailScreen({
    super.key,
    required this.countdownId,
  });

  final String countdownId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countdown = ref.watch(countdownByIdProvider(countdownId));
    final entriesAsync = ref.watch(
      achievementEntriesControllerProvider(countdownId),
    );

    if (countdown == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Countdown')),
        body: const Center(
          child: Text('This countdown no longer exists.'),
        ),
      );
    }

    final daysLeft = CountdownCalculator.daysLeft(countdown.targetDate);
    final label = switch (daysLeft) {
      < 0 => 'Passed ${daysLeft.abs()} days ago',
      0 => 'Happening today',
      1 => '1 day left',
      _ => '$daysLeft days left',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(countdown.title),
        actions: [
          IconButton(
            onPressed: () async {
              final message = await Navigator.of(context).push<String>(
                MaterialPageRoute<String>(
                  builder: (_) => CountdownFormScreen(existing: countdown),
                ),
              );
              if (context.mounted && message != null) {
                showIslandNotice(context, message);
              }
            },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => AchievementEntryFormScreen(
              countdownId: countdownId,
            ),
          ),
        ),
        label: const Text('Add milestone'),
        icon: const Icon(Icons.flag_outlined),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          _HeaderCard(
            title: countdown.title,
            dateLabel: DateFormat.yMMMMEEEEd().format(countdown.targetDate),
            statusLabel: label,
            reminderEnabled: countdown.reminderEnabled,
            reminderHour: countdown.reminderHour,
            reminderMinute: countdown.reminderMinute,
            note: countdown.note,
          ),
          const SizedBox(height: 16),
          Text(
            'Progress timeline',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          entriesAsync.when(
            data: (entries) => _EntryList(
              countdownId: countdownId,
              entries: entries,
            ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text('Failed to load milestones.\n$error'),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.title,
    required this.dateLabel,
    required this.statusLabel,
    required this.reminderEnabled,
    required this.reminderHour,
    required this.reminderMinute,
    required this.note,
  });

  final String title;
  final String dateLabel;
  final String statusLabel;
  final bool reminderEnabled;
  final int reminderHour;
  final int reminderMinute;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFFB91C1C), Color(0xFF7F1D1D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              statusLabel,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              dateLabel,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 12),
            _ReminderBadge(
              reminderEnabled: reminderEnabled,
              reminderHour: reminderHour,
              reminderMinute: reminderMinute,
            ),
            if (note?.isNotEmpty ?? false) ...[
              const SizedBox(height: 16),
              Text(
                note!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReminderBadge extends StatelessWidget {
  const _ReminderBadge({
    required this.reminderEnabled,
    required this.reminderHour,
    required this.reminderMinute,
  });

  final bool reminderEnabled;
  final int reminderHour;
  final int reminderMinute;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.14),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            reminderEnabled
                ? 'Reminder ${TimeOfDay(hour: reminderHour, minute: reminderMinute).format(context)}'
                : 'Reminder off',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
      ],
    );
  }
}

class _EntryList extends ConsumerWidget {
  const _EntryList({
    required this.countdownId,
    required this.entries,
  });

  final String countdownId;
  final List<AchievementEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (entries.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'No milestones recorded yet. Add one to build a day-by-day trail toward your target.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final entry in entries) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          DateFormat.yMMMMEEEEd().format(entry.entryDate),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            await Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => AchievementEntryFormScreen(
                                  countdownId: countdownId,
                                  existing: entry,
                                ),
                              ),
                            );
                            return;
                          }

                          if (value == 'delete') {
                            await ref
                                .read(
                                  achievementEntriesControllerProvider(
                                    countdownId,
                                  ).notifier,
                                )
                                .deleteEntry(entry.id);
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(entry.content),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
