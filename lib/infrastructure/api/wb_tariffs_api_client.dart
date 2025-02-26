import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mc_dashboard/domain/entities/wb_box_tariff.dart';
import 'package:mc_dashboard/domain/entities/wb_tariff.dart';
import 'package:mc_dashboard/domain/services/wb_tariffs_service.dart';

class WbTariffsApiClient implements WbTariffsServiceApiClient {
  static const String _baseUrl =
      'https://common-api.wildberries.ru/api/v1/tariffs';

  const WbTariffsApiClient();

  @override
  Future<List<WbTariff>> fetchTariffs(
      {required String token, String locale = 'ru'}) async {
    final url = Uri.parse('$_baseUrl/commission?locale=$locale');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> reportJson = jsonResponse['report'] ?? [];

        return reportJson.map((json) => WbTariff.fromJson(json)).toList();
      } else {
        throw Exception(
            'Ошибка получения комиссии: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Ошибка сети при получении комиссии: $e');
    }
  }

  @override
  Future<List<WbBoxTariff>> fetchBoxTariffs(
      {required String token, required String date}) async {
    final url = Uri.parse('$_baseUrl/box?date=$date');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> warehouseJson =
            jsonResponse['response']['data']['warehouseList'] ?? [];

        return warehouseJson.map((json) => WbBoxTariff.fromJson(json)).toList();
      } else {
        throw Exception(
            'Ошибка получения тарифов для коробов: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Ошибка сети при получении тарифов для коробов: $e');
    }
  }
}
