import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mc_dashboard/domain/entities/ozon_fbs_stock.dart';
import 'package:mc_dashboard/domain/services/ozon_fbs_stocks_service.dart';

class OzonFbsStocksApiClient implements OzonFbsStocksServiceApiClient {
  static const String _baseUrl = 'https://api-seller.ozon.ru/v4';

  const OzonFbsStocksApiClient();

  @override
  Future<OzonFbsStocksResponse> fetchStocks({
    required String apiKey,
    required String clientId,
    String? cursor,
    List<String>? offerIds,
    List<int>? productIds,
    String? visibility,
    Map<String, bool>? withQuant,
    int? limit,
  }) async {
    final url = Uri.parse('$_baseUrl/product/info/stocks');

    final Map<String, dynamic> requestBody = {
      if (cursor != null) 'cursor': cursor,
      'filter': {
        if (offerIds != null) 'offer_id': offerIds,
        if (productIds != null) 'product_id': productIds,
        if (visibility != null) 'visibility': visibility,
      },
      if (withQuant != null) 'with_quant': withQuant,
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
        return OzonFbsStocksResponse.fromJson(responseJson);
      } else {
        throw Exception(
            'Error fetching Ozon FBS stocks: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error while fetching Ozon FBS stocks: $e');
    }
  }
}
