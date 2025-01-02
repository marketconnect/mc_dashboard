import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/api/detailed_orders.dart';

import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/domain/entities/detailed_order_item.dart';
import 'package:mc_dashboard/presentation/product_screen/product_view_model.dart';
import 'package:mc_dashboard/presentation/subject_products_screen/subject_products_view_model.dart';

class DetailedOrdersService
    implements
        SubjectProductsViewModelDetailedOrdersService,
        ProductViewModelDetailedOrdersService {
  final DetailedOrdersApiClient detailedOrdersApiClient;

  DetailedOrdersService({required this.detailedOrdersApiClient});
  @override
  Future<Either<AppErrorBase, List<DetailedOrderItem>>> fetchDetailedOrders({
    int? subjectId,
    int? productId,
    int? isFbs,
    String pageSize = '10000',
  }) async {
    try {
      final result = await detailedOrdersApiClient.getDetailedOrders(
        subjectId: subjectId,
        productId: productId,
        pageSize: pageSize,
        isFbs: isFbs,
      );

      return Right(result.detailedOrders);
    } on DioException catch (e, stackTrace) {
      // Подробная обработка ошибок Dio
      final responseMessage = e.response?.data?['message'] ?? e.message;
      final error = AppErrorBase(
        'DioException: $responseMessage',
        name: 'fetchDetailedOrders',
        sendTo: true,
        source: 'DetailedOrdersService',
        args: [
          'subjectId: $subjectId',
          'productId: $productId',
        ],
        stackTrace: stackTrace.toString(),
      );
      AppLogger.log(error); // Логируйте ошибку
      return Left(error);
    } catch (e, stackTrace) {
      // Обработка всех других ошибок
      final error = AppErrorBase(
        'Unexpected error: $e',
        name: 'fetchDetailedOrders',
        sendTo: true,
        source: 'DetailedOrdersService',
        args: [
          'subjectId: $subjectId',
          'productId: $productId',
        ],
        stackTrace: stackTrace.toString(),
      );
      AppLogger.log(error);
      return Left(error);
    }
  }
}
