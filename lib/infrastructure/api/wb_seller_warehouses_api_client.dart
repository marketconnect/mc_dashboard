import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mc_dashboard/domain/entities/wb_seller_warehouse.dart';
import 'package:mc_dashboard/domain/services/wb_seller_warehouses_service.dart';

class WbSellerWarehousesApiClient
    implements WbSellerWarehousesServiceApiClient {
  static const String _baseUrl =
      'https://marketplace-api.wildberries.ru/api/v3';

  const WbSellerWarehousesApiClient();

  @override
  Future<List<WbSellerWarehouse>> fetchWarehouses(
      {required String token}) async {
    final url = Uri.parse('$_baseUrl/warehouses');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> warehousesJson =
            jsonDecode(utf8.decode(response.bodyBytes));
        return warehousesJson
            .map((json) => WbSellerWarehouse.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Error fetching seller warehouses: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error while fetching seller warehouses: $e');
    }
  }
}
