import '../models/app_settings_model.dart';
import '../datasources/hive_database.dart';

class SettingsRepository {
  Future<AppSettingsModel> getSettings() async {
    return HiveDatabase.settings.get('settings') ?? AppSettingsModel();
  }

  Future<void> saveSettings(AppSettingsModel settings) async {
    await HiveDatabase.settings.put('settings', settings);
  }
}
