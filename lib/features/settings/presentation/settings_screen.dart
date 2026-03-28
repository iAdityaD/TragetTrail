import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/app_preferences.dart';
import '../../theme/application/theme_mode_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences =
        ref.watch(appPreferencesControllerProvider).valueOrNull ??
            const AppPreferences(
              themeMode: ThemeMode.system,
              accentColorValue: 0xFFEF4444,
              swipeActionsEnabled: true,
            );

    return Scaffold(
      appBar: AppBar(title: const Text('Customization')),
      body: _SettingsBody(preferences: preferences),
    );
  }
}

class _SettingsBody extends ConsumerStatefulWidget {
  const _SettingsBody({
    required this.preferences,
  });

  final AppPreferences preferences;

  @override
  ConsumerState<_SettingsBody> createState() => _SettingsBodyState();
}

class _SettingsBodyState extends ConsumerState<_SettingsBody> {
  static const _accentColors = [
    Color(0xFFEF4444),
    Color(0xFF0F766E),
    Color(0xFF2563EB),
    Color(0xFF7C3AED),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
  ];

  late ThemeMode _themeMode;
  late int _accentColorValue;
  late bool _swipeActionsEnabled;
  var _isSaving = false;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.preferences.themeMode;
    _accentColorValue = widget.preferences.accentColorValue;
    _swipeActionsEnabled = widget.preferences.swipeActionsEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appearance',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text('System'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text('Light'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text('Dark'),
                    ),
                  ],
                  selected: {_themeMode},
                  onSelectionChanged: (value) {
                    setState(() {
                      _themeMode = value.first;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App color',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final color in _accentColors)
                      _AccentColorChip(
                        color: color,
                        selected: _accentColorValue == color.value,
                        onTap: () {
                          setState(() {
                            _accentColorValue = color.value;
                          });
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: SwitchListTile.adaptive(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            value: _swipeActionsEnabled,
            onChanged: (value) {
              setState(() {
                _swipeActionsEnabled = value;
              });
            },
            title: const Text('Swipe actions'),
            subtitle: const Text(
              'Swipe countdown cards to quickly edit or delete them.',
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Reminders are configured per target. On Android, each home-screen widget can be configured separately so multiple widgets can show different targets.',
            ),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: Text(_isSaving ? 'Saving...' : 'Save settings'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await ref.read(appPreferencesControllerProvider.notifier).save(
          AppPreferences(
            themeMode: _themeMode,
            accentColorValue: _accentColorValue,
            swipeActionsEnabled: _swipeActionsEnabled,
          ),
        );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });
    Navigator.of(context).pop();
  }
}

class _AccentColorChip extends StatelessWidget {
  const _AccentColorChip({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.onSurface
                : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.34),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: selected
            ? const Icon(Icons.check_rounded, color: Colors.white)
            : null,
      ),
    );
  }
}
