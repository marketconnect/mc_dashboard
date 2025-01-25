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
  // Periodic
  bool _daily = true;
  bool _weekly = false;

  // Options
  // Анализ позиций
  bool productPosition = true;
  // Уведомления о ценах
  bool productPrice = true;
  // Тренды
  bool newSearchQueries = true;
  // Акции
  bool productPromotions = true;
  // Изменения карточек
  bool productCardChanges = true;
  // Изменение ассортимента
  bool assortmentChanges = true;

  // Emails
  List<String> _emails = [];

  // Error
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
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('User is not logged in'),
          ));
        }
        return;
      }
      final settingsOrEither = await settingsService.getSettings(
        token: _tokenInfo!.token,
      );
      if (settingsOrEither.isRight()) {
        _settings =
            settingsOrEither.fold((l) => throw UnimplementedError(), (r) => r);
        // daily
        _daily = (_settings['daily'] is bool)
            ? _settings['daily'] as bool
            : _settings['daily'].toString().toLowerCase() == 'true';

        // weekly
        _weekly = (_settings['weekly'] is bool)
            ? _settings['weekly'] as bool
            : _settings['weekly'].toString().toLowerCase() == 'true';

        // options
        // productPosition
        productPosition = (_settings['productPosition'] is bool)
            ? _settings['productPosition'] as bool
            : _settings['productPosition'].toString().toLowerCase() == 'true';

        // newSearchQueries
        newSearchQueries = (_settings['newSearchQueries'] is bool)
            ? _settings['newSearchQueries'] as bool
            : _settings['newSearchQueries'].toString().toLowerCase() == 'true';

        // assortmentChanges
        assortmentChanges = (_settings['assortmentChanges'] is bool)
            ? _settings['assortmentChanges'] as bool
            : _settings['assortmentChanges'].toString().toLowerCase() == 'true';

        // productPromotions
        productPromotions = (_settings['productPromotions'] is bool)
            ? _settings['productPromotions'] as bool
            : _settings['productPromotions'].toString().toLowerCase() == 'true';

        // productPrice
        productPrice = (_settings['productPrice'] is bool)
            ? _settings['productPrice'] as bool
            : _settings['productPrice'].toString().toLowerCase() == 'true';

        // productCardChanges
        productCardChanges = (_settings['productCardChanges'] is bool)
            ? _settings['productCardChanges'] as bool
            : _settings['productCardChanges'].toString().toLowerCase() ==
                'true';
      }
    }

    notifyListeners();
  } // asyncInit

  // Toggle
  void toggleDaily(bool value) {
    _daily = value;
    notifyListeners();
  }

  void toggleWeekly(bool value) {
    _weekly = value;
    notifyListeners();
  }

  void toggleProductPosition(bool value) {
    productPosition = value;
    notifyListeners();
  }

  void toggleNewSearchQueries(bool value) {
    newSearchQueries = value;
    notifyListeners();
  }

  void toggleAssortmentChanges(bool value) {
    assortmentChanges = value;
    notifyListeners();
  }

  void togglePriceChanges(bool value) {
    productPrice = value;
    notifyListeners();
  }

  void toggleProductPromotions(bool value) {
    productPromotions = value;
    notifyListeners();
  }

  void toggleProductCardChanges(bool value) {
    productCardChanges = value;
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

  Future<void> onSave() async {
    if (_tokenInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('User is not logged in'),
      ));
      return;
    }
    if (_tokenInfo!.type == "free") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Пожалуйста, оформите подписку'),
      ));
      return;
    }

    final token = _tokenInfo!.token;

    // Sync settings
    final settings = <String, dynamic>{};

    settings['daily'] = _daily;
    settings['weekly'] = _weekly;
    settings['productPosition'] = productPosition;
    settings['newSearchQueries'] = newSearchQueries;
    settings['productPromotions'] = productPromotions;
    settings['productPrice'] = productPrice;
    settings['productCardChanges'] = productCardChanges;
    settings['assortmentChanges'] = assortmentChanges;

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
        const SnackBar(
            content: Text('Настройки успешно сохранены',
                style: TextStyle(fontSize: 16))),
      );
    }
  }

  // navigation

  void onNavigateToSubscriptionScreen() {
    onNavigateTo(routeName: MainNavigationRouteNames.subscriptionScreen);
  }

  void onNavigateToProductScreen(int productId, int productPrice) {
    onNavigateTo(
        routeName: MainNavigationRouteNames.productScreen,
        params: {"productId": productId, "productPrice": productPrice});
  }
}
