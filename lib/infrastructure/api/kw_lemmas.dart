import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mc_dashboard/.env.dart';
import 'package:mc_dashboard/domain/entities/kw_lemmas.dart';

class KwLemmasApiClient {
  final String baseUrl;
  // Простой in-memory кеш, где ключ — строка, составленная из списка ids, а значение — кэшированное значение с датой истечения
  final Map<String, CacheEntry<KwLemmasResponse>> _cache = {};

  KwLemmasApiClient({String? baseUrl})
      : baseUrl = baseUrl ?? ApiSettings.baseUrl;

  Future<KwLemmasResponse> getKwLemmas({required List<int> ids}) async {
    final cacheKey = ids.join(',');
    // Проверяем, есть ли данные в кеше и не просрочены ли они (например, срок жизни кеша 1 час)
    if (_cache.containsKey(cacheKey)) {
      final entry = _cache[cacheKey]!;
      if (DateTime.now().isBefore(entry.expiration)) {
        return entry.data;
      }
    }

    final uri = Uri.parse('$baseUrl/kw_lemmas').replace(queryParameters: {
      'ids': ids.join(','),
    });

    final response =
        await http.get(uri, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      final result = KwLemmasResponse.fromJson(jsonData);

      final now = DateTime.now();
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
      _cache[cacheKey] = CacheEntry(
        data: result,
        expiration: endOfDay,
      );

      return result;
    } else {
      throw Exception(
          'Ошибка получения kw_lemmas, статус: ${response.statusCode}');
    }
  }
}

class CacheEntry<T> {
  final T data;
  final DateTime expiration;

  CacheEntry({required this.data, required this.expiration});
}

class KwLemmasResponse {
  final List<KwLemmaItem> kwLemmas;

  KwLemmasResponse({required this.kwLemmas});

  factory KwLemmasResponse.fromJson(Map<String, dynamic> json) {
    return KwLemmasResponse(
      kwLemmas: (json['kw_lemmas'] as List<dynamic>)
          .map((item) => KwLemmaItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kw_lemmas': kwLemmas.map((item) => item.toJson()).toList(),
    };
  }
}
