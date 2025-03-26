import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mc_dashboard/.env.dart';
import 'package:mc_dashboard/domain/entities/stock.dart';

class StocksApiClient {
  static final StocksApiClient instance = StocksApiClient();
  final String baseUrl = ApiSettings.baseUrl;
  final Map<String, CacheEntry<StocksResponse>> _cache = {};

  Future<StocksResponse> getStocks({
    int? productId,
    int? warehouseId,
    required String startDate,
    required String endDate,
    int? page,
    int? pageSize,
  }) async {
    final cacheKey =
        'stocks-$productId-$warehouseId-$startDate-$endDate-$page-$pageSize';
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    if (_cache.containsKey(cacheKey) &&
        _cache[cacheKey]!.expiration.isAfter(now)) {
      return _cache[cacheKey]!.data;
    }

    final uri = Uri.parse('$baseUrl/stocks').replace(queryParameters: {
      if (productId != null) 'product_id': productId.toString(),
      if (warehouseId != null) 'warehouse_id': warehouseId.toString(),
      'start_date': startDate,
      'end_date': endDate,
      if (page != null) 'page': page.toString(),
      if (pageSize != null) 'page_size': pageSize.toString(),
    });

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(utf8.decode(response.bodyBytes));
      final result = StocksResponse.fromJson(jsonData);
      _cache[cacheKey] = CacheEntry(data: result, expiration: endOfDay);
      return result;
    } else {
      throw Exception(
          'Ошибка получения stocks, статус: ${response.statusCode}');
    }
  }
}

class CacheEntry<T> {
  final T data;
  final DateTime expiration;

  CacheEntry({required this.data, required this.expiration});
}

class StocksResponse {
  final List<Stock> stocks;

  StocksResponse({required this.stocks});

  factory StocksResponse.fromJson(Map<String, dynamic> json) {
    if (json['stocks'] == null || json['stocks'] is! List) {
      throw FormatException(
          'Ожидался список для "stocks", получено: ${json['stocks']}');
    }

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
