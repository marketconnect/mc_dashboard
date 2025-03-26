import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mc_dashboard/domain/entities/ozon_fbo_stock.dart';
import 'package:mc_dashboard/domain/services/ozon_fbo_stocks_service.dart';

class OzonFboStocksApiClient implements OzonFboStocksServiceApiClient {
  static const String _baseUrl = 'https://api-seller.ozon.ru/v1';

  const OzonFboStocksApiClient();

  @override
  Future<OzonFboStocksResponse> fetchStocks({
    required String apiKey,
    required String clientId,
    List<String>? skus,
    String? stockTypes,
    List<String>? warehouseIds,
    int? limit,
    int? offset,
  }) async {
    final url = Uri.parse('$_baseUrl/analytics/manage/stocks');

    final Map<String, dynamic> requestBody = {
      'filter': {
        if (skus != null) 'skus': skus,
        if (stockTypes != null) 'stock_types': stockTypes,
        if (warehouseIds != null) 'warehouse_ids': warehouseIds,
      },
      if (limit != null) 'limit': limit,
      if (offset != null) 'offset': offset,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Client-Id': clientId,
          'Api-Key': apiKey,
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseJson =
            jsonDecode(utf8.decode(response.bodyBytes));
        return OzonFboStocksResponse.fromJson(responseJson);
      } else {
        throw Exception(
            'Error fetching Ozon FBO stocks: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error while fetching Ozon FBO stocks: $e');
    }
  }
}
