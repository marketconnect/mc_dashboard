import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mc_dashboard/.env.dart';
import 'package:mc_dashboard/domain/entities/product_item.dart';

class CacheEntry<T> {
  final T data;
  final DateTime expiration;

  CacheEntry({required this.data, required this.expiration});
}

class ProductsApiClient {
  final String baseUrl;
  final Map<String, CacheEntry<ProductsResponse>> _cache = {};

  ProductsApiClient({String? baseUrl})
      : baseUrl = baseUrl ?? ApiSettings.baseUrl;

  Future<ProductsResponse> getProducts({
    int? brandId,
    int? subjectId,
    int? supplierId,
    int? page,
    int? pageSize,
  }) async {
    final cacheKey = 'products-$brandId-$subjectId-$supplierId-$page-$pageSize';
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    if (_cache.containsKey(cacheKey) &&
        _cache[cacheKey]!.expiration.isAfter(now)) {
      return _cache[cacheKey]!.data;
    }

    final uri = Uri.parse('$baseUrl/products').replace(queryParameters: {
      if (brandId != null) 'brand_id': brandId.toString(),
      if (subjectId != null) 'subject_id': subjectId.toString(),
      if (supplierId != null) 'supplier_id': supplierId.toString(),
      if (page != null) 'page': page.toString(),
      if (pageSize != null) 'page_size': pageSize.toString(),
    });

    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final jsonData = json.decode(utf8.decode(response.bodyBytes));
      final result = ProductsResponse.fromJson(jsonData);
      _cache[cacheKey] = CacheEntry(data: result, expiration: endOfDay);
      return result;
    } else {
      throw Exception(
          'Ошибка получения продуктов, статус: ${response.statusCode}');
    }
  }
}

class ProductsResponse {
  final Pagination pagination;
  final List<ProductItem> products;

  ProductsResponse({required this.pagination, required this.products});

  factory ProductsResponse.fromJson(Map<String, dynamic> json) {
    return ProductsResponse(
      pagination: Pagination.fromJson(json['pagination']),
      products: (json['products'] as List<dynamic>)
          .map((item) => ProductItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pagination': pagination.toJson(),
      'products': products.map((product) => product.toJson()).toList(),
    };
  }
}

class Pagination {
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final int totalItems;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.totalItems,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'] as int,
      totalPages: json['total_pages'] as int,
      pageSize: json['page_size'] as int,
      totalItems: json['total_items'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'total_pages': totalPages,
      'page_size': pageSize,
      'total_items': totalItems,
    };
  }
}
