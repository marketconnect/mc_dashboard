import 'package:mc_dashboard/.env.dart';
import 'package:mc_dashboard/domain/entities/normquery.dart';
import 'package:mc_dashboard/domain/entities/normquery_product.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
part 'normqueries.g.dart';

@RestApi(baseUrl: ApiSettings.baseUrl)
abstract class NormqueriesApiClient {
  factory NormqueriesApiClient(Dio dio, {String baseUrl}) =
      _NormqueriesApiClient;

  @GET("/normqueries-products")
  Future<NormqueriesResponse> getNormqueriesProducts({
    @Query("ids") required List<int> ids,
  });

  @GET("/normqueries-unique")
  Future<UniqueNormqueriesResponse> getUniqueNormqueries({
    @Query("ids") required List<int> ids,
  });
}
// TODO Add token

class NormqueriesResponse {
  final List<NormqueryProduct> normqueriesWithProducts;

  NormqueriesResponse({
    required this.normqueriesWithProducts,
  });

  factory NormqueriesResponse.fromJson(Map<String, dynamic> json) {
    // Проверка, что поле `normquery_with_products` содержит список
    final products = json['normquery_with_products'];
    if (products is! List) {
      throw Exception(
          'Invalid format: "normquery_with_products" must be a List.');
    }

    // Преобразование списка объектов в `NormqueryProduct`
    return NormqueriesResponse(
      normqueriesWithProducts: products.map((item) {
        if (item is! Map<String, dynamic>) {
          throw Exception(
              'Invalid format: each item in "normquery_with_products" must be a Map<String, dynamic>.');
        }
        return NormqueryProduct.fromJson(item);
      }).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'normquery_with_products': normqueriesWithProducts
          .map((normqueryProduct) => normqueryProduct.toJson())
          .toList(),
    };
  }
}

class UniqueNormqueriesResponse {
  final List<Normquery> uniqueNormqueries;

  UniqueNormqueriesResponse({
    required this.uniqueNormqueries,
  });

  factory UniqueNormqueriesResponse.fromJson(Map<String, dynamic> json) {
    final queries = json['unique_normqueries'];
    if (queries is! List) {
      throw Exception('Invalid format: "unique_normqueries" must be a List.');
    }

    return UniqueNormqueriesResponse(
      uniqueNormqueries: queries.map((item) {
        if (item is! Map<String, dynamic>) {
          throw Exception(
              'Invalid format: each item in "unique_normqueries" must be a Map<String, dynamic>.');
        }
        return Normquery.fromJson(item);
      }).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unique_normqueries':
          uniqueNormqueries.map((normquery) => normquery.toJson()).toList(),
    };
  }
}
