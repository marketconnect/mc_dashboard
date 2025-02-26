import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mc_dashboard/.env.dart';

class SubjectsSummaryApiClient {
  final String baseUrl;
  final Map<String, CacheEntry<List<RawJsonMap>>> _cache = {};

  SubjectsSummaryApiClient({String? baseUrl})
      : baseUrl = baseUrl ?? ApiSettings.baseUrl;

  Future<List<RawJsonMap>> getSubjectsSummaryAsDynamic({
    int? subjectId,
    String? subjectName,
    String? subjectParentName,
  }) async {
    final cacheKey =
        'subjects-summary-$subjectId-$subjectName-$subjectParentName';
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    if (_cache.containsKey(cacheKey) &&
        _cache[cacheKey]!.expiration.isAfter(now)) {
      return _cache[cacheKey]!.data;
    }

    final uri = Uri.parse('$baseUrl/subjects-summary').replace(
      queryParameters: {
        if (subjectId != null) 'subject_id': subjectId.toString(),
        if (subjectName != null) 'subject_name': subjectName,
        if (subjectParentName != null) 'subject_parent_name': subjectParentName,
      },
    );

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData =
          json.decode(utf8.decode(response.bodyBytes));
      final result = jsonData
          .map((e) => RawJsonMap.fromJson(e as Map<String, dynamic>))
          .toList();
      _cache[cacheKey] = CacheEntry(data: result, expiration: endOfDay);
      return result;
    } else {
      throw Exception(
          'Ошибка при загрузке subjects summary, статус: ${response.statusCode}');
    }
  }
}

class CacheEntry<T> {
  final T data;
  final DateTime expiration;

  CacheEntry({required this.data, required this.expiration});
}

/// Обёртка над Map<String, dynamic>
class RawJsonMap {
  final Map<String, dynamic> data;

  RawJsonMap(this.data);

  factory RawJsonMap.fromJson(Map<String, dynamic> json) {
    return RawJsonMap(Map<String, dynamic>.from(json));
  }
}
