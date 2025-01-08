import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mc_dashboard/.env.dart';

class UserSkusApiClient {
  final String baseUrl;

  UserSkusApiClient({this.baseUrl = McAuthService.baseUrl});

  Future<UserSkusResponse> findUserSkus({
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/user_skus');

    final response = await http.get(
      url,
      headers: {
        'Authorization': token,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return UserSkusResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch user SKUs: ${response.body}');
    }
  }

  Future<void> saveUserSkus({
    required String token,
    required SaveSkusRequest request,
  }) async {
    final url = Uri.parse('$baseUrl/user_skus');

    final response = await http.post(
      url,
      headers: {
        'Authorization': token,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Failed to save user SKUs: ${response.body}');
    }
  }

  Future<void> deleteUserSkus({
    required String token,
    required DeleteSkusRequest request,
  }) async {
    final url = Uri.parse('$baseUrl/user_skus');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': token,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Failed to delete user SKUs: ${response.body}');
    }
  }
}

// Request class for saving SKUs
class SaveSkusRequest {
  final List<Sku> skus;

  SaveSkusRequest({
    required this.skus,
  });

  Map<String, dynamic> toJson() => {
        'skus': skus.map((sku) => sku.toJson()).toList(),
      };
}

// Request class for deleting SKUs
class DeleteSkusRequest {
  final List<Sku> skus;

  DeleteSkusRequest({
    required this.skus,
  });

  Map<String, dynamic> toJson() => {
        'skus': skus.map((sku) => sku.toJson()).toList(),
      };
}

// Response class for fetching SKUs
class UserSkusResponse {
  final List<Sku> skus;

  UserSkusResponse({
    required this.skus,
  });

  factory UserSkusResponse.fromJson(Map<String, dynamic> json) =>
      UserSkusResponse(
        skus: (json['skus'] as List<dynamic>)
            .map((item) => Sku.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}

// Entity representing a SKU
class Sku {
  final String id;
  final String marketplaceType;

  Sku({
    required this.id,
    required this.marketplaceType,
  });

  factory Sku.fromJson(Map<String, dynamic> json) => Sku(
        id: json['id'] as String,
        marketplaceType: json['marketplace_type'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'marketplace_type': marketplaceType,
      };
}
