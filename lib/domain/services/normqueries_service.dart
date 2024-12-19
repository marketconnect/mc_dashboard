import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/api/normqueries.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/domain/entities/normquery_product.dart';
import 'package:mc_dashboard/presentation/product_screen/product_view_model.dart';

class NormqueryService implements ProductViewModelNormqueryService {
  final NormqueriesApiClient apiClient;

  NormqueryService(this.apiClient);

  @override
  Future<Either<AppErrorBase, List<NormqueryProduct>>> get(
      {required List<int> ids}) async {
    try {
      final result = await apiClient.getNormqueriesProducts(ids: ids);

      return Right(result.normqueriesWithProducts);
    } on DioException catch (e, stackTrace) {
      if (e.response?.statusCode == 404) {
        return const Right([]);
      }

      // final responseMessage = e.response?.data?['message'] ?? e.message;
      final error = AppErrorBase(
        'DioException: $e',
        name: 'get',
        sendTo: true,
        source: 'NormqueryService',
        args: [
          'ids: $ids',
        ],
        stackTrace: stackTrace.toString(),
      );
      AppLogger.log(error);
      return Left(error);
    } catch (e, stackTrace) {
      final error = AppErrorBase(
        'Unexpected error: $e',
        name: 'get',
        sendTo: true,
        source: 'NormqueryService',
        args: [
          'productId: $ids',
        ],
        stackTrace: stackTrace.toString(),
      );
      AppLogger.log(error);
      return Left(error);
    }
  }
}
