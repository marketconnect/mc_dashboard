import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:mc_dashboard/.env.dart';

import 'package:mc_dashboard/domain/entities/sku.dart';
import 'package:mc_dashboard/domain/services/saved_products_service.dart';

class UserSkusApiClient implements SavedProductsApiClient {
  final String baseUrl = ApiSettings.subsUrl;

  UserSkusApiClient();

  @override
  Future<List<Sku>> findUserSkus({
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
      final resp = UserSkusResponse.fromJson(jsonDecode(response.body));
      List<Sku> productSkus = [];

      for (var product in resp.skus) {
        productSkus
            .add(Sku(id: product.id, marketplaceType: product.marketplaceType));
      }

      return productSkus;
    } else {
      throw Exception('Failed to fetch user SKUs: ${response.body}');
    }
  }

  @override
  Future<void> saveUserSkus({
    required String token,
    required List<Sku> skus,
  }) async {
    final request = SaveSkusRequest(skus: skus);
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

  @override
  Future<void> deleteUserSkus({
    required String token,
    required List<Sku> skus,
  }) async {
    final request = DeleteSkusRequest(skus: skus);
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

  factory UserSkusResponse.fromJson(Map<String, dynamic> json) {
    if (json['skus'] == null || json['skus'] == '') {
      return UserSkusResponse(skus: []);
    }
    return UserSkusResponse(
      skus: (json['skus'] as List<dynamic>)
          .map((item) => Sku.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

// Entity representing a SKU
