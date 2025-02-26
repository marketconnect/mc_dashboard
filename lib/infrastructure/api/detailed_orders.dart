import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mc_dashboard/.env.dart';
import 'package:mc_dashboard/domain/entities/detailed_order_item.dart';

class CacheEntry<T> {
  final T data;
  final DateTime expiration;

  CacheEntry({required this.data, required this.expiration});
}

class DetailedOrdersApiClient {
  final String baseUrl;
  final Map<String, CacheEntry<DetailedOrdersResponse>> _cache = {};

  DetailedOrdersApiClient({String? baseUrl})
      : baseUrl = baseUrl ?? ApiSettings.baseUrl;

  Future<DetailedOrdersResponse> getDetailedOrders({
    int? subjectId,
    int? productId,
    int? isFbs,
    String? pageSize,
  }) async {
    final cacheKey = 'detailed-orders-$subjectId-$productId-$isFbs-$pageSize';

    // Проверяем кеш
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final cachedEntry = _cache[cacheKey];

    if (cachedEntry != null && cachedEntry.expiration.isAfter(now)) {
      return cachedEntry.data;
    }

    final uri = Uri.parse('$baseUrl/detailed-orders30d').replace(
      queryParameters: {
        if (subjectId != null) 'subject_id': subjectId.toString(),
        if (productId != null) 'product_id': productId.toString(),
        if (isFbs != null) 'is_fbs': isFbs.toString(),
        if (pageSize != null) 'page_size': pageSize,
      },
    );

    // Выполняем GET-запрос
    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(utf8.decode(response.bodyBytes));
      final result = DetailedOrdersResponse.fromJson(jsonData);

      if (result.detailedOrders.isNotEmpty) {
        _cache[cacheKey] = CacheEntry(data: result, expiration: endOfDay);
      }

      return result;
    } else {
      throw Exception(
          'Ошибка получения подробных заказов, статус: ${response.statusCode}');
    }
  }
}

class DetailedOrdersResponse {
  final List<DetailedOrderItem> detailedOrders;

  DetailedOrdersResponse({required this.detailedOrders});

  factory DetailedOrdersResponse.fromJson(Map<String, dynamic> json) {
    return DetailedOrdersResponse(
      detailedOrders: (json['detailed_orders30d'] as List)
          .map((item) =>
              DetailedOrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detailed_orders30d':
          detailedOrders.map((item) => item.toJson()).toList(),
    };
  }
}
