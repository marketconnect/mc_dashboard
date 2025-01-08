import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';
import 'package:mc_dashboard/domain/entities/token_info.dart';
import 'package:mc_dashboard/routes/main_navigation_route_names.dart';

// mailing settings service
abstract class MailingSettingsMailingSettingsService {
  Future<Either<AppErrorBase, Map<String, dynamic>>> getSettings({
    required String token,
  });
  Future<Either<AppErrorBase, void>> syncSettings({
    required String token,
    required Map<String, dynamic> newSettings,
  });
}

// auth service
abstract class MailingAuthService {
  User? getFirebaseAuthUserInfo();
  Future<Either<AppErrorBase, TokenInfo>> getTokenInfo();

  logout();
}

// user emails service
abstract class MailingUserEmailsService {
  Future<Either<AppErrorBase, void>> syncUserEmails({
    required String token,
    required List<String> newEmails,
  });
  Future<Either<AppErrorBase, List<String>>> getAllUserEmails(
      {required String token});
}

class MailingSettingsViewModel extends ViewModelBase {
  MailingSettingsViewModel({
    required this.userEmailsService,
    required this.authService,
    required this.settingsService,
    required this.onNavigateTo,
    required super.context,
  });

  final MailingUserEmailsService userEmailsService;
  final MailingAuthService authService;
  final MailingSettingsMailingSettingsService settingsService;
  // Navigation
  final void Function({
    required String routeName,
    Map<String, dynamic>? params,
  }) onNavigateTo;
  // Fields ////////////////////////////////////////////////////////////////////
  bool _daily = false;
  bool _weekly = false;
  List<String> _emails = [];
  String? _errorMessage;
  Map<String, dynamic> _settings = {};

  TokenInfo? _tokenInfo;
  bool get isSubscribed => _tokenInfo != null && _tokenInfo!.type != "free";

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

    // Token
    final tokenInfoOrEither = await authService.getTokenInfo();
    if (tokenInfoOrEither.isLeft()) {
      // Token error
      final error =
          tokenInfoOrEither.fold((l) => l, (r) => throw UnimplementedError());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error.message ?? 'Unknown error'),
        ));
      }
      return;
    }

    _tokenInfo =
        tokenInfoOrEither.fold((l) => throw UnimplementedError(), (r) => r);
    if (_tokenInfo == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('User is not logged in'),
        ));
      }
      return;
    }

    // Load user emails
    if (isSubscribed) {
      final emailsOrEither = await userEmailsService.getAllUserEmails(
        token: _tokenInfo!.token,
      );

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
      if (_tokenInfo == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('User is not logged in'),
        ));
        return;
      }
      final settingsOrEither = await settingsService.getSettings(
        token: _tokenInfo!.token,
      );
      if (settingsOrEither.isRight()) {
        _settings =
            settingsOrEither.fold((l) => throw UnimplementedError(), (r) => r);
        _daily = (_settings['daily'] is bool)
            ? _settings['daily'] as bool
            : _settings['daily'].toString().toLowerCase() == 'true';

        _weekly = (_settings['weekly'] is bool)
            ? _settings['weekly'] as bool
            : _settings['weekly'].toString().toLowerCase() == 'true';
      }
    }

    notifyListeners();
  } // asyncInit

  void toggleDaily(bool value) {
    _daily = value;
    notifyListeners();
  }

  void toggleWeekly(bool value) {
    _weekly = value;
    notifyListeners();
  }

  void addEmail(String email) {
    if (!_isValidEmail(email)) {
      _errorMessage = "Неверный формат email";
      notifyListeners();
      return;
    }
    if (!_emails.contains(email)) {
      _emails.add(email);
      _errorMessage = null;
      notifyListeners();
    }
  }

  void removeEmail(String email) {
    _emails.remove(email);
    notifyListeners();
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return regex.hasMatch(email);
  }

  // void deleteSetting(String key) async {
  //   await settingsService.deleteSetting(key);
  //   _settings.remove(key);
  //   notifyListeners();
  // }

  Future<void> onSave() async {
    if (_tokenInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('User is not logged in'),
      ));
      return;
    }

    final token = _tokenInfo!.token;

    // Sync settings
    final settings = <String, dynamic>{};

    settings['daily'] = _daily;

    settings['weekly'] = _weekly;

    await settingsService.syncSettings(
      token: token,
      newSettings: settings,
    );

    // Sync emails
    await userEmailsService.syncUserEmails(
      token: token,
      newEmails: _emails,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Настройки успешно сохранены')),
      );
    }
  }

  // navigation

  void onNavigateToSubscriptionScreen() {
    onNavigateTo(routeName: MainNavigationRouteNames.subscriptionScreen);
  }
}
