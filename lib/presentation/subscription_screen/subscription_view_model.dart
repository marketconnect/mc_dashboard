import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';
import 'package:mc_dashboard/domain/entities/token_info.dart';

// auth service
abstract class SubscriptionAuthService {
  Future<Either<AppErrorBase, TokenInfo>> getTokenInfo();

  logout();
}

class SubscriptionViewModel extends ViewModelBase {
  SubscriptionViewModel({required super.context, required this.authService});

  final SubscriptionAuthService authService;

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
}
