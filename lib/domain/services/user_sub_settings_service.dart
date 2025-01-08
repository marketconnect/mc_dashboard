import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/api/user_settings_api.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';

import 'package:mc_dashboard/presentation/mailing_screen/mailing_view_model.dart';

abstract class UserSubSettingsRepoRepository {
  Future<void> saveSettings(Map<String, dynamic> newSettings);
  Future<Map<String, dynamic>> getSettings();
  Future<void> deleteSetting(String key);
}

abstract class UserSubSettingsApiClient {
  Future<UserSettingsResponse> findUserSettings({
    required String token,
  });
  Future<void> saveUserSettings({
    required String token,
    required SaveSettingsRequest request,
  });
  Future<void> deleteUserSettings({
    required String token,
    required DeleteSettingsRequest request,
  });
}

class UserSubSettingsService implements MailingSettingsMailingSettingsService {
  UserSubSettingsService({
    required this.mailingSettingsRepo,
    required this.userSettingsApiClient,
  });

  final UserSubSettingsRepoRepository mailingSettingsRepo;
  final UserSubSettingsApiClient userSettingsApiClient;

  @override
  Future<Either<AppErrorBase, void>> syncSettings({
    required String token,
    required Map<String, dynamic> newSettings,
  }) async {
    try {
      // Получение текущих настроек из локального хранилища
      final currentSettings = await mailingSettingsRepo.getSettings();

      // Найти добавленные или обновленные настройки
      final addedOrUpdatedSettings = newSettings.entries
          .where((entry) =>
              !currentSettings.containsKey(entry.key) ||
              currentSettings[entry.key] != entry.value)
          .toList();

      // Найти удаленные настройки
      final removedSettings = currentSettings.keys
          .where((key) => !newSettings.containsKey(key))
          .toList();

      // Сохранение добавленных или обновленных настроек
      if (addedOrUpdatedSettings.isNotEmpty) {
        final saveResult = await _saveSettings(
          token: token,
          settings: Map.fromEntries(addedOrUpdatedSettings),
        );
        if (saveResult.isLeft()) {
          return saveResult;
        }
      }

      // Удаление настроек
      if (removedSettings.isNotEmpty) {
        final deleteResult = await _deleteSettings(
          token: token,
          keys: removedSettings,
        );
        if (deleteResult.isLeft()) {
          return deleteResult;
        }
      }

      return right(null);
    } catch (e) {
      return left(AppErrorBase(
        'Caught error: $e',
        name: 'syncSettings',
        sendTo: true,
        source: 'MailingSettingsService',
        stackTrace: e.toString(),
      ));
    }
  }

  Future<Either<AppErrorBase, void>> _saveSettings({
    required String token,
    required Map<String, dynamic> settings,
  }) async {
    try {
      // Преобразование в формат API
      final settingsJson = settings.entries
          .map((e) => Setting(key: e.key, value: e.value.toString()))
          .toList();

      // Сохранение на сервере
      await userSettingsApiClient.saveUserSettings(
        token: token,
        request: SaveSettingsRequest(settings: settingsJson),
      );

      // Сохранение локально
      await mailingSettingsRepo.saveSettings(settings);
    } catch (e) {
      return left(AppErrorBase(
        'Caught error: $e',
        name: '_saveSettings',
        sendTo: true,
        source: 'MailingSettingsService',
      ));
    }
    return right(null);
  }

  Future<Either<AppErrorBase, void>> _deleteSettings({
    required String token,
    required List<String> keys,
  }) async {
    try {
      // Преобразование в формат API
      final settingsJson =
          keys.map((key) => Setting(key: key, value: '')).toList();

      // Удаление на сервере
      await userSettingsApiClient.deleteUserSettings(
        token: token,
        request: DeleteSettingsRequest(settings: settingsJson),
      );

      // Удаление локально
      for (final key in keys) {
        await mailingSettingsRepo.deleteSetting(key);
      }
    } catch (e) {
      return left(AppErrorBase(
        'Caught error: $e',
        name: '_deleteSettings',
        sendTo: true,
        source: 'MailingSettingsService',
      ));
    }
    return right(null);
  }

  @override
  Future<Either<AppErrorBase, Map<String, dynamic>>> getSettings({
    required String token,
  }) async {
    try {
      // Получение настроек с сервера
      final serverSettingsResponse =
          await userSettingsApiClient.findUserSettings(token: token);
      final serverSettings = {
        for (var setting in serverSettingsResponse.settings)
          setting.key: setting.value,
      };

      // Получение локальных настроек
      final localSettings = await mailingSettingsRepo.getSettings();

      bool localStorageUpdated = false;

      // Синхронизация добавленных или измененных настроек
      for (final entry in serverSettings.entries) {
        if (!localSettings.containsKey(entry.key) ||
            localSettings[entry.key] != entry.value) {
          await mailingSettingsRepo.saveSettings({entry.key: entry.value});
          localStorageUpdated = true;
        }
      }

      // Удаление локальных настроек, отсутствующих на сервере
      for (final key in localSettings.keys) {
        if (!serverSettings.containsKey(key)) {
          await mailingSettingsRepo.deleteSetting(key);
          localStorageUpdated = true;
        }
      }

      // Получение актуализированных настроек
      final updatedSettings = localStorageUpdated
          ? await mailingSettingsRepo.getSettings()
          : localSettings;

      return right(updatedSettings);
    } catch (e) {
      return left(AppErrorBase(
        'Caught error: $e',
        name: 'getSettings',
        sendTo: true,
        source: 'MailingSettingsService',
        stackTrace: e.toString(),
      ));
    }
  }

  @override
  Future<Either<AppErrorBase, void>> saveSettings({
    required String token,
    required Map<String, dynamic> settings,
  }) async {
    return _saveSettings(token: token, settings: settings);
  }

  @override
  Future<Either<AppErrorBase, void>> deleteSetting(String key) async {
    return left(AppErrorBase(
      'deleteSetting requires a token. Use _deleteSettings instead.',
      name: 'deleteSetting',
      sendTo: false,
    ));
  }
}
