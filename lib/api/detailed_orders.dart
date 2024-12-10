import 'package:mc_dashboard/domain/entities/detailed_order_item.dart';

import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'detailed_orders.g.dart';

@RestApi(baseUrl: "http://localhost:2009")
abstract class DetailedOrdersApiClient {
  factory DetailedOrdersApiClient(Dio dio, {String baseUrl}) =
      _DetailedOrdersApiClient;

  @GET("/detailed-orders30d")
  Future<DetailedOrdersResponse> getDetailedOrders({
    @Query("subject_id") int? subjectId,
    @Query("product_id") int? productId,
    @Query("is_fbs") int? isFbs,
    @Query("page_size") String? pageSize,
  });
}
