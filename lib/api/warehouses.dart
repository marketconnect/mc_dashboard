import 'package:mc_dashboard/.env.dart';
import 'package:mc_dashboard/domain/entities/warehouse.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'warehouses.g.dart';

@RestApi(baseUrl: ApiSettings.baseUrl)
abstract class WarehousesApiClient {
  factory WarehousesApiClient(Dio dio, {String baseUrl}) = _WarehousesApiClient;

  @GET("/warehouses")
  Future<WarehousesResponse> getWarehouses({
    @Query("ids") required List<int> ids,
  });
}

class WarehousesResponse {
  final List<Warehouse> warehouses;

  WarehousesResponse({required this.warehouses});

  factory WarehousesResponse.fromJson(Map<String, dynamic> json) {
    return WarehousesResponse(
      warehouses: (json['warehouses'] as List<dynamic>)
          .map((e) => Warehouse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'warehouses': warehouses.map((w) => w.toJson()).toList(),
      };
}
