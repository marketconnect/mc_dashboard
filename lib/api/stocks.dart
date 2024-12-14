import 'package:mc_dashboard/domain/entities/stock.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'stocks.g.dart';

@RestApi(baseUrl: "http://localhost:2009")
abstract class StocksApiClient {
  factory StocksApiClient(Dio dio, {String baseUrl}) = _StocksApiClient;

  @GET("/stocks")
  Future<StocksResponse> getStocks({
    @Query("product_id") int? productId,
    @Query("warehouse_id") int? warehouseId,
    @Query("start_date") required String startDate,
    @Query("end_date") required String endDate,
    @Query("page") int? page,
    @Query("page_size") int? pageSize,
  });
}

class StocksResponse {
  final List<Stock> stocks;

  StocksResponse({
    required this.stocks,
  });

  factory StocksResponse.fromJson(Map<String, dynamic> json) {
    return StocksResponse(
      stocks: (json['stocks'] as List<dynamic>)
          .map((item) => Stock.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stocks': stocks.map((stock) => stock.toJson()).toList(),
    };
  }
}
