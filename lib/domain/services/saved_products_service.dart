import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/domain/entities/saved_product.dart';
import 'package:mc_dashboard/presentation/saved_products_screen/saved_products_view_model.dart';
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
  Future<Either<AppError, void>> saveProducts(
      List<SavedProduct> products) async {
    try {
      for (var product in products) {
        await savedProductsRepo.saveProduct(product);
      }
    } catch (e) {
      return left(AppError());
    }
    return right(null);
  }

  @override
  Future<Either<AppError, List<SavedProduct>>> loadProducts() async {
    try {
      final products = await savedProductsRepo.loadProducts();

      return right(products);
    } catch (e) {
      return left(AppError());
    }
  }

  @override
  Future<Either<AppError, void>> deleteProduct(int productId) async {
    try {
      await savedProductsRepo.deleteProduct(productId);
    } catch (e) {
      return left(AppError());
    }
    return right(null);
  }
}

class AppError {}
