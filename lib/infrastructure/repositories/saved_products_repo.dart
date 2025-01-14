import 'package:hive/hive.dart';
import 'package:mc_dashboard/domain/entities/saved_product.dart';
import 'package:mc_dashboard/domain/services/saved_products_service.dart';

class SavedProductsRepo implements SavedProductsRepository {
  @override
  Future<void> saveProduct(SavedProduct product) async {
    final box = await Hive.openBox<SavedProduct>('savedProducts');
    await box.put(product.productId, product);
  }

  @override
  Future<List<SavedProduct>> loadProducts() async {
    final box = await Hive.openBox<SavedProduct>('savedProducts');
    return box.values.toList();
  }

  @override
  Future<void> deleteProduct(int productId) async {
    final box = await Hive.openBox<SavedProduct>('savedProducts');

    if (box.containsKey(productId)) {
      await box.delete(productId);
    }
  }
}
