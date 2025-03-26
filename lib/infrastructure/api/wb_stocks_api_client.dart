import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mc_dashboard/domain/services/wb_stocks_service.dart';
import '../../domain/entities/wb_stock.dart';

class WbStocksApiClient implements WbStocksServiceApiClient {
  static const String _baseUrl =
      'https://statistics-api.wildberries.ru/api/v1/supplier';

  const WbStocksApiClient();

  @override
  Future<List<WbStock>> fetchStocks({
    required String token,
    required String dateFrom,
  }) async {
    final url = Uri.parse('$_baseUrl/stocks').replace(
      queryParameters: {
        'dateFrom': dateFrom,
      },
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> stocksJson =
            jsonDecode(utf8.decode(response.bodyBytes));

        return stocksJson.map((json) => WbStock.fromJson(json)).toList();
      } else {
        throw Exception(
            'Error fetching stocks: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error while fetching stocks: $e');
    }
  }
}
