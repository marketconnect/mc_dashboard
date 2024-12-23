import 'package:mc_dashboard/.env.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:mc_dashboard/domain/entities/order.dart';
part 'orders.g.dart';
// TODO Add token
@RestApi(baseUrl: ApiSettings.baseUrl)
abstract class OrdersApiClient {
  factory OrdersApiClient(Dio dio, {String baseUrl}) = _OrdersApiClient;

  @GET("/orders")
  Future<OrdersResponse> getOrders({
    @Query("product_id") int? productId,
    @Query("warehouse_id") int? warehouseId,
    @Query("start_date") required String startDate,
    @Query("end_date") required String endDate,
    @Query("page") int? page,
    @Query("page_size") int? pageSize,
  });
}

class OrdersResponse {
  final List<OrderWb> orders;

  OrdersResponse({
    required this.orders,
  });

  factory OrdersResponse.fromJson(Map<String, dynamic> json) {
    return OrdersResponse(
      orders: (json['orders'] as List<dynamic>)
          .map((item) => OrderWb.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orders': orders.map((order) => order.toJson()).toList(),
    };
  }
}
