import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mc_dashboard/domain/entities/wb_stocks_report.dart';
import 'package:mc_dashboard/domain/services/wb_stocks_reports_service.dart';
import 'package:mc_dashboard/core/constants/wb_api.dart';

class WbStocksReportsApiClient implements WbStocksReportsServiceApiClient {
  const WbStocksReportsApiClient();

  static const baseUrl = WbApi.analyticsBaseUrl;

  @override
  Future<WbStocksReport> fetchStocksReport({
    required String token,
    List<int>? nmIDs,
    List<int>? subjectIDs,
    List<String>? brandNames,
    List<int>? tagIDs,
    required DateTime startDate,
    required DateTime endDate,
    String stockType = 'wb',
    required bool skipDeletedNm,
    required List<String> availabilityFilters,
    required String orderByField,
    required String orderByMode,
    int limit = 100,
    required int offset,
  }) async {
    final url = Uri.parse('$baseUrl/api/v2/stocks-report/products/groups');

    final Map<String, dynamic> requestBody = {
      if (nmIDs != null) 'nmIDs': nmIDs,
      if (subjectIDs != null) 'subjectIDs': subjectIDs,
      if (brandNames != null) 'brandNames': brandNames,
      if (tagIDs != null) 'tagIDs': tagIDs,
      'currentPeriod': {
        'start': startDate.toIso8601String().split('T')[0],
        'end': endDate.toIso8601String().split('T')[0],
      },
      'stockType': stockType,
      'skipDeletedNm': skipDeletedNm,
      'availabilityFilters': availabilityFilters,
      'orderBy': {
        'field': orderByField,
        'mode': orderByMode,
      },
      'limit': limit,
      'offset': offset,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final jsonData = jsonDecode(decodedBody);
        if (jsonData['data'] == null) {
          throw Exception('Response data is null');
        }
        return WbStocksReport.fromJson(jsonData['data']);
      } else {
        throw Exception(
          'Failed to fetch stocks report: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Network error while fetching stocks report: $e');
    }
  }
}
