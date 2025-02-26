import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mc_dashboard/.env.dart';
import 'package:mc_dashboard/domain/entities/warehouse.dart';

class CacheEntry<T> {
  final T data;
  final DateTime expiration;

  CacheEntry({required this.data, required this.expiration});
}

class WarehousesApiClient {
  final String baseUrl;
  final Map<String, CacheEntry<WarehousesResponse>> _cache = {};

  WarehousesApiClient({String? baseUrl})
      : baseUrl = baseUrl ?? ApiSettings.baseUrl;

  Future<WarehousesResponse> getWarehouses({required List<int> ids}) async {
    final cacheKey = 'warehouses-${ids.join(",")}';
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    if (_cache.containsKey(cacheKey) &&
        _cache[cacheKey]!.expiration.isAfter(now)) {
      return _cache[cacheKey]!.data;
    }

    final uri = Uri.parse('$baseUrl/warehouses').replace(
      queryParameters: {
        'ids': ids.join(','),
      },
    );

    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final jsonData =
          json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final result = WarehousesResponse.fromJson(jsonData);
      _cache[cacheKey] = CacheEntry(data: result, expiration: endOfDay);
      return result;
    } else {
      throw Exception(
          'Ошибка получения складов, статус: ${response.statusCode}');
    }
  }
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
