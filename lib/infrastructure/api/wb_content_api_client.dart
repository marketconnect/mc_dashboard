// lib/infrastructure/api/charcs_api_client.dart

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:mc_dashboard/.env.dart';
import 'package:mc_dashboard/domain/entities/charc.dart';
import 'package:mc_dashboard/domain/entities/product_card.dart';
import 'package:mc_dashboard/domain/services/wb_api_content_service.dart';

class WbContentApiClient implements WbContentApiServiceApiClient {
  const WbContentApiClient();

  static const baseUrl = WbApi.contentBaseUrl;
  @override
  Future<List<ProductCard>> fetchProductCards({
    required String token,
    required int nmID,
    int limit = 100,
  }) async {
    final url = Uri.parse('$baseUrl/content/v2/get/cards/list');

    final Map<String, dynamic> requestBody = {
      "settings": {
        "sort": {"ascending": false},
        "filter": {
          "textSearch": "",
          "allowedCategoriesOnly": true,
          "tagIDs": [],
          "objectIDs": [],
          "brands": [],
          "imtID": nmID,
          "withPhoto": 1 // Всегда берем только карточки с фото
        },
        "cursor": {
          "limit": limit,
        }
      }
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
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> cardsJson = jsonResponse['cards'] ?? [];
        return cardsJson.map((json) => ProductCard.fromJson(json)).toList();
      } else {
        throw Exception(
            'Ошибка получения списка карточек: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Ошибка сети при получении списка карточек: $e');
    }
  }

  @override
  Future<List<ProductCard>> fetchAllProductCards(
      {required String token}) async {
    final url = Uri.parse('$baseUrl/content/v2/get/cards/list');
    List<ProductCard> allCards = [];
    String? lastUpdatedAt;
    int? lastNmID;
    const int limit = 100;

    while (true) {
      final Map<String, dynamic> requestBody = {
        "settings": {
          "sort": {"ascending": false},
          "filter": {
            "textSearch": "",
            "allowedCategoriesOnly": true,
            "tagIDs": [],
            "objectIDs": [],
            "brands": [],
            "imtID": 0,
            "withPhoto": 1 // Берем только карточки с фото
          },
          "cursor": {
            "limit": limit,
            if (lastUpdatedAt != null) "updatedAt": lastUpdatedAt,
            if (lastNmID != null) "nmID": lastNmID,
          }
        }
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
          final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

          // Получаем карточки
          final List<dynamic> cardsJson = jsonResponse['cards'] ?? [];
          List<ProductCard> batchCards =
              cardsJson.map((json) => ProductCard.fromJson(json)).toList();
          allCards.addAll(batchCards);

          // Обновляем параметры курсора
          final cursor = jsonResponse['cursor'];
          if (cursor == null ||
              (cursor['total'] != null && cursor['total'] < limit)) {
            break; // Данные закончились
          }

          lastUpdatedAt = cursor['updatedAt'];
          lastNmID = cursor['nmID'];
        } else {
          throw Exception(
              'Ошибка получения списка карточек: ${response.statusCode} ${response.body}');
        }
      } catch (e) {
        throw Exception('Ошибка сети при получении списка карточек: $e');
      }
    }

    return allCards;
  }

  @override
  Future<Map<String, dynamic>> uploadProductCards({
    required String token,
    required List<Map<String, dynamic>> productData,
  }) async {
    final url = Uri.parse('$baseUrl/content/v2/cards/upload');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: jsonEncode(productData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception(
            'Ошибка при создании карточек товаров: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Ошибка сети: $e');
    }
  }

  @override
  Future<List<Charc>> fetchCharcs(
      {required String token, required int subjectId}) async {
    try {
      final url = Uri.parse('$baseUrl/content/v2/object/charcs/$subjectId');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        // utf8.decode(response.bodyBytes)
        final Map<String, dynamic> jsonResponse =
            jsonDecode(utf8.decode(response.bodyBytes));

        if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
          final List<dynamic> data = jsonResponse['data'];
          return data
              .map((json) => Charc.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('Unexpected response format: missing "data" key');
        }
      } else {
        throw Exception(
            'Failed to fetch characteristics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Caught error: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> uploadMediaFile({
    required String token,
    required String nmId,
    required int photoNumber,
    required Uint8List mediaFile,
  }) async {
    final url = Uri.parse('$baseUrl/content/v3/media/file');

    try {
      var request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = token
        ..headers['X-Nm-Id'] = nmId
        ..headers['X-Photo-Number'] = photoNumber.toString()
        ..files.add(http.MultipartFile.fromBytes('uploadfile', mediaFile));

      final response = await request.send();

      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return jsonDecode(responseBody);
      } else {
        throw Exception(
            'Failed to upload media file: ${response.statusCode}, Response: $responseBody');
      }
    } catch (e) {
      throw Exception('Caught error: $e');
    }
  }
}
