import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mc_dashboard/domain/services/wb_price_service.dart';

class WbPriceApiClient implements WbPriceApiServiceApiClient {
  const WbPriceApiClient();
  static const baseUrl = 'https://discounts-prices-api.wildberries.ru';

  @override
  Future<Map<String, dynamic>> uploadPriceTask({
    required String token,
    required List<Map<String, dynamic>> priceData,
  }) async {
    final url = Uri.parse('$baseUrl/api/v2/upload/task');

    // Формируем тело запроса по спецификации:
    // {
    //   "data": [
    //     {
    //       "nmID": 123,
    //       "price": 999,
    //       "discount": 30
    //     }
    //   ]
    // }
    final Map<String, dynamic> requestBody = {
      'data': priceData,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Авторизация через HeaderApiKey
          'Authorization': token,
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Успешный ответ
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else if (response.statusCode == 208) {
        // Загрузка уже существует
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else if (response.statusCode == 400) {
        throw Exception(
            'Неправильный запрос: ${response.statusCode} ${response.body}');
      } else if (response.statusCode == 401) {
        throw Exception(
            'Пользователь не авторизован: ${response.statusCode} ${response.body}');
      } else if (response.statusCode == 422) {
        throw Exception(
            'Неожиданный результат: ${response.statusCode} ${response.body}');
      } else if (response.statusCode == 429) {
        throw Exception(
            'Слишком много запросов: ${response.statusCode} ${response.body}');
      } else {
        throw Exception(
            'Ошибка при установке цен и скидок: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Ошибка сети при установке цен и скидок: $e');
    }
  }
}
