import 'package:flutter/material.dart';

class AppPreferences {
  const AppPreferences({
    required this.themeMode,
    required this.accentColorValue,
    required this.swipeActionsEnabled,
  });

  final ThemeMode themeMode;
  final int accentColorValue;
  final bool swipeActionsEnabled;

  Color get accentColor => Color(accentColorValue);

  AppPreferences copyWith({
    ThemeMode? themeMode,
    int? accentColorValue,
    bool? swipeActionsEnabled,
  }) {
    return AppPreferences(
      themeMode: themeMode ?? this.themeMode,
      accentColorValue: accentColorValue ?? this.accentColorValue,
      swipeActionsEnabled: swipeActionsEnabled ?? this.swipeActionsEnabled,
    );
  }
}
