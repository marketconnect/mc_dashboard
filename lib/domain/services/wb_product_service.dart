import 'package:mc_dashboard/domain/entities/wb_product.dart';

abstract class WbProductsServiceApiClient {
  Future<List<WbProduct>> fetchProducts(List<int> nmIds);
}

class WbProductsService {
  final WbProductsServiceApiClient apiClient;

  WbProductsService({required this.apiClient});

  Future<List<WbProduct>> fetchProducts(List<int> nmIds) async {
    try {
      final products = await apiClient.fetchProducts(nmIds);

      return products;
    } catch (e) {
      throw Exception("Failed to fetch WB products: ${e.toString()}");
    }
  }
}
