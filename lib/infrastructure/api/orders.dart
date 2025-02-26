import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mc_dashboard/.env.dart';
import 'package:mc_dashboard/domain/entities/order.dart';

class OrdersApiClient {
  final String baseUrl;
  final Map<String, CacheEntry<OrdersResponse>> _cache = {};

  OrdersApiClient({String? baseUrl}) : baseUrl = baseUrl ?? ApiSettings.baseUrl;

  Future<OrdersResponse> getOrders({
    int? productId,
    int? warehouseId,
    required String startDate,
    required String endDate,
    int? page,
    int? pageSize,
  }) async {
    final cacheKey =
        'orders-$productId-$warehouseId-$startDate-$endDate-$page-$pageSize';
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    if (_cache.containsKey(cacheKey) &&
        _cache[cacheKey]!.expiration.isAfter(now)) {
      return _cache[cacheKey]!.data;
    }

    final uri = Uri.parse('$baseUrl/orders').replace(
      queryParameters: {
        if (productId != null) 'product_id': productId.toString(),
        if (warehouseId != null) 'warehouse_id': warehouseId.toString(),
        'start_date': startDate,
        'end_date': endDate,
        if (page != null) 'page': page.toString(),
        if (pageSize != null) 'page_size': pageSize.toString(),
      },
    );

    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final jsonData = json.decode(utf8.decode(response.bodyBytes));
      final result = OrdersResponse.fromJson(jsonData);
      _cache[cacheKey] = CacheEntry(data: result, expiration: endOfDay);
      return result;
    } else {
      throw Exception(
          'Ошибка получения заказов, статус: ${response.statusCode}');
    }
  }
}

class CacheEntry<T> {
  final T data;
  final DateTime expiration;

  CacheEntry({required this.data, required this.expiration});
}

class OrdersResponse {
  final List<OrderWb> orders;

  OrdersResponse({required this.orders});

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
