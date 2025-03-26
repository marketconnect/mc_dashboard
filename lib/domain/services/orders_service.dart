import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/infrastructure/api/orders.dart';

import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/domain/entities/order.dart';

import 'package:mc_dashboard/presentation/product_screen/product_view_model.dart';

class OrderService implements ProductViewModelOrderService {
  final OrdersApiClient ordersApiClient;

  const OrderService({required this.ordersApiClient});

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
    } catch (e) {
      return const Right([]);
    }
  }
}
