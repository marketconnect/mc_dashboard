import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:mc_dashboard/.env.dart';
import 'package:mc_dashboard/domain/entities/mailing_settings.dart';
import 'package:mc_dashboard/domain/services/user_sub_settings_service.dart';

class UserSettingsApiClient implements UserSubSettingsApiClient {
  final String baseUrl = ApiSettings.subsUrl;

  UserSettingsApiClient();

  @override
  Future<List<Setting>> findUserSettings({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user_settings'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final resp = UserSettingsResponse.fromJson(json.decode(response.body));

      return resp.settings;
    } else {
      throw Exception('Failed to fetch user settings: ${response.body}');
    }
  }

  @override
  Future<void> saveUserSettings({
    required String token,
    required List<Setting> settings,
  }) async {
    final request = SaveSettingsRequest(settings: settings);
    final response = await http.post(
      Uri.parse('$baseUrl/user_settings'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Failed to save user settings: ${response.body}');
    }
  }

  @override
  Future<void> deleteUserSettings({
    required String token,
    required List<Setting> settings,
  }) async {
    final request = DeleteSettingsRequest(settings: settings);
    final response = await http.delete(
      Uri.parse('$baseUrl/user_settings'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Failed to delete user settings: ${response.body}');
    }
  }
}

class SaveSettingsRequest {
  final List<Setting> settings;

  SaveSettingsRequest({
    required this.settings,
  });

  Map<String, dynamic> toJson() => {
        'settings': settings.map((setting) => setting.toJson()).toList(),
      };
}

class DeleteSettingsRequest {
  final List<Setting> settings;

  DeleteSettingsRequest({
    required this.settings,
  });

  Map<String, dynamic> toJson() => {
        'settings': settings.map((setting) => setting.toJson()).toList(),
      };
}

class UserSettingsResponse {
  final List<Setting> settings;

  UserSettingsResponse({
    required this.settings,
  });

  factory UserSettingsResponse.fromJson(Map<String, dynamic> json) {
    if (json['settings'] == null || json['settings'] == '') {
      return UserSettingsResponse(settings: []);
    }
    return UserSettingsResponse(
      settings: (json['settings'] as List<dynamic>)
          .map((item) => Setting.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
