import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:mc_dashboard/.env.dart';
import 'package:mc_dashboard/domain/services/user_emails_service.dart';

class UserEmailsApiClient implements UserEmailsServiceApiClient {
  final String baseUrl = ApiSettings.subsUrl;

  const UserEmailsApiClient();

  @override
  Future<UserEmailsResponse> findUserEmails({required String token}) async {
    final url = Uri.parse('$baseUrl/user_emails');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        return UserEmailsResponse(emails: []);
      }
      return UserEmailsResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch emails: ${response.body}');
    }
  }

  @override
  Future<void> saveUserEmails(
      {required String token, required SaveEmailsRequest request}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user_emails'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Failed to save emails: ${response.body}');
    }
  }

  @override
  Future<void> deleteUserEmails(
      {required String token, required DeleteEmailsRequest request}) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/user_emails'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Failed to delete emails: ${response.body}');
    }
  }
}

// Request class for saving user emails
class SaveEmailsRequest {
  final List<String> emails;

  SaveEmailsRequest({
    required this.emails,
  });

  factory SaveEmailsRequest.fromJson(Map<String, dynamic> json) =>
      SaveEmailsRequest(
        emails: (json['emails'] as List<dynamic>).cast<String>(),
      );

  Map<String, dynamic> toJson() => {
        'emails': emails,
      };
}

// Request class for deleting user emails
class DeleteEmailsRequest {
  final List<String> emails;

  DeleteEmailsRequest({
    required this.emails,
  });

  factory DeleteEmailsRequest.fromJson(Map<String, dynamic> json) =>
      DeleteEmailsRequest(
        emails: (json['emails'] as List<dynamic>).cast<String>(),
      );

  Map<String, dynamic> toJson() => {
        'emails': emails,
      };
}

// Response class for fetching user emails
class UserEmailsResponse {
  final List<String> emails;

  UserEmailsResponse({
    required this.emails,
  });

  factory UserEmailsResponse.fromJson(Map<String, dynamic> json) {
    if (json['emails'] == null || json['emails'] == '') {
      return UserEmailsResponse(emails: []);
    }
    return UserEmailsResponse(
      emails: (json['emails'] as List<dynamic>)
          .map((item) => item as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'emails': emails,
      };
}
