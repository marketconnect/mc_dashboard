import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mc_dashboard/.env.dart';
import 'package:mc_dashboard/domain/services/user_sub_settings_service.dart';

class UserSettingsApiClient implements UserSubSettingsApiClient {
  final String baseUrl = ApiSettings.subsUrl;

  UserSettingsApiClient();

  @override
  Future<UserSettingsResponse> findUserSettings({
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
      return UserSettingsResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch user settings: ${response.body}');
    }
  }

  @override
  Future<void> saveUserSettings({
    required String token,
    required SaveSettingsRequest request,
  }) async {
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
    required DeleteSettingsRequest request,
  }) async {
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

  factory UserSettingsResponse.fromJson(Map<String, dynamic> json) =>
      UserSettingsResponse(
        settings: (json['settings'] as List<dynamic>)
            .map((item) => Setting.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}

class Setting {
  final String key;
  final String value;

  Setting({
    required this.key,
    required this.value,
  });

  factory Setting.fromJson(Map<String, dynamic> json) => Setting(
        key: json['key'] as String,
        value: json['value'] as String,
      );

  Map<String, dynamic> toJson() => {
        'key': key,
        'value': value,
      };
}
