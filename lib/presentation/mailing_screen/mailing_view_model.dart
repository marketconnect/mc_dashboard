import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';
import 'package:url_launcher/url_launcher.dart';

// mailing settings service
abstract class MailingSettingsMailingSettingsService {
  Future<Either<AppErrorBase, Map<String, dynamic>>> getSettings();
  Future<Either<AppErrorBase, void>> saveSettings(
      Map<String, dynamic> settings);
  Future<Either<AppErrorBase, void>> deleteSetting(String key);
}

// auth service
abstract class MailingAuthService {
  User? getFirebaseAuthUserInfo();
  Future<Either<AppErrorBase, Map<String, String?>>> getTokenAndType();
  String? getPaymentUrl();
  logout();
}

// user emails service
abstract class MailingUserEmailsService {
  Future<Either<AppErrorBase, void>> saveUserEmail(String userEmail);
  Future<Either<AppErrorBase, void>> deleteUserEmail(String email);
  Future<Either<AppErrorBase, List<String>>> getAllUserEmails();
}

class MailingSettingsViewModel extends ViewModelBase {
  MailingSettingsViewModel({
    required this.userEmailsService,
    required this.authService,
    required this.settingsService,
    required super.context,
  });

  final MailingUserEmailsService userEmailsService;
  final MailingAuthService authService;
  final MailingSettingsMailingSettingsService settingsService;

  // Fields ////////////////////////////////////////////////////////////////////
  bool _daily = false;
  bool _weekly = false;
  List<String> _emails = [];
  String? _errorMessage;
  Map<String, dynamic> _settings = {};

  Map<String, String?> _tokenInfo = {};
  bool get isSubscribed => _tokenInfo["type"] != "free";

  // Getters ///////////////////////////////////////////////////////////////////
  bool get daily => _daily;
  bool get weekly => _weekly;
  List<String> get emails => _emails;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic> get settings => _settings;

  // Methods ///////////////////////////////////////////////////////////////////
  @override
  Future<void> asyncInit() async {
    // Load user emails

    final values = await Future.wait(
        [authService.getTokenAndType(), userEmailsService.getAllUserEmails()]);

    final tokenInfoOrEither =
        values[0] as Either<AppErrorBase, Map<String, String?>>;
    if (tokenInfoOrEither.isRight()) {
      _tokenInfo = tokenInfoOrEither.fold((l) => {}, (r) => r);
    }
    final emailsOrEither = values[1] as Either<AppErrorBase, List<String>>;

    if (emailsOrEither.isRight()) {
      _emails =
          emailsOrEither.fold((l) => throw UnimplementedError(), (r) => r);
    }
    // If emails are empty, add the current user's email
    if (_emails.isEmpty) {
      final user = authService.getFirebaseAuthUserInfo();
      if (user != null) {
        _emails.add(user.email ?? '');
      }
    }

    // Load mailing settings
    final settingsOrEither = await settingsService.getSettings();
    if (settingsOrEither.isRight()) {
      _settings =
          settingsOrEither.fold((l) => throw UnimplementedError(), (r) => r);
      _daily = _settings['daily'] ?? false;
      _weekly = _settings['weekly'] ?? false;
    }

    notifyListeners();
  }

  void toggleDaily(bool value) async {
    _daily = value;
    await _updateSetting('daily', value);
    notifyListeners();
  }

  void toggleWeekly(bool value) async {
    _weekly = value;
    await _updateSetting('weekly', value);
    notifyListeners();
  }

  void addEmail(String email) async {
    if (!_isValidEmail(email)) {
      _errorMessage = "Неверный формат email";
      notifyListeners();
      return;
    }
    if (email.isNotEmpty && !_emails.contains(email)) {
      _emails.add(email);
      _errorMessage = null; // Сбрасываем ошибку
      notifyListeners();

      await userEmailsService.saveUserEmail(email);
    }
  }

  void removeEmail(String email) async {
    _emails.remove(email);
    notifyListeners();

    await userEmailsService.deleteUserEmail(email);
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return regex.hasMatch(email);
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    final updatedSettings = {..._settings, key: value};
    final saveOrError = await settingsService.saveSettings(updatedSettings);
    if (saveOrError.isRight()) {
      _settings[key] = value;
    }
  }

  void deleteSetting(String key) async {
    await settingsService.deleteSetting(key);
    _settings.remove(key);
    notifyListeners();
  }

  void onPaymentComplete() {
    final paymentUrl = authService.getPaymentUrl();
    if (paymentUrl != null) {
      launchUrl(Uri.parse(paymentUrl));
      authService.logout();
    }
  }
}
