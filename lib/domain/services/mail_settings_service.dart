import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';

import 'package:mc_dashboard/presentation/mailing_screen/mailing_view_model.dart';

abstract class MailingSettingsRepoRepository {
  Future<void> saveSettings(Map<String, dynamic> newSettings);
  Future<Map<String, dynamic>> getSettings();
  Future<void> deleteSetting(String key);
}

class MailingSettingsService implements MailingSettingsMailingSettingsService {
  final MailingSettingsRepoRepository mailingSettingsRepo;

  MailingSettingsService({
    required this.mailingSettingsRepo,
  });

  @override
  Future<Either<AppErrorBase, void>> saveSettings(
    Map<String, dynamic> newSettings,
  ) async {
    try {
      // TODO: send to server

      await mailingSettingsRepo.saveSettings(newSettings);
    } catch (e) {
      return left(AppErrorBase(
        'Caught error: $e',
        name: 'saveSettings',
        sendTo: true,
        source: 'MailingSettingsService',
        stackTrace: e.toString(),
      ));
    }
    return right(null);
  }

  @override
  Future<Either<AppErrorBase, Map<String, dynamic>>> getSettings() async {
    try {
      final settings = await mailingSettingsRepo.getSettings();
      return right(settings);
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
  Future<Either<AppErrorBase, void>> deleteSetting(
    String key,
  ) async {
    try {
      await mailingSettingsRepo.deleteSetting(key);
    } catch (e) {
      return left(AppErrorBase(
        'Caught error: $e',
        name: 'deleteSetting',
        sendTo: true,
        source: 'MailingSettingsService',
        stackTrace: e.toString(),
      ));
    }
    return right(null);
  }
}
