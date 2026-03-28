import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/countdown_calculator.dart';
import '../../../core/widgets/island_notice.dart';
import '../../../domain/models/countdown.dart';
import '../../calendar/presentation/calendar_screen.dart';
import '../../countdowns/application/countdowns_controller.dart';
import '../../countdowns/presentation/countdown_detail_screen.dart';
import '../../countdowns/presentation/countdown_form_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../theme/application/theme_mode_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final Set<String> _selectedCountdownIds = <String>{};

  bool get _selectionMode => _selectedCountdownIds.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final countdownsAsync = ref.watch(countdownsControllerProvider);
    final swipeActionsEnabled = ref.watch(swipeActionsEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        leading: _selectionMode
            ? IconButton(
                onPressed: _clearSelection,
                icon: const Icon(Icons.close_rounded),
              )
            : null,
        title: Text(_selectionMode
            ? '${_selectedCountdownIds.length} selected'
            : 'TargetTrail'),
        actions: _selectionMode
            ? [
                IconButton(
                  onPressed: _deleteSelected,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ]
            : [
                IconButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const CalendarScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.calendar_month_outlined),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SettingsScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.tune_rounded),
                ),
              ],
      ),
      floatingActionButton: _selectionMode
          ? null
          : FloatingActionButton.extended(
              onPressed: _openCreate,
              label: const Text('Add countdown'),
              icon: const Icon(Icons.add),
            ),
      body: countdownsAsync.when(
        data: (countdowns) => _HomeBody(
          countdowns: countdowns,
          swipeActionsEnabled: swipeActionsEnabled,
          selectedIds: _selectedCountdownIds,
          onCreatePressed: _openCreate,
          onOpenCountdown: _openCountdown,
          onEditCountdown: _openEdit,
          onDeleteCountdown: _deleteCountdown,
          onToggleSelection: _toggleSelection,
          onStartSelection: _startSelection,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Failed to load countdowns.\n$error'),
          ),
        ),
      ),
    );
  }

  Future<void> _openCreate() async {
    final message = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => const CountdownFormScreen(),
      ),
    );

    if (!mounted || message == null) {
      return;
    }

    showIslandNotice(context, message);
  }

  Future<void> _openCountdown(Countdown countdown) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CountdownDetailScreen(countdownId: countdown.id),
      ),
    );
  }

  Future<void> _openEdit(Countdown countdown) async {
    final message = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => CountdownFormScreen(existing: countdown),
      ),
    );

    if (!mounted || message == null) {
      return;
    }

    showIslandNotice(context, message);
  }

  Future<void> _deleteCountdown(Countdown countdown) async {
    await ref.read(countdownsControllerProvider.notifier).delete(countdown.id);
    if (!mounted) {
      return;
    }
    showIslandNotice(context, 'Countdown deleted');
  }

  Future<void> _deleteSelected() async {
    final ids = _selectedCountdownIds.toList(growable: false);
    if (ids.isEmpty) {
      return;
    }

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              ids.length == 1 ? 'Delete countdown?' : 'Delete countdowns?',
            ),
            content: Text(
              ids.length == 1
                  ? 'This countdown and its milestones will be removed.'
                  : '${ids.length} countdowns and their milestones will be removed.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) {
      return;
    }

    await ref.read(countdownsControllerProvider.notifier).deleteMany(ids);

    if (!mounted) {
      return;
    }

    setState(_selectedCountdownIds.clear);
    showIslandNotice(
      context,
      ids.length == 1
          ? 'Countdown deleted'
          : '${ids.length} countdowns deleted',
    );
  }

  void _toggleSelection(String countdownId) {
    setState(() {
      if (_selectedCountdownIds.contains(countdownId)) {
        _selectedCountdownIds.remove(countdownId);
      } else {
        _selectedCountdownIds.add(countdownId);
      }
    });
  }

  void _startSelection(String countdownId) {
    if (_selectionMode) {
      _toggleSelection(countdownId);
      return;
    }

    setState(() {
      _selectedCountdownIds.add(countdownId);
    });
  }

  void _clearSelection() {
    setState(_selectedCountdownIds.clear);
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({
    required this.countdowns,
    required this.swipeActionsEnabled,
    required this.selectedIds,
    required this.onCreatePressed,
    required this.onOpenCountdown,
    required this.onEditCountdown,
    required this.onDeleteCountdown,
    required this.onToggleSelection,
    required this.onStartSelection,
  });

  final List<Countdown> countdowns;
  final bool swipeActionsEnabled;
  final Set<String> selectedIds;
  final VoidCallback onCreatePressed;
  final Future<void> Function(Countdown countdown) onOpenCountdown;
  final Future<void> Function(Countdown countdown) onEditCountdown;
  final Future<void> Function(Countdown countdown) onDeleteCountdown;
  final ValueChanged<String> onToggleSelection;
  final ValueChanged<String> onStartSelection;

  @override
  Widget build(BuildContext context) {
    if (countdowns.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Track meaningful targets and log daily wins offline.',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Add your first target to start reminders, milestone tracking, and widget updates.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: onCreatePressed,
                    icon: const Icon(Icons.add),
                    label: const Text('Create first countdown'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final featured = CountdownCalculator.featuredCountdown(countdowns);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        if (selectedIds.isEmpty && featured != null) ...[
          _FeaturedCard(countdown: featured),
          const SizedBox(height: 16),
        ],
        if (selectedIds.isNotEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Tap countdowns to select multiple items, then delete them together from the top bar.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        for (final countdown in countdowns) ...[
          _CountdownTile(
            countdown: countdown,
            swipeActionsEnabled: swipeActionsEnabled && selectedIds.isEmpty,
            selected: selectedIds.contains(countdown.id),
            selectionMode: selectedIds.isNotEmpty,
            onOpen: () => onOpenCountdown(countdown),
            onEdit: () => onEditCountdown(countdown),
            onDelete: () => onDeleteCountdown(countdown),
            onToggleSelection: () => onToggleSelection(countdown.id),
            onStartSelection: () => onStartSelection(countdown.id),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.countdown,
  });

  final Countdown countdown;

  @override
  Widget build(BuildContext context) {
    final daysLeft = CountdownCalculator.daysLeft(countdown.targetDate);
    final label = switch (daysLeft) {
      < 0 => 'Passed ${daysLeft.abs()} days ago',
      0 => 'Today',
      1 => 'Tomorrow',
      _ => '$daysLeft days left',
    };

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF164E63)],
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
              'Primary target',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              countdown.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat.yMMMMd().format(countdown.targetDate),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountdownTile extends ConsumerWidget {
  const _CountdownTile({
    required this.countdown,
    required this.swipeActionsEnabled,
    required this.selected,
    required this.selectionMode,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleSelection,
    required this.onStartSelection,
  });

  final Countdown countdown;
  final bool swipeActionsEnabled;
  final bool selected;
  final bool selectionMode;
  final Future<void> Function() onOpen;
  final Future<void> Function() onEdit;
  final Future<void> Function() onDelete;
  final VoidCallback onToggleSelection;
  final VoidCallback onStartSelection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daysLeft = CountdownCalculator.daysLeft(countdown.targetDate);
    final theme = Theme.of(context);

    Widget tile = Card(
      color: selected ? theme.colorScheme.primaryContainer : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: selectionMode ? onToggleSelection : onOpen,
        onLongPress: onStartSelection,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: selected
                      ? theme.colorScheme.primary.withOpacity(0.16)
                      : theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(22),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      daysLeft.toString(),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'days',
                      style: theme.textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            countdown.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (selectionMode)
                          Icon(
                            selected
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: selected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline,
                          )
                        else
                          IconButton(
                            onPressed: () => ref
                                .read(countdownsControllerProvider.notifier)
                                .togglePinned(countdown),
                            icon: Icon(
                              countdown.isPinned
                                  ? Icons.push_pin
                                  : Icons.push_pin_outlined,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(DateFormat.yMMMMd().format(countdown.targetDate)),
                    if (countdown.note?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 8),
                      Text(
                        countdown.note!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!selectionMode)
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'open') {
                      await onOpen();
                      return;
                    }
                    if (value == 'edit') {
                      await onEdit();
                      return;
                    }
                    if (value == 'delete') {
                      await onDelete();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'open', child: Text('Open')),
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
            ],
          ),
        ),
      ),
    );

    if (!swipeActionsEnabled) {
      return tile;
    }

    return Dismissible(
      key: ValueKey('countdown-${countdown.id}'),
      background: _SwipeActionBackground(
        alignment: Alignment.centerLeft,
        color: theme.colorScheme.primary,
        icon: Icons.edit_outlined,
        label: 'Edit',
      ),
      secondaryBackground: _SwipeActionBackground(
        alignment: Alignment.centerRight,
        color: theme.colorScheme.error,
        icon: Icons.delete_outline_rounded,
        label: 'Delete',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await onEdit();
          return false;
        }

        final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete countdown?'),
                content: const Text(
                  'This countdown and its milestones will be removed.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ) ??
            false;

        if (!confirmed) {
          return false;
        }

        await onDelete();
        return true;
      },
      child: tile,
    );
  }
}

class _SwipeActionBackground extends StatelessWidget {
  const _SwipeActionBackground({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.label,
  });

  final Alignment alignment;
  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: alignment,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: alignment == Alignment.centerLeft
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
