import 'package:hive/hive.dart';
import 'package:mc_dashboard/domain/entities/mailing_settings.dart';
import 'package:mc_dashboard/domain/services/user_sub_settings_service.dart';

class MailingSettingsRepo implements UserSubSettingsRepoRepository {
  @override
  Future<void> saveSettings(Map<String, dynamic> newSettings) async {
    final box = await Hive.openBox<DynamicMailingSettings>('mailingSettings');
    final existingSettings = box.get('userSettings')?.settings ?? {};
    final updatedSettings = {...existingSettings, ...newSettings};
    await box.put(
        'userSettings', DynamicMailingSettings(settings: updatedSettings));
  }

  @override
  Future<Map<String, dynamic>> getSettings() async {
    final box = await Hive.openBox<DynamicMailingSettings>('mailingSettings');
    return box.get('userSettings')?.settings ?? {};
  }

  @override
  Future<void> deleteSetting(String key) async {
    final box = await Hive.openBox<DynamicMailingSettings>('mailingSettings');
    final currentSettings = box.get('userSettings');

    if (currentSettings != null && currentSettings.settings.containsKey(key)) {
      final updatedSettings = {...currentSettings.settings};
      updatedSettings.remove(key);

      await box.put(
          'userSettings', DynamicMailingSettings(settings: updatedSettings));
    }
  }
}
