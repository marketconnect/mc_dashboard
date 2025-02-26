import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mc_dashboard/domain/entities/good.dart';
import 'package:mc_dashboard/domain/services/goods_service.dart';

class WbGoodsApiClient implements WbGoodsServiceApiClient {
  static const String baseUrl =
      'https://discounts-prices-api.wildberries.ru/api/v2/list/goods/filter';

  const WbGoodsApiClient();

  @override
  Future<List<Good>> fetchGoods({
    required String apiKey,
    int? filterNmID,
  }) async {
    List<Good> allGoods = [];
    int offset = 0;
    const int limit = 1000;
    bool hasMore = true;

    while (hasMore) {
      final Uri url = Uri.parse(
          '$baseUrl?limit=$limit&offset=$offset${filterNmID != null ? '&filterNmID=$filterNmID' : ''}');

      try {
        final response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': apiKey,
          },
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          final List<dynamic> goodsJson =
              jsonResponse['data']['listGoods'] ?? [];
          final List<Good> batchGoods =
              goodsJson.map((json) => Good.fromJson(json)).toList();
          allGoods.addAll(batchGoods);

          if (batchGoods.length < limit) {
            hasMore = false;
          } else {
            offset += limit;
            await Future.delayed(
                const Duration(seconds: 1)); // Ограничение 1 запрос в сек.
          }
        } else {
          throw Exception(
              'Ошибка получения товаров: ${response.statusCode} ${response.body}');
        }
      } catch (e) {
        throw Exception('Ошибка сети при получении товаров: $e');
      }
    }

    return allGoods;
  }
}
