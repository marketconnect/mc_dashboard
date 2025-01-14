import 'package:mc_dashboard/.env.dart';
import 'package:mc_dashboard/domain/entities/product_item.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'products.g.dart';

@RestApi(baseUrl: ApiSettings.baseUrl)
abstract class ProductsApiClient {
  factory ProductsApiClient(Dio dio, {String baseUrl}) = _ProductsApiClient;

  @GET("/products")
  Future<ProductsResponse> getProducts({
    @Query("brand_id") int? brandId,
    @Query("subject_id") int? subjectId,
    @Query("supplier_id") int? supplierId,
    @Query("page") int? page,
    @Query("page_size") int? pageSize,
  });
}

class ProductsResponse {
  final Pagination pagination;
  final List<ProductItem> products;

  ProductsResponse({
    required this.pagination,
    required this.products,
  });

  factory ProductsResponse.fromJson(Map<String, dynamic> json) {
    return ProductsResponse(
      pagination: Pagination.fromJson(json['pagination']),
      products: (json['products'] as List<dynamic>)
          .map((item) => ProductItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pagination': pagination.toJson(),
      'products': products.map((product) => product.toJson()).toList(),
    };
  }
}

class Pagination {
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final int totalItems;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.totalItems,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'] as int,
      totalPages: json['total_pages'] as int,
      pageSize: json['page_size'] as int,
      totalItems: json['total_items'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'total_pages': totalPages,
      'page_size': pageSize,
      'total_items': totalItems,
    };
  }
}
