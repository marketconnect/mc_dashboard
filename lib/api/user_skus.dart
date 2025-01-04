import 'package:mc_dashboard/.env.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'user_skus.g.dart';

@RestApi(baseUrl: ApiSettings.baseUrl)
abstract class UserSkusApiClient {
  factory UserSkusApiClient(Dio dio, {String baseUrl}) = _UserSkusApiClient;

  @GET("/find_skus")
  Future<UserSkusResponse> findUserSkus({
    @Header("Authorization") required String token,
    @Query("user_id") required int userId,
  });

  @POST("/save_sku")
  Future<SaveSkuResponse> saveUserSku({
    @Header("Authorization") required String token,
    @Body() required SaveSkuRequest request,
  });

  @DELETE("/delete_sku")
  Future<DeleteSkuResponse> deleteUserSku({
    @Header("Authorization") required String token,
    @Body() required DeleteSkuRequest request,
  });
}

// Request class for saving a SKU
class SaveSkuRequest {
  final int userId;
  final String sku;
  final String marketplaceType;

  SaveSkuRequest({
    required this.userId,
    required this.sku,
    required this.marketplaceType,
  });

  factory SaveSkuRequest.fromJson(Map<String, dynamic> json) => SaveSkuRequest(
        userId: json['user_id'] as int,
        sku: json['sku'] as String,
        marketplaceType: json['marketplace_type'] as String,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'sku': sku,
        'marketplace_type': marketplaceType,
      };
}

// Request class for deleting a SKU
class DeleteSkuRequest {
  final int userId;
  final String sku;
  final String marketplaceType;

  DeleteSkuRequest({
    required this.userId,
    required this.sku,
    required this.marketplaceType,
  });

  factory DeleteSkuRequest.fromJson(Map<String, dynamic> json) =>
      DeleteSkuRequest(
        userId: json['user_id'] as int,
        sku: json['sku'] as String,
        marketplaceType: json['marketplace_type'] as String,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'sku': sku,
        'marketplace_type': marketplaceType,
      };
}

// Response class for fetching SKUs
class UserSkusResponse {
  final List<Map<String, String>> skus;

  UserSkusResponse({
    required this.skus,
  });

  factory UserSkusResponse.fromJson(Map<String, dynamic> json) =>
      UserSkusResponse(
        skus: (json['skus'] as List<dynamic>)
            .map((item) => Map<String, String>.from(item as Map))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'skus': skus,
      };
}

// Response class for saving a SKU
class SaveSkuResponse {
  final String message;
  final int skuId;

  SaveSkuResponse({
    required this.message,
    required this.skuId,
  });

  factory SaveSkuResponse.fromJson(Map<String, dynamic> json) =>
      SaveSkuResponse(
        message: json['message'] as String,
        skuId: json['sku_id'] as int,
      );

  Map<String, dynamic> toJson() => {
        'message': message,
        'sku_id': skuId,
      };
}

// Response class for deleting a SKU
class DeleteSkuResponse {
  final String message;

  DeleteSkuResponse({
    required this.message,
  });

  factory DeleteSkuResponse.fromJson(Map<String, dynamic> json) =>
      DeleteSkuResponse(
        message: json['message'] as String,
      );

  Map<String, dynamic> toJson() => {
        'message': message,
      };
}
