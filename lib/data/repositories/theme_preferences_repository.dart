import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/app_preferences.dart';

class ThemePreferencesRepository {
  ThemePreferencesRepository(this._preferences);

  static const _themeModeKey = 'theme_mode';
  static const _accentColorKey = 'accent_color_value';
  static const _swipeActionsEnabledKey = 'swipe_actions_enabled';
  static const _defaultAccentColorValue = 0xFFEF4444;

  final SharedPreferences _preferences;

  Future<AppPreferences> load() async {
    final rawValue = _preferences.getString(_themeModeKey);
    final themeMode = switch (rawValue) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    final accentColorValue =
        _preferences.getInt(_accentColorKey) ?? _defaultAccentColorValue;
    final swipeActionsEnabled =
        _preferences.getBool(_swipeActionsEnabledKey) ?? true;

    return AppPreferences(
      themeMode: themeMode,
      accentColorValue: accentColorValue,
      swipeActionsEnabled: swipeActionsEnabled,
    );
  }

  Future<void> save(AppPreferences preferences) async {
    final rawValue = switch (preferences.themeMode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _preferences.setString(_themeModeKey, rawValue);
    await _preferences.setInt(_accentColorKey, preferences.accentColorValue);
    await _preferences.setBool(
      _swipeActionsEnabledKey,
      preferences.swipeActionsEnabled,
    );
  }
}
