import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/core/utils/basket_num.dart';
import 'package:mc_dashboard/domain/entities/card_info.dart';
import 'package:mc_dashboard/domain/entities/saved_product.dart';
import 'package:mc_dashboard/domain/entities/sku.dart';
import 'package:mc_dashboard/domain/entities/supplier_item.dart';
import 'package:mc_dashboard/infrastructure/api/suppliers_api_client.dart';
import 'package:mc_dashboard/presentation/mailing_screen/saved_products_view_model.dart';
import 'package:mc_dashboard/presentation/subject_products_screen/subject_products_view_model.dart';

abstract class SavedProductsRepository {
  Future<void> saveProduct(SavedProduct products);
  Future<List<SavedProduct>> loadProducts();
  Future<void> deleteProduct(String productId);
}

abstract class SavedProductsApiClient {
  Future<List<Sku>> findUserSkus({
    required String token,
  });
  Future<void> saveUserSkus({
    required String token,
    required List<Sku> skus,
  });
  Future<void> deleteUserSkus({
    required String token,
    required List<Sku> skus,
  });
}

class SavedProductsService
    implements
        SubjectProductsSavedProductsService,
        SavedProductsSavedProductsService {
  SavedProductsService({
    required this.savedProductsRepo,
    required this.savedProductsApiClient,
    required this.suppliersApiClient,
  });

  final SavedProductsRepository savedProductsRepo;
  final SavedProductsApiClient savedProductsApiClient;
  final SuppliersApiClient suppliersApiClient;

  /// Синхронизация сохранённых товаров
  @override
  Future<Either<AppErrorBase, void>> syncSavedProducts({
    required String token,
    required List<SavedProduct> products,
  }) async {
    try {
      // get local saved products
      final currentProducts = await savedProductsRepo.loadProducts();
      final currentSkus =
          currentProducts.map((product) => product.productId).toList();

      // get products to add
      final addedSkus = products
          .where((sku) => !currentSkus.contains(sku.productId))
          .toList();

      // get products to delete
      final removedSkus = currentSkus
          .where((skuId) => !products.any((sku) => sku.productId == skuId))
          .toList();

      // Save new
      if (addedSkus.isNotEmpty) {
        final saveResult =
            await _saveUserProducts(token: token, products: addedSkus);
        if (saveResult.isLeft()) {
          return saveResult;
        }
      }

      // Delete missing
      if (removedSkus.isNotEmpty) {
        final productsToRemove = currentProducts
            .where((product) => removedSkus.contains(product.productId))
            .toList();
        final deleteResult = await _deleteUserSkus(
            token: token,
            skus: productsToRemove
                .map((product) => Sku(
                    id: product.productId,
                    marketplaceType: product.marketplaceType))
                .toList());
        if (deleteResult.isLeft()) {
          return deleteResult;
        }
      }

      return right(null);
    } catch (e) {
      return left(AppErrorBase(
        'Caught error: $e',
        name: 'syncSavedProducts',
        sendTo: true,
        source: 'SavedProductsService',
      ));
    }
  }

  @override
  Future<Either<AppErrorBase, void>> addProducts({
    required String token,
    required List<SavedProduct> products,
  }) async {
    // Save on server
    try {
      final skus = products.map((product) => Sku(
            id: product.productId.toString(),
            marketplaceType: product.marketplaceType,
          ));
      await savedProductsApiClient.saveUserSkus(
        token: token,
        skus: skus.toList(),
      );
      // get local saved products
      final currentProducts = await savedProductsRepo.loadProducts();
      final currentSkus =
          currentProducts.map((product) => product.productId).toList();

      // get products to add
      final addedSkus = products
          .where((sku) => !currentSkus.contains(sku.productId))
          .toList();

      // Save new
      if (addedSkus.isNotEmpty) {
        final saveResult =
            await _saveUserProducts(token: token, products: addedSkus);
        if (saveResult.isLeft()) {
          return saveResult;
        }
      }
    } catch (e) {
      return left(AppErrorBase(
        'Caught error: $e',
        name: 'addProducts',
        sendTo: true,
        source: 'SavedProductsService',
      ));
    }
    return right(null);
  }

  Future<Either<AppErrorBase, void>> _saveUserProducts({
    required String token,
    required List<SavedProduct> products,
  }) async {
    try {
      // Save on server
      final skus = products.map((product) => Sku(
            id: product.productId.toString(),
            marketplaceType: product.marketplaceType,
          ));
      await savedProductsApiClient.saveUserSkus(
        token: token,
        skus: skus.toList(),
      );

      // Save on local
      for (final sku in products) {
        await savedProductsRepo.saveProduct(sku);
      }
    } catch (e) {
      return left(AppErrorBase(
        'Caught error: $e',
        name: '_saveUserSkus',
        sendTo: true,
        source: 'SavedProductsService',
      ));
    }
    return right(null);
  }

  Future<Either<AppErrorBase, void>> _deleteUserSkus({
    required String token,
    required List<Sku> skus,
  }) async {
    try {
      // Delete on server
      final skusToDelete = skus
          .map((sku) => Sku(id: sku.id, marketplaceType: sku.marketplaceType))
          .toList();

      await savedProductsApiClient.deleteUserSkus(
        token: token,
        skus: skusToDelete,
      );

      // Delete on local
      for (final sku in skus) {
        await savedProductsRepo.deleteProduct(sku.id);
      }
    } catch (e) {
      return left(AppErrorBase(
        'Caught error: $e',
        name: '_deleteUserSkus',
        sendTo: true,
        source: 'SavedProductsService',
      ));
    }
    return right(null);
  }

  @override
  Future<Either<AppErrorBase, List<SavedProduct>>> getAllSavedProducts({
    required String token,
  }) async {
    try {
      // Get from server
      final serverSkus =
          await savedProductsApiClient.findUserSkus(token: token);

      // Get from local
      final localProducts = await savedProductsRepo.loadProducts();
      final localSkuIds =
          localProducts.map((product) => product.productId).toList();

      // Add new products to local
      // get suppliers info
      List<int> suppliersIds = [];
      Map<int, CardInfo> cardInfoMap = {};
      Map<int, String> imageUrlMap = {};
      Map<int, String> marketplaceTypesMap = {};
      bool localStorageUpdated = false;
      // Get missing products and fetch card info for them
      for (final sku in serverSkus) {
        if (!localSkuIds.contains(sku.id)) {
          marketplaceTypesMap[int.parse(sku.id)] = sku.marketplaceType;
          final id = int.tryParse(sku.id);
          if (id == null) {
            continue;
          }
          final basketNum = getBasketNum(id);
          final imageUrl = calculateImageUrl(basketNum, id);

          imageUrlMap[id] = imageUrl;
          final cardUrl = calculateCardUrl(imageUrl);
          final cardInfo = await fetchCardInfo(cardUrl);
          suppliersIds.add(cardInfo.supplierId);

          cardInfoMap[id] = cardInfo;
          localStorageUpdated = true;
        }
      }
      // Get suppliers for missing products
      Map<int, SupplierItem> suppliersMap = {};

      final supplierOrEither = await getSuppliers(supplierIds: suppliersIds);
      if (supplierOrEither.isRight()) {
        final suppliers =
            supplierOrEither.fold((l) => throw UnimplementedError(), (r) => r);
        for (final supplierItem in suppliers) {
          suppliersMap[supplierItem.id] = supplierItem;
        }
      }

      // Add new products to local
      for (final card in cardInfoMap.entries) {
        final product = SavedProduct(
          productId: card.key.toString(),
          name: card.value.imtName,
          imageUrl: imageUrlMap[card.key] ?? '',
          sellerId: card.value.supplierId,
          sellerName: suppliersMap[card.value.supplierId]?.name ?? '',
          brandId: 0,
          brandName: '',
          marketplaceType: marketplaceTypesMap[card.key] ?? "wb",
        );
        await savedProductsRepo.saveProduct(product);
      }

      // Delete deleted products
      for (final product in localProducts) {
        if (!serverSkus.any((sku) => sku.id == product.productId.toString())) {
          await savedProductsRepo.deleteProduct(product.productId.toString());
          localStorageUpdated = true;
        }
      }

      // Обновление локальных данных, если были изменения
      final updatedProducts = localStorageUpdated
          ? await savedProductsRepo.loadProducts()
          : localProducts;

      return right(updatedProducts);
    } catch (e) {
      return left(AppErrorBase(
        'Caught error: $e',
        name: 'getAllSavedProducts',
        sendTo: true,
        source: 'SavedProductsService',
      ));
    }
  }

  Future<Either<AppErrorBase, List<SupplierItem>>> getSuppliers({
    required List<int> supplierIds,
  }) async {
    try {
      final response = await suppliersApiClient.getSuppliers(
        supplierIds: supplierIds.join(','),
      );
      return Right(response);
    } catch (e, stackTrace) {
      final error = AppErrorBase(
        'Unexpected error: $e',
        name: 'getSuppliers',
        sendTo: true,
        source: 'SuppliersService',
        args: [
          'supplierIds: $supplierIds',
        ],
        stackTrace: stackTrace.toString(),
      );
      AppLogger.log(error);
      return Left(error);
    }
  }
}
