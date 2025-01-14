import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mc_dashboard/.env.dart';
import 'package:mc_dashboard/domain/entities/key_phrase.dart';
import 'package:mc_dashboard/domain/services/saved_key_phrases_service.dart';

class UserSearchQueriesApiClient implements SavedKeyPhrasesApiClient {
  final String baseUrl = ApiSettings.subsUrl;

  UserSearchQueriesApiClient();

  @override
  Future<List<KeyPhrase>> findUserSearchQueries({
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
      final data = UserSearchQueriesResponse.fromJson(
          json.decode(response.body) as Map<String, dynamic>);
      List<KeyPhrase> keyPhrases = [];

      for (var query in data.searchQueries) {
        keyPhrases.add(KeyPhrase(
          phraseText: query.query,
          marketPlace: query.marketplaceType,
        ));
      }

      return keyPhrases;
    } else {
      throw Exception('Failed to fetch search queries: ${response.body}');
    }
  }

  @override
  Future<void> saveUserSearchQueries({
    required String token,
    required List<KeyPhrase> phrases,
  }) async {
    final url = Uri.parse('$baseUrl/user_search_queries');

    final request = SaveQueriesRequest(
      searchQueries: phrases
          .map((phrase) => SearchQuery(
                query: phrase.phraseText,
                marketplaceType: phrase.marketPlace,
              ))
          .toList(),
    );

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

  @override
  Future<void> deleteUserSearchQueries({
    required String token,
    required List<KeyPhrase> phrases,
  }) async {
    final url = Uri.parse('$baseUrl/user_search_queries');

    final request = DeleteQueriesRequest(
      searchQueries: phrases
          .map((phrase) => SearchQuery(
                query: phrase.phraseText,
                marketplaceType: phrase.marketPlace,
              ))
          .toList(),
    );

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
    if (json['search_queries'] == null || json['search_queries'] == '') {
      return UserSearchQueriesResponse(searchQueries: []);
    }
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
