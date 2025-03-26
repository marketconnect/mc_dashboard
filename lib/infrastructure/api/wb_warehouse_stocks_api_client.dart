import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/wb_warehouse_stock.dart';
import '../../domain/services/wb_warehouse_stocks_service.dart';

class WbWarehouseStocksApiClient implements WbWarehouseStocksServiceApiClient {
  static const String _baseUrl =
      'https://marketplace-api.wildberries.ru/api/v3';

  const WbWarehouseStocksApiClient();

  @override
  Future<List<WbSellerStock>> fetchStocks({
    required String token,
    required int warehouseId,
    required List<String> skus,
  }) async {
    final url = Uri.parse('$_baseUrl/stocks/$warehouseId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: jsonEncode({
          'skus': skus,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> stocksJson = jsonResponse['stocks'] ?? [];
        return stocksJson.map((json) => WbSellerStock.fromJson(json)).toList();
      } else {
        throw Exception(
            'Error fetching warehouse stocks: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error while fetching warehouse stocks: $e');
    }
  }
}
