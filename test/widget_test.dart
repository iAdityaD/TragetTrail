import 'package:countdown_reminder/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app theme uses Material 3', () {
    expect(
      buildAppTheme(
        Brightness.light,
        seedColor: const Color(0xFFEF4444),
      ).useMaterial3,
      isTrue,
    );
  });
}
