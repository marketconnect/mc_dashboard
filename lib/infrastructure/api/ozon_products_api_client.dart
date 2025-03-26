import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mc_dashboard/domain/entities/ozon_product.dart';
import 'package:mc_dashboard/domain/services/ozon_products_service.dart';

class OzonProductsApiClient implements OzonProductsServiceApiClient {
  static const String _baseUrl = 'https://api-seller.ozon.ru/v3';

  const OzonProductsApiClient();

  @override
  Future<OzonProductsResponse> fetchProducts({
    required String apiKey,
    required String clientId,
    List<String>? offerIds,
  }) async {
    final url = Uri.parse('$_baseUrl/product/list');

    final Map<String, dynamic> requestBody = {
      'filter': {
        if (offerIds != null) 'offer_id': offerIds,
      },
      'limit': 1000,
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

        return OzonProductsResponse.fromJson(responseJson);
      } else {
        throw Exception(
            'Error fetching Ozon products: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error while fetching Ozon products: $e');
    }
  }

  Future<List<OzonProduct>> fetchAllProducts({
    required String apiKey,
    required String clientId,
    List<String>? offerIds,
    List<int>? productIds,
    String? visibility,
  }) async {
    List<OzonProduct> allProducts = [];
    String? lastId;
    // int limit = 1000;

    do {
      final response = await fetchProducts(
        apiKey: apiKey,
        clientId: clientId,
        offerIds: offerIds,
      );

      allProducts.addAll(response.items);
      lastId = response.lastId;
    } while (lastId != null && allProducts.length < 10000);

    return allProducts;
  }
}
