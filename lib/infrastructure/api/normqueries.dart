import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mc_dashboard/.env.dart';
import 'package:mc_dashboard/domain/entities/normquery.dart';
import 'package:mc_dashboard/domain/entities/normquery_product.dart';

class NormqueriesApiClient {
  final Map<String, CacheEntry<NormqueriesResponse>> _cache = {};
  final Map<String, CacheEntry<UniqueNormqueriesResponse>> _uniqueCache = {};

  NormqueriesApiClient();

  Future<NormqueriesResponse> getNormqueriesProducts(
      {required List<int> ids}) async {
    final cacheKey = 'normqueries-products-${ids.join(",")}';
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    if (_cache.containsKey(cacheKey) &&
        _cache[cacheKey]!.expiration.isAfter(now)) {
      return _cache[cacheKey]!.data;
    }

    final query = ids.map((e) => 'ids=$e').join('&');
    final uri = Uri.parse('${ApiSettings.baseUrl}/normqueries-products?$query');

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      final result = NormqueriesResponse.fromJson(jsonData);
      _cache[cacheKey] = CacheEntry(data: result, expiration: endOfDay);
      return result;
    } else {
      throw Exception(
          'Ошибка получения normqueries-products, статус: ${response.statusCode}');
    }
  }

  Future<UniqueNormqueriesResponse> getUniqueNormqueries(
      {required List<int> ids}) async {
    final cacheKey = 'unique-normqueries-${ids.join(",")}';
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    if (_uniqueCache.containsKey(cacheKey) &&
        _uniqueCache[cacheKey]!.expiration.isAfter(now)) {
      return _uniqueCache[cacheKey]!.data;
    }

    final query = ids.map((e) => 'ids=$e').join('&');
    final uri = Uri.parse('${ApiSettings.baseUrl}/normqueries-unique?$query');

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonData =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final result = UniqueNormqueriesResponse.fromJson(jsonData);
      _uniqueCache[cacheKey] = CacheEntry(data: result, expiration: endOfDay);
      return result;
    } else {
      throw Exception(
          'Ошибка получения unique_normqueries, статус: ${response.statusCode}');
    }
  }
}

class CacheEntry<T> {
  final T data;
  final DateTime expiration;

  CacheEntry({required this.data, required this.expiration});
}

class NormqueriesResponse {
  final List<NormqueryProduct> normqueriesWithProducts;

  NormqueriesResponse({required this.normqueriesWithProducts});

  factory NormqueriesResponse.fromJson(Map<String, dynamic> json) {
    final products = json['normquery_with_products'];
    if (products is! List) {
      throw Exception(
          'Invalid format: "normquery_with_products" must be a List.');
    }
    return NormqueriesResponse(
      normqueriesWithProducts: products.map((item) {
        if (item is! Map<String, dynamic>) {
          throw Exception(
              'Invalid format: each item in "normquery_with_products" must be a Map<String, dynamic>.');
        }
        return NormqueryProduct.fromJson(item);
      }).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'normquery_with_products':
          normqueriesWithProducts.map((nqp) => nqp.toJson()).toList(),
    };
  }
}

class UniqueNormqueriesResponse {
  final List<Normquery> uniqueNormqueries;

  UniqueNormqueriesResponse({required this.uniqueNormqueries});

  factory UniqueNormqueriesResponse.fromJson(Map<String, dynamic> json) {
    final queries = json['unique_normqueries'];
    if (queries is! List) {
      throw Exception('Invalid format: "unique_normqueries" must be a List.');
    }
    return UniqueNormqueriesResponse(
      uniqueNormqueries: queries.map((item) {
        if (item is! Map<String, dynamic>) {
          throw Exception(
              'Invalid format: each item in "unique_normqueries" must be a Map<String, dynamic>.');
        }
        return Normquery.fromJson(item);
      }).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unique_normqueries': uniqueNormqueries.map((n) => n.toJson()).toList(),
    };
  }
}
