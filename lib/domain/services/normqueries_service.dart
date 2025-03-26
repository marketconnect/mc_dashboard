import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/infrastructure/api/normqueries.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/domain/entities/normquery.dart';
import 'package:mc_dashboard/domain/entities/normquery_product.dart';
import 'package:mc_dashboard/presentation/product_screen/product_view_model.dart';
import 'package:mc_dashboard/presentation/seo_requests_extend_screen/seo_requests_extend_view_model.dart';

class NormqueryService
    implements
        ProductViewModelNormqueryService,
        SeoRequestsExtendNormqueryService {
  final NormqueriesApiClient apiClient;

  NormqueryService(this.apiClient);

  @override
  Future<Either<AppErrorBase, List<NormqueryProduct>>> get(
      {required List<int> ids}) async {
    if (ids.isEmpty) {
      return Right([]);
    }
    try {
      final result = await apiClient.getNormqueriesProducts(ids: ids);

      return Right(result.normqueriesWithProducts);
    } catch (e) {
      return const Right([]);

      // final responseMessage = e.response?.data?['message'] ?? e.message;
    }
  }

  @override
  Future<Either<AppErrorBase, List<Normquery>>> getUniqueNormqueries(
      {required List<int> ids}) async {
    if (ids.isEmpty) {
      return Right([]);
    }
    try {
      final result = await apiClient.getUniqueNormqueries(ids: ids);

      return Right(result.uniqueNormqueries);
    } catch (e) {
      return const Right([]);
    }
  }
}
