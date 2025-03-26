import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:mc_dashboard/.env.dart';
import 'package:mc_dashboard/domain/entities/wb_product.dart';
import 'package:mc_dashboard/domain/services/wb_products_service.dart';

class WbProductsApiClient implements WbProductsServiceApiClient {
  WbProductsApiClient();
  static const String _baseUrl = ApiSettings.wbDetailsProxy;
  final Map<String, CacheEntry<List<WbProduct>>> _cache = {};
  // Singleton instance
  static final WbProductsApiClient instance = WbProductsApiClient();

  @override
  Future<List<WbProduct>> fetchProducts(List<int> nmIds) async {
    final cacheKey = 'wbProducts-${nmIds.join(";")}';
    final now = DateTime.now();
    final oneMinute =
        DateTime(now.year, now.month, now.day, now.hour, now.minute + 1);

    if (_cache.containsKey(cacheKey) &&
        _cache[cacheKey]!.expiration.isAfter(now)) {
      return _cache[cacheKey]!.data;
    }

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'appType': '1',
      'curr': 'rub',
      'dest': '123589415',
      'spp': '30',
      'ab_testing': 'false',
      'nm': nmIds.map((id) => id.toString()).join(';'),
    });

    final headers = {
      'Accept': '*/*',
      'Accept-Encoding': 'gzip, deflate, br, zstd',
      'Accept-Language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7,fr;q=0.6',
      'Sec-Fetch-Dest': 'empty',
      'Sec-Fetch-Mode': 'cors',
      'Sec-Fetch-Site': 'same-origin',
      'User-Agent':
          'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36',
    };

    final response = await http.get(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch WB products: ${response.statusCode}");
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    final productsJson = data['data']['products'] as List<dynamic>;
    final result =
        productsJson.map((json) => WbProduct.fromJson(json)).toList();

    _cache[cacheKey] = CacheEntry(data: result, expiration: oneMinute);
    return result;
  }
}

class CacheEntry<T> {
  final T data;
  final DateTime expiration;

  CacheEntry({required this.data, required this.expiration});
}
