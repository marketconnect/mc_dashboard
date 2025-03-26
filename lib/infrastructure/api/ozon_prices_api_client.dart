import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mc_dashboard/domain/entities/ozon_price.dart';
import 'package:mc_dashboard/domain/services/ozon_prices_service.dart';

class OzonPricesApiClient implements OzonPricesServiceApiClient {
  static const String _baseUrl = 'https://api-seller.ozon.ru/v5';

  const OzonPricesApiClient();

  @override
  Future<OzonPricesResponse> fetchPrices({
    required String apiKey,
    required String clientId,
    String? cursor,
    List<String>? offerIds,
    List<int>? productIds,
    String? visibility,
    int? limit,
  }) async {
    final url = Uri.parse('$_baseUrl/product/info/prices');

    final Map<String, dynamic> requestBody = {
      if (cursor != null) 'cursor': cursor,
      'filter': {
        if (offerIds != null) 'offer_id': offerIds,
        if (productIds != null) 'product_id': productIds,
        if (visibility != null) 'visibility': visibility,
      },
      if (limit != null) 'limit': limit,
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
        return OzonPricesResponse.fromJson(responseJson);
      } else {
        throw Exception(
            'Error fetching Ozon prices: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error while fetching Ozon prices: $e');
    }
  }
}
