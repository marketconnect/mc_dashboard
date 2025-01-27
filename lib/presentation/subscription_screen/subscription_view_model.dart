import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/.env.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';
import 'package:mc_dashboard/core/utils/dates.dart';
import 'package:mc_dashboard/domain/entities/token_info.dart';
import 'package:url_launcher/url_launcher.dart';

// auth service
abstract class SubscriptionAuthService {
  Future<Either<AppErrorBase, TokenInfo>> getTokenInfo();
  User? getFirebaseAuthUserInfo();
  logout();
}

abstract class SubscriptionTinkoffPaymentService {
  Future<String?> processPayment(int amount, DateTime endDate, String email);
}

class SubscriptionViewModel extends ViewModelBase {
  SubscriptionViewModel(
      {required super.context,
      required this.authService,
      required this.tinkoffPaymentService});

  final SubscriptionAuthService authService;
  final SubscriptionTinkoffPaymentService tinkoffPaymentService;
  // Fields
  TokenInfo? _tokenInfo;
  bool get isSubscribed => _tokenInfo != null && _tokenInfo!.type != "free";

  String get subsEndDate => _tokenInfo?.endDate ?? "";

  @override
  Future<void> asyncInit() async {
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
  }

  void subscribe() async {
    // email
    final user = authService.getFirebaseAuthUserInfo();
    if (user == null || user.email == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('User is not logged in'),
        ));
      }
      return;
    }

    // subsEndDate
    DateTime endDate = DateTime.now().add(const Duration(days: 30));
    final startDate = parseDateYYYYMMDD(_tokenInfo!.endDate);
    // if start date is after today then add to end date difference between today and start date
    if (isSubscribed && startDate.isAfter(DateTime.now())) {
      endDate = endDate
          .add(Duration(days: startDate.difference(DateTime.now()).inDays));
    }

    final paymentUrl = await tinkoffPaymentService.processPayment(
        PaymentSettings.amount, endDate, user.email!);
    if (paymentUrl == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error processing payment'),
        ));
      }
      return;
    }
    if (context.mounted) {
      await launchUrl(Uri.parse(paymentUrl));
      authService.logout();
    }
  }
}
