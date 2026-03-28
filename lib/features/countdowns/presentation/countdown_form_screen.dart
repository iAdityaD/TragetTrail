import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/countdown.dart';
import '../application/countdowns_controller.dart';

class CountdownFormScreen extends ConsumerStatefulWidget {
  const CountdownFormScreen({
    super.key,
    this.existing,
  });

  final Countdown? existing;

  @override
  ConsumerState<CountdownFormScreen> createState() =>
      _CountdownFormScreenState();
}

class _CountdownFormScreenState extends ConsumerState<CountdownFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  late DateTime _selectedDate;
  late bool _isPinned;
  late bool _reminderEnabled;
  late TimeOfDay _reminderTime;
  var _isSaving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.existing?.title ?? '');
    _noteController = TextEditingController(text: widget.existing?.note ?? '');
    _selectedDate = widget.existing?.targetDate ?? DateTime.now();
    _isPinned = widget.existing?.isPinned ?? false;
    _reminderEnabled = widget.existing?.reminderEnabled ?? false;
    _reminderTime = TimeOfDay(
      hour: widget.existing?.reminderHour ?? 9,
      minute: widget.existing?.reminderMinute ?? 0,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit countdown' : 'New countdown'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Exam, launch, vacation, goal',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Overview',
                  hintText: 'Optional summary of the target or why it matters',
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  title: const Text('Target date'),
                  subtitle: Text(DateFormat.yMMMMEEEEd().format(_selectedDate)),
                  trailing: const Icon(Icons.calendar_month_outlined),
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile.adaptive(
                value: _isPinned,
                onChanged: (value) => setState(() => _isPinned = value),
                title: const Text('Pin as featured'),
                subtitle: const Text(
                  'Pinned countdowns are prioritized for the home screen and widget.',
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    SwitchListTile.adaptive(
                      value: _reminderEnabled,
                      onChanged: (value) =>
                          setState(() => _reminderEnabled = value),
                      title: const Text('Daily reminder'),
                      subtitle: const Text(
                        'Schedule a reminder specifically for this target.',
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      enabled: _reminderEnabled,
                      title: const Text('Reminder time'),
                      subtitle: Text(_reminderTime.format(context)),
                      trailing: const Icon(Icons.alarm_outlined),
                      onTap: _reminderEnabled ? _pickReminderTime : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                child: Text(
                  _isSaving
                      ? (_isEditing ? 'Saving...' : 'Creating...')
                      : (_isEditing ? 'Save changes' : 'Create countdown'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _selectedDate = picked;
    });
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _reminderTime = picked;
    });
  }

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final controller = ref.read(countdownsControllerProvider.notifier);
      if (_isEditing) {
        final existing = widget.existing!;
        await controller.updateCountdown(
          existing.copyWith(
            title: _titleController.text.trim(),
            targetDate: _selectedDate,
            note: _noteController.text.trim(),
            clearNote: _noteController.text.trim().isEmpty,
            isPinned: _isPinned,
            reminderEnabled: _reminderEnabled,
            reminderHour: _reminderTime.hour,
            reminderMinute: _reminderTime.minute,
          ),
        );
      } else {
        await controller.create(
          title: _titleController.text,
          targetDate: _selectedDate,
          reminderEnabled: _reminderEnabled,
          reminderHour: _reminderTime.hour,
          reminderMinute: _reminderTime.minute,
          note: _noteController.text,
          isPinned: _isPinned,
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
      rethrow;
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(
      _isEditing ? 'Countdown updated' : 'Countdown created',
    );
  }
}
