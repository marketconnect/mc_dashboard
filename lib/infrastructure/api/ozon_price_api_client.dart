import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mc_dashboard/core/constants/ozon_api.dart';
import 'package:mc_dashboard/domain/services/ozon_price_service.dart';

class OzonPriceApiClient implements OzonPriceServiceOzonPriceApiClient {
  const OzonPriceApiClient();
  static const baseUrl = OzonApi.baseUrl;

  @override
  Future<Map<String, dynamic>> updatePrices({
    required String clientId,
    required String apiKey,
    required List<Map<String, dynamic>> prices,
  }) async {
    final url = Uri.parse('$baseUrl/v1/product/import/prices');

    final Map<String, dynamic> requestBody = {
      'prices': prices,
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
      print(requestBody);
      print(response.body);
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else if (response.statusCode == 400) {
        throw Exception(
            'Неправильный запрос: ${response.statusCode} ${response.body}');
      } else if (response.statusCode == 403) {
        throw Exception(
            'Доступ запрещен: ${response.statusCode} ${response.body}');
      } else if (response.statusCode == 404) {
        throw Exception(
            'Ответ не найден: ${response.statusCode} ${response.body}');
      } else if (response.statusCode == 409) {
        throw Exception(
            'Конфликт запроса: ${response.statusCode} ${response.body}');
      } else if (response.statusCode == 500) {
        throw Exception(
            'Внутренняя ошибка сервера: ${response.statusCode} ${response.body}');
      } else {
        throw Exception(
            'Ошибка при обновлении цен: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Ошибка сети при обновлении цен: $e');
    }
  }
}
