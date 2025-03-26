import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/domain/entities/wb_product.dart';
import 'package:mc_dashboard/presentation/product_screen/product_view_model.dart';

abstract class WbProductsServiceApiClient {
  Future<List<WbProduct>> fetchProducts(List<int> nmIds);
}

class WbProductsServiceImpl implements WbProductsService {
  final WbProductsServiceApiClient apiClient;

  WbProductsServiceImpl({required this.apiClient});

  @override
  Future<Either<AppErrorBase, List<WbProduct>>> fetchProducts(
      List<int> nmIds) async {
    try {
      final products = await apiClient.fetchProducts(nmIds);
      return right(products);
    } catch (e) {
      return left(AppErrorBase(
        'Ошибка загрузки продуктов: $e',
        name: 'fetchProducts',
        sendTo: true,
      ));
    }
  }
}
