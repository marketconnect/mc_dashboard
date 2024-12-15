import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/api/orders.dart';

import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/domain/entities/order.dart';

import 'package:mc_dashboard/presentation/product_screen/product_view_model.dart';

class OrderService implements ProductViewModelOrderService {
  final OrdersApiClient ordersApiClient;

  OrderService({required this.ordersApiClient});

  @override
  Future<Either<AppErrorBase, List<OrderWb>>> getOneMonthOrders({
    int? productId,
  }) async {
    try {
      final today = DateTime.now();
      final startDate = today.subtract(const Duration(days: 30));
      final endDate = today;

      final startDateStr = startDate.toIso8601String().substring(0, 10);
      final endDateStr = endDate.toIso8601String().substring(0, 10);

      final result = await ordersApiClient.getOrders(
        productId: productId,
        pageSize: 10000,
        startDate: startDateStr,
        endDate: endDateStr,
      );

      return Right(result.orders);
    } on DioException catch (e, stackTrace) {
      // Обработка 404 ошибки: возвращаем пустой список
      if (e.response?.statusCode == 404) {
        return const Right([]);
      }

      // Обработка остальных ошибок
      final responseMessage = e.response?.data?['message'] ?? e.message;
      final error = AppErrorBase(
        'DioException: $responseMessage',
        name: 'getOneMonthOrders',
        sendTo: true,
        source: 'OrderService',
        args: [
          'productId: $productId',
        ],
        stackTrace: stackTrace.toString(),
      );
      AppLogger.log(error);
      return Left(error);
    } catch (e, stackTrace) {
      final error = AppErrorBase(
        'Unexpected error: $e',
        name: 'getOneMonthOrders',
        sendTo: true,
        source: 'OrderService',
        args: [
          'productId: $productId',
        ],
        stackTrace: stackTrace.toString(),
      );
      AppLogger.log(error);
      return Left(error);
    }
  }
}
