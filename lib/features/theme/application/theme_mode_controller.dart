import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/app_preferences.dart';
import '../../shared/providers.dart';

final appPreferencesControllerProvider =
    AsyncNotifierProvider<AppPreferencesController, AppPreferences>(
  AppPreferencesController.new,
);

final themeModeControllerProvider = Provider((ref) {
  return ref.watch(appPreferencesControllerProvider).valueOrNull?.themeMode;
});

final swipeActionsEnabledProvider = Provider((ref) {
  return ref
          .watch(appPreferencesControllerProvider)
          .valueOrNull
          ?.swipeActionsEnabled ??
      true;
});

class AppPreferencesController extends AsyncNotifier<AppPreferences> {
  @override
  Future<AppPreferences> build() async {
    return ref.read(themePreferencesRepositoryProvider).load();
  }

  Future<void> save(AppPreferences preferences) async {
    await ref.read(themePreferencesRepositoryProvider).save(preferences);
    state = AsyncData(preferences);
  }
}
