import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/app_settings_model.dart';
import '../../data/repositories/settings_repository.dart';

part 'settings_providers.g.dart';

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(SettingsRepositoryRef ref) {
  return SettingsRepository();
}

@riverpod
class SettingsController extends _$SettingsController {
  @override
  FutureOr<AppSettingsModel> build() async {
    return ref.read(settingsRepositoryProvider).getSettings();
  }

  Future<void> updateSettings(AppSettingsModel newSettings) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(settingsRepositoryProvider).saveSettings(newSettings);
      return newSettings;
    });
  }
}
