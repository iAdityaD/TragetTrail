import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/home/presentation/home_screen.dart';
import '../features/theme/application/theme_mode_controller.dart';
import 'theme.dart';

class CountdownApp extends ConsumerWidget {
  const CountdownApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencesAsync = ref.watch(appPreferencesControllerProvider);
    final preferences = preferencesAsync.valueOrNull;
    final themeMode = preferences?.themeMode ?? ThemeMode.system;
    final accentColor = preferences?.accentColor ?? const Color(0xFFEF4444);

    return MaterialApp(
      title: 'TargetTrail',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(Brightness.light, seedColor: accentColor),
      darkTheme: buildAppTheme(Brightness.dark, seedColor: accentColor),
      themeMode: themeMode,
      home: const HomeScreen(),
    );
  }
}
