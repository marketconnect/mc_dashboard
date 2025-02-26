import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mc_dashboard/.env.dart';
import 'package:mc_dashboard/domain/entities/lemmatize.dart';

class CacheEntry<T> {
  final T data;
  final DateTime expiration;

  CacheEntry({required this.data, required this.expiration});
}

class LemmatizeApiClient {
  final String baseUrl;
  final Map<String, CacheEntry<LemmatizeResponse>> _cache = {};

  LemmatizeApiClient({String? baseUrl})
      : baseUrl = baseUrl ?? ApiSettings.stemUrl;

  Future<LemmatizeResponse> lemmatize(LemmatizeRequest request) async {
    final cacheKey = 'lemmatize-${request.toJson()}';
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    if (_cache.containsKey(cacheKey) &&
        _cache[cacheKey]!.expiration.isAfter(now)) {
      return _cache[cacheKey]!.data;
    }

    final uri = Uri.parse('$baseUrl/lemmatize');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      final result = LemmatizeResponse.fromJson(jsonData);
      _cache[cacheKey] = CacheEntry(data: result, expiration: endOfDay);
      return result;
    } else {
      throw Exception('Ошибка лемматизации, статус: ${response.statusCode}');
    }
  }
}
