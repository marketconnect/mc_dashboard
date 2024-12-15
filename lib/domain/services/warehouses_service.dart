import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import 'package:mc_dashboard/api/warehouses.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/domain/entities/warehouse.dart';
import 'package:mc_dashboard/presentation/product_screen/product_view_model.dart';

class WhService implements ProductViewModelWhService {
  final WarehousesApiClient whApiClient;

  WhService({required this.whApiClient});

  @override
  Future<Either<AppErrorBase, List<Warehouse>>> getWarehouses({
    required List<int> ids,
  }) async {
    try {
      final result = await whApiClient.getWarehouses(ids: ids);

      return Right(result.warehouses);
    } on DioException catch (e, stackTrace) {
      final responseMessage = e.response?.data?['message'] ?? e.message;
      final error = AppErrorBase(
        'DioException: $responseMessage',
        name: 'getOneMonthStocks',
        sendTo: true,
        source: 'WhService',
        args: [
          'productId: $ids',
        ],
        stackTrace: stackTrace.toString(),
      );
      AppLogger.log(error);
      return Left(error);
    } catch (e, stackTrace) {
      final error = AppErrorBase(
        'Unexpected error: $e',
        name: 'getOneMonthStocks',
        sendTo: true,
        source: 'WhService',
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
