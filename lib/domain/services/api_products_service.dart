import 'package:mc_dashboard/domain/entities/product_item.dart';
import 'package:mc_dashboard/presentation/product_detail_screen/product_detail_view_model.dart';

abstract class ProductServiceProductsApiClient {
  Future<List<ProductItem>> getProducts({required int subjectId});
}

class ApiProductService implements ProductDetailApiProductsService {
  final ProductServiceProductsApiClient productsApiClient;

  ApiProductService({required this.productsApiClient});

  @override
  Future<List<ProductItem>> getProducts({
    required int subjectId,
  }) async {
    try {
      final result = await productsApiClient.getProducts(
        subjectId: subjectId,
      );

      return result;
    } catch (e) {
      throw Exception('Failed to fetch products');
    }
  }
}
