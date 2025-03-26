// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:mc_dashboard/.env.dart';
import 'package:mc_dashboard/domain/entities/product_item.dart';

import 'dart:convert';

import 'package:mc_dashboard/domain/services/api_products_service.dart';

class ProductsApiClient implements ProductServiceProductsApiClient {
  final String baseUrl = Env.mcApiUrl;

  const ProductsApiClient();

  @override
  Future<List<ProductItem>> getProducts({required int subjectId}) async {
    final uri = Uri.parse('$baseUrl/products?subject_id=$subjectId');

    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      return (jsonResponse['products'] as List)
          .map((item) => ProductItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to fetch products: ${response.statusCode}');
    }
  }
}
