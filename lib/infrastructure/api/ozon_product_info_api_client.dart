import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mc_dashboard/domain/entities/ozon_product_info.dart';
import 'package:mc_dashboard/domain/services/ozon_product_info_service.dart';

class OzonProductInfoApiClient implements OzonProductInfoServiceApiClient {
  static const String _baseUrl = 'https://api-seller.ozon.ru/v3';

  const OzonProductInfoApiClient();

  @override
  Future<OzonProductInfoResponse> fetchProductInfo({
    required String apiKey,
    required String clientId,
    required List<String> offerIds,
  }) async {
    final url = Uri.parse('$_baseUrl/product/info/list');

    final Map<String, dynamic> requestBody = {
      'offer_id': offerIds,
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
        return OzonProductInfoResponse.fromJson(responseJson);
      } else {
        throw Exception(
            'Error fetching Ozon product info: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error while fetching Ozon product info: $e');
    }
  }
}
