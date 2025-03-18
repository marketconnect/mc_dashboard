import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mc_dashboard/.env.dart';
import 'package:mc_dashboard/domain/entities/wb_stats_keywords.dart';
import 'package:mc_dashboard/domain/services/wb_stats_keywords_service.dart';

class WbStatsKeywordsApiClient
    implements WbStatsKeywordsWbStatsKeywordsApiClient {
  const WbStatsKeywordsApiClient();
  static const baseUrl = WbApi.advBaseUrl;

  @override
  Future<List<WbStatsKeywords>> getStatsKeywords({
    required String token,
    required int advertId,
    required String from,
    required String to,
  }) async {
    print("getStatsKeywords");
    final url = Uri.parse('$baseUrl?advert_id=$advertId&from=$from&to=$to');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        print("Response status code: ${body}");
        if (body.containsKey('keywords')) {
          final List<WbStatsKeywords> stats = [];

          // Перебираем даты и собираем статистику
          for (var entry in body['keywords']) {
            if (entry.containsKey('stats')) {
              stats.addAll((entry['stats'] as List)
                  .map((e) => WbStatsKeywords.fromJson(e))
                  .toList());
            }
          }
          return stats;
        } else {
          throw Exception('Ошибка: В ответе нет ключа "keywords"');
        }
      } else if (response.statusCode == 400) {
        throw Exception(
            'Неправильный запрос: ${response.statusCode} ${response.body}');
      } else if (response.statusCode == 401) {
        throw Exception(
            'Пользователь не авторизован: ${response.statusCode} ${response.body}');
      } else if (response.statusCode == 429) {
        throw Exception(
            'Слишком много запросов: ${response.statusCode} ${response.body}');
      } else {
        throw Exception(
            'Ошибка при получении статистики по ключевым словам: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception(
          'Ошибка сети при получении статистики по ключевым словам: $e');
    }
  }
}
