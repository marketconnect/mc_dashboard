import 'dart:convert';
import 'package:http/http.dart' as http;

class UserSearchQueriesApiClient {
  final String baseUrl;

  UserSearchQueriesApiClient({required this.baseUrl});

  Future<UserSearchQueriesResponse> findUserSearchQueries({
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/user_search_queries');

    final response = await http.get(
      url,
      headers: {
        'Authorization': token,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return UserSearchQueriesResponse.fromJson(
          json.decode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to fetch search queries: ${response.body}');
    }
  }

  Future<void> saveUserSearchQueries({
    required String token,
    required SaveQueriesRequest request,
  }) async {
    final url = Uri.parse('$baseUrl/user_search_queries');

    final response = await http.post(
      url,
      headers: {
        'Authorization': token,
        'Content-Type': 'application/json',
      },
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Failed to save search queries: ${response.body}');
    }
  }

  Future<void> deleteUserSearchQueries({
    required String token,
    required DeleteQueriesRequest request,
  }) async {
    final url = Uri.parse('$baseUrl/user_search_queries');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': token,
        'Content-Type': 'application/json',
      },
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Failed to delete search queries: ${response.body}');
    }
  }
}

// Request class for saving user search queries
class SaveQueriesRequest {
  final List<SearchQuery> searchQueries;

  SaveQueriesRequest({
    required this.searchQueries,
  });

  Map<String, dynamic> toJson() => {
        'search_queries': searchQueries.map((query) => query.toJson()).toList(),
      };
}

// Request class for deleting user search queries
class DeleteQueriesRequest {
  final List<SearchQuery> searchQueries;

  DeleteQueriesRequest({
    required this.searchQueries,
  });

  Map<String, dynamic> toJson() => {
        'search_queries': searchQueries.map((query) => query.toJson()).toList(),
      };
}

// Response class for fetching user search queries
class UserSearchQueriesResponse {
  final List<SearchQuery> searchQueries;

  UserSearchQueriesResponse({required this.searchQueries});

  factory UserSearchQueriesResponse.fromJson(Map<String, dynamic> json) {
    return UserSearchQueriesResponse(
      searchQueries: (json['search_queries'] as List<dynamic>)
          .map((e) => SearchQuery.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// Entity representing a search query
class SearchQuery {
  final String query;
  final String marketplaceType;

  SearchQuery({
    required this.query,
    required this.marketplaceType,
  });

  factory SearchQuery.fromJson(Map<String, dynamic> json) {
    return SearchQuery(
      query: json['query'] as String,
      marketplaceType: json['marketplace_type'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'query': query,
        'marketplace_type': marketplaceType,
      };
}
