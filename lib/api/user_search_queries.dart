import 'package:mc_dashboard/.env.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'user_search_queries.g.dart';

@RestApi(baseUrl: ApiSettings.baseUrl)
abstract class UserSearchQueriesApiClient {
  factory UserSearchQueriesApiClient(Dio dio, {String baseUrl}) =
      _UserSearchQueriesApiClient;

  @GET("/find_search_queries")
  Future<UserSearchQueriesResponse> findUserSearchQueries({
    @Header("Authorization") required String token,
    @Query("user_id") required int userId,
  });

  @POST("/save_search_queries")
  Future<SaveQueryResponse> saveUserSearchQuery({
    @Header("Authorization") required String token,
    @Body() required SaveQueryRequest request,
  });

  @DELETE("/delete_search_queries")
  Future<DeleteQueryResponse> deleteUserSearchQuery({
    @Header("Authorization") required String token,
    @Body() required DeleteQueryRequest request,
  });
}

// Request class for saving a search query
class SaveQueryRequest {
  final int userId;
  final String marketplaceType;
  final String query;

  SaveQueryRequest({
    required this.userId,
    required this.marketplaceType,
    required this.query,
  });

  factory SaveQueryRequest.fromJson(Map<String, dynamic> json) =>
      SaveQueryRequest(
        userId: json['user_id'] as int,
        marketplaceType: json['marketplace_type'] as String,
        query: json['query'] as String,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'marketplace_type': marketplaceType,
        'query': query,
      };
}

// Request class for deleting a search query
class DeleteQueryRequest {
  final int userId;
  final String query;

  DeleteQueryRequest({
    required this.userId,
    required this.query,
  });

  factory DeleteQueryRequest.fromJson(Map<String, dynamic> json) =>
      DeleteQueryRequest(
        userId: json['user_id'] as int,
        query: json['query'] as String,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'query': query,
      };
}

// Response class for fetching user search queries
class UserSearchQueriesResponse {
  final List<SearchQuery> queries;

  UserSearchQueriesResponse({
    required this.queries,
  });

  factory UserSearchQueriesResponse.fromJson(Map<String, dynamic> json) =>
      UserSearchQueriesResponse(
        queries: (json['queries'] as List<dynamic>)
            .map((item) => SearchQuery.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'queries': queries.map((query) => query.toJson()).toList(),
      };
}

// Response class for saving a search query
class SaveQueryResponse {
  final String message;
  final int queryId;

  SaveQueryResponse({
    required this.message,
    required this.queryId,
  });

  factory SaveQueryResponse.fromJson(Map<String, dynamic> json) =>
      SaveQueryResponse(
        message: json['message'] as String,
        queryId: json['query_id'] as int,
      );

  Map<String, dynamic> toJson() => {
        'message': message,
        'query_id': queryId,
      };
}

// Response class for deleting a search query
class DeleteQueryResponse {
  final String message;

  DeleteQueryResponse({
    required this.message,
  });

  factory DeleteQueryResponse.fromJson(Map<String, dynamic> json) =>
      DeleteQueryResponse(
        message: json['message'] as String,
      );

  Map<String, dynamic> toJson() => {
        'message': message,
      };
}

// Entity representing a search query
class SearchQuery {
  final int id;
  final String marketplaceType;
  final String query;

  SearchQuery({
    required this.id,
    required this.marketplaceType,
    required this.query,
  });

  factory SearchQuery.fromJson(Map<String, dynamic> json) => SearchQuery(
        id: json['id'] as int,
        marketplaceType: json['marketplace_type'] as String,
        query: json['query'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'marketplace_type': marketplaceType,
        'query': query,
      };
}
