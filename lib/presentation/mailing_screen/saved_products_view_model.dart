import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';

import 'package:mc_dashboard/domain/entities/saved_product.dart';
import 'package:mc_dashboard/domain/entities/token_info.dart';

abstract class SavedProductsSavedProductsService {
  Future<Either<AppErrorBase, List<SavedProduct>>> getAllSavedProducts({
    required String token,
  });
  Future<Either<AppErrorBase, void>> syncSavedProducts({
    required String token,
    required List<SavedProduct> products,
  });
}

// auth service
abstract class SavedProductsAuthService {
  Future<Either<AppErrorBase, TokenInfo>> getTokenInfo();
}

class SavedProductsViewModel extends ViewModelBase {
  SavedProductsViewModel(
      {required super.context,
      required this.savedProductsService,
      required this.authService});

  final SavedProductsSavedProductsService savedProductsService;
  final SavedProductsAuthService authService;
  // Fields
  final double tableRowHeight = 60.0;
  List<String> selectedRows = [];
  final List<SavedProduct> _savedProducts = [];

  List<SavedProduct> get savedProducts => _savedProducts;
  TokenInfo? tokenInfo;
  // Methods
  @override
  Future<void> asyncInit() async {
    //Token
    final tokenInfoOrEither = await authService.getTokenInfo();
    if (tokenInfoOrEither.isLeft()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Не удалось получить токен"),
          ),
        );
      }
      return;
    }

    tokenInfo =
        tokenInfoOrEither.fold((l) => throw UnimplementedError(), (r) => r);
    if (tokenInfo == null || tokenInfo!.type == "free") {
      return;
    }
    final savedProductsOrEither =
        await savedProductsService.getAllSavedProducts(token: tokenInfo!.token);

    if (savedProductsOrEither.isRight()) {
      final fetchedProducts = savedProductsOrEither.fold(
          (l) => throw UnimplementedError(), (r) => r);

      _savedProducts.addAll(fetchedProducts);
    }
    notifyListeners();
  }

  void addSkuToSaved(String sku) {
    print("Adding $sku to saved");
  }

  void removeProductsFromSaved(List<String> productIds, bool isSubscribed) {
    if (!isSubscribed) {
      return;
    }
    if (productIds.isEmpty) {
      return;
    }

    if (tokenInfo == null || tokenInfo!.type == "free") {
      return;
    }
    _savedProducts
        .removeWhere((product) => productIds.contains(product.productId));

    savedProductsService.syncSavedProducts(
        token: tokenInfo!.token, products: _savedProducts.toList());

    notifyListeners();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Удалено ${productIds.length} товаров"),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void selectRow(String productId) {
    if (selectedRows.contains(productId)) {
      selectedRows.remove(productId);
    } else {
      selectedRows.add(productId);
    }
    notifyListeners();
  }
}
