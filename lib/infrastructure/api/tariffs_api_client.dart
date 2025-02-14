import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:mc_dashboard/domain/entities/tariff.dart';
import 'package:mc_dashboard/domain/entities/box_tariff.dart';
import 'package:mc_dashboard/domain/services/tariff_service.dart';

class TariffsApiClient implements TariffsServiceApiClient {
  static final TariffsApiClient instance = TariffsApiClient._internal();

  factory TariffsApiClient() {
    return instance;
  }

  TariffsApiClient._internal(
      {this.baseUrl = "https://common-api.wildberries.ru/api/v1/tariffs"});

  final String baseUrl;
  DateTime? _lastRequestTime;

  // Кеш теперь статический, не сбрасывается при пересоздании TariffsApiClient
  static final Map<String, Tuple2<String, List<Tariff>>> _tariffsCache = {};
  static final Map<String, Tuple2<String, List<BoxTariff>>> _boxTariffsCache =
      {};

  Future<void> _rateLimit() async {
    final now = DateTime.now();
    if (_lastRequestTime != null) {
      final diff = now.difference(_lastRequestTime!);
      if (diff < Duration(seconds: 5)) {
        await Future.delayed(Duration(seconds: 5) - diff);
      }
    }
    _lastRequestTime = now;
  }

  @override
  Future<List<Tariff>> fetchTariffs({
    required String token,
    String locale = "ru",
  }) async {
    final today = _currentDate();
    final cacheKey = "${_normalizeToken(token)}-$locale";

    if (_tariffsCache.containsKey(cacheKey) &&
        _tariffsCache[cacheKey]!.item1 == today) {
      print("✅ [CACHE] Returning tariffs from cache");
      return _tariffsCache[cacheKey]!.item2;
    }

    print("🔄 [API] Fetching tariffs...");
    await _rateLimit(); // Вызываем только если нет кеша

    final response = await http.get(
      Uri.parse("$baseUrl/commission")
          .replace(queryParameters: {'locale': locale}),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch tariffs");
    }

    final data = jsonDecode(response.body);
    final tariffs =
        (data['report'] as List).map((e) => Tariff.fromJson(e)).toList();

    // Кешируем ответ с датой
    _tariffsCache[cacheKey] = Tuple2(today, tariffs);

    print("✅ [API] Tariffs fetched and cached");
    return tariffs;
  }

  @override
  Future<List<BoxTariff>> fetchBoxTariffs({
    required String token,
    required String date,
  }) async {
    final cacheKey = "$token-$date";

    if (_boxTariffsCache.containsKey(cacheKey) &&
        _boxTariffsCache[cacheKey]!.item1 == date) {
      print("✅ [CACHE] Returning box tariffs from cache");
      return _boxTariffsCache[cacheKey]!.item2;
    }

    print("🔄 [API] Fetching box tariffs...");

    final response = await http.get(
      Uri.parse("$baseUrl/box").replace(queryParameters: {'date': date}),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
          "Failed to fetch box tariffs. Status: ${response.statusCode}");
    }

    // Проверяем кодировку ответа
    final contentType = response.headers['content-type'];
    if (contentType != null && contentType.contains("charset=windows-1251")) {
      // Сервер вернул Windows-1251, нужно перекодировать
      print("⚠️ Server returned Windows-1251 encoding. Converting...");
      final decodedBody = latin1.decode(response.bodyBytes);
      return _parseBoxTariffs(decodedBody);
    }

    // Если `UTF-8`, просто декодируем `bodyBytes`
    final decodedBody = utf8.decode(response.bodyBytes);
    return _parseBoxTariffs(decodedBody);
  }

  List<BoxTariff> _parseBoxTariffs(String responseBody) {
    final data = jsonDecode(responseBody);

    // Проверяем, что API вернул корректный JSON
    if (data['response'] == null ||
        data['response']['data'] == null ||
        data['response']['data']['warehouseList'] == null) {
      throw Exception("Invalid API response format");
    }

    final warehouseList = data['response']['data']['warehouseList'] as List;
    final boxTariffs = warehouseList.map((e) => BoxTariff.fromJson(e)).toList();

    return boxTariffs;
  }

  String _normalizeToken(String token) {
    return token.split('.')[0];
  }

  String _currentDate() {
    return DateTime.now().toIso8601String().split('T')[0];
  }
}

// Класс-обертка для кеша
class Tuple2<T1, T2> {
  final T1 item1;
  final T2 item2;
  Tuple2(this.item1, this.item2);
}
