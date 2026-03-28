import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/achievement_entry.dart';
import '../application/achievement_entries_controller.dart';

class AchievementEntryFormScreen extends ConsumerStatefulWidget {
  const AchievementEntryFormScreen({
    super.key,
    required this.countdownId,
    this.existing,
  });

  final String countdownId;
  final AchievementEntry? existing;

  @override
  ConsumerState<AchievementEntryFormScreen> createState() =>
      _AchievementEntryFormScreenState();
}

class _AchievementEntryFormScreenState
    extends ConsumerState<AchievementEntryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _contentController;
  late DateTime _entryDate;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(
      text: widget.existing?.content ?? '',
    );
    _entryDate = widget.existing?.entryDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit milestone' : 'Add milestone'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                title: const Text('Entry date'),
                subtitle: Text(DateFormat.yMMMMEEEEd().format(_entryDate)),
                trailing: const Icon(Icons.event_note_outlined),
                onTap: _pickDate,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _contentController,
              maxLines: 6,
              minLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Achievement',
                hintText: 'What progress did you make today?',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Achievement details are required';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: Text(_isEditing ? 'Save milestone' : 'Add milestone'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _entryDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) {
      return;
    }

    setState(() {
      _entryDate = picked;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final controller = ref.read(
      achievementEntriesControllerProvider(widget.countdownId).notifier,
    );

    if (_isEditing) {
      await controller.updateEntry(
        widget.existing!.copyWith(
          entryDate: _entryDate,
          content: _contentController.text.trim(),
        ),
      );
    } else {
      await controller.create(
        countdownId: widget.countdownId,
        entryDate: _entryDate,
        content: _contentController.text.trim(),
      );
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
