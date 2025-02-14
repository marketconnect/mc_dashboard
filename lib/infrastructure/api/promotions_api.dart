import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:mc_dashboard/domain/entities/promotions.dart';
import 'package:mc_dashboard/domain/services/promotion_service.dart';

class PromotionsApiClient implements PromotionsServiceApiClient {
  final String baseUrl;

  // Список для хранения времени отправки запросов
  final List<DateTime> _requestTimestamps = [];

  PromotionsApiClient(
      {this.baseUrl =
          "https://dp-calendar-api.wildberries.ru/api/v1/calendar"});

  Future<void> _rateLimit() async {
    while (true) {
      final now = DateTime.now();

      _requestTimestamps.removeWhere(
          (timestamp) => now.difference(timestamp) > Duration(seconds: 6));

      if (_requestTimestamps.length < 5) {
        break;
      }

      final earliest = _requestTimestamps.first;
      final waitDuration = Duration(seconds: 6) - now.difference(earliest);

      await Future.delayed(waitDuration);
    }
    _requestTimestamps.add(DateTime.now());
  }

  @override
  Future<List<Promotion>> fetchPromotions({
    required String token,
    required DateTime startDate,
    required DateTime endDate,
    required bool allPromo,
    int limit = 10,
    int offset = 0,
  }) async {
    await _rateLimit(); // Применяем ограничение скорости запросов
    final response = await http.get(
      Uri.parse("$baseUrl/promotions").replace(queryParameters: {
        'startDateTime': startDate.toUtc().toIso8601String(),
        'endDateTime': endDate.toUtc().toIso8601String(),
        'allPromo': allPromo.toString(),
        'limit': limit.toString(),
        'offset': offset.toString(),
      }),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch promotions");
    }

    final data = jsonDecode(response.body);
    print("fetchPromotions resp body: $data");
    return (data['data']['promotions'] as List)
        .map((e) => Promotion.fromJson(e))
        .toList();
  }

  @override
  Future<PromotionDetails> fetchPromotionDetails({
    required String token,
    required List<int> promotionIds,
  }) async {
    await _rateLimit(); // Применяем ограничение скорости запросов
    print("fetchPromotionDetails");
    final response = await http.get(
      Uri.parse("$baseUrl/promotions/details").replace(queryParameters: {
        'promotionIDs': promotionIds.map((e) => e.toString()).toList(),
      }),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch promotion details");
    }

    final data = jsonDecode(response.body);
    return PromotionDetails.fromJson(data['data']['promotions'][0]);
  }

  @override
  Future<List<PromotionNomenclature>> fetchPromotionNomenclatures({
    required String token,
    required int promotionId,
    required bool inAction,
    int limit = 10,
    int offset = 0,
  }) async {
    await _rateLimit(); // Применяем ограничение скорости запросов

    final uri = Uri.parse("$baseUrl/promotions/nomenclatures").replace(
      queryParameters: {
        'promotionID': promotionId.toString(),
        'inAction': inAction ? 'true' : 'false',
        'limit': limit.toString(),
        'offset': offset.toString(),
      },
    );
    print("Request URI: $uri");

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token', // Тот же заголовок авторизации
        'Content-Type': 'application/json',
      },
    );

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch promotion nomenclatures");
    }

    final data = jsonDecode(response.body);

    if (data['data'] == null || data['data']['nomenclatures'] == null) {
      throw Exception("Malformed response: missing nomenclatures data");
    }

    return (data['data']['nomenclatures'] as List)
        .map((json) => PromotionNomenclature.fromJson(json))
        .toList();
  }
}
