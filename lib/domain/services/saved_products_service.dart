import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/domain/entities/saved_product.dart';
import 'package:mc_dashboard/presentation/mailing_screen/saved_products_view_model.dart';
import 'package:mc_dashboard/presentation/subject_products_screen/subject_products_view_model.dart';

abstract class SavedProductsRepository {
  Future<void> saveProduct(SavedProduct products);
  Future<List<SavedProduct>> loadProducts();
  Future<void> deleteProduct(int productId);
}

class SavedProductsService
    implements
        SubjectProductsSavedProductsService,
        SavedProductsSavedProductsService {
  SavedProductsService({
    required this.savedProductsRepo,
  });

  final SavedProductsRepository savedProductsRepo;

  @override
  Future<Either<AppErrorBase, void>> saveProducts(
      List<SavedProduct> products) async {
    try {
      // TODO: send to server

      for (var product in products) {
        await savedProductsRepo.saveProduct(product);
      }
    } catch (e) {
      return left(AppErrorBase(
        'Caught error: $e',
        name: 'saveProducts',
        sendTo: true,
        source: 'SavedProductsService',
        stackTrace: e.toString(),
      ));
    }
    return right(null);
  }

  @override
  Future<Either<AppErrorBase, List<SavedProduct>>> loadProducts() async {
    try {
      // TODO: send to server

      final products = await savedProductsRepo.loadProducts();

      return right(products);
    } catch (e) {
      return left(AppErrorBase(
        'Caught error: $e',
        name: 'loadProducts',
        sendTo: true,
        source: 'SavedProductsService',
        stackTrace: e.toString(),
      ));
    }
  }

  @override
  Future<Either<AppErrorBase, void>> deleteProduct(
    int productId,
  ) async {
    try {
      // TODO: send to server

      await savedProductsRepo.deleteProduct(productId);
    } catch (e) {
      return left(AppErrorBase(
        'Caught error: $e',
        name: 'deleteProduct',
        sendTo: true,
        source: 'SavedProductsService',
        stackTrace: e.toString(),
      ));
    }
    return right(null);
  }
}
