import 'package:mc_dashboard/.env.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'user_settings.g.dart';

@RestApi(baseUrl: ApiSettings.baseUrl)
abstract class UserSettingsApiClient {
  factory UserSettingsApiClient(Dio dio, {String baseUrl}) =
      _UserSettingsApiClient;

  @GET("/find_settings")
  Future<UserSettingsResponse> findUserSettings({
    @Header("Authorization") required String token,
    @Query("user_id") required int userId,
  });

  @POST("/save_setting")
  Future<SaveSettingResponse> saveUserSetting({
    @Header("Authorization") required String token,
    @Body() required SaveSettingRequest request,
  });

  @DELETE("/delete_setting")
  Future<DeleteSettingResponse> deleteUserSetting({
    @Header("Authorization") required String token,
    @Body() required DeleteSettingRequest request,
  });
}

// Request class for saving a user setting
class SaveSettingRequest {
  final int userId;
  final String key;
  final String value;

  SaveSettingRequest({
    required this.userId,
    required this.key,
    required this.value,
  });

  factory SaveSettingRequest.fromJson(Map<String, dynamic> json) =>
      SaveSettingRequest(
        userId: json['user_id'] as int,
        key: json['key'] as String,
        value: json['value'] as String,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'key': key,
        'value': value,
      };
}

// Request class for deleting a user setting
class DeleteSettingRequest {
  final int userId;
  final String key;

  DeleteSettingRequest({
    required this.userId,
    required this.key,
  });

  factory DeleteSettingRequest.fromJson(Map<String, dynamic> json) =>
      DeleteSettingRequest(
        userId: json['user_id'] as int,
        key: json['key'] as String,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'key': key,
      };
}

// Response class for fetching user settings
class UserSettingsResponse {
  final List<UserSetting> settings;

  UserSettingsResponse({
    required this.settings,
  });

  factory UserSettingsResponse.fromJson(Map<String, dynamic> json) =>
      UserSettingsResponse(
        settings: (json['settings'] as List<dynamic>)
            .map((item) => UserSetting.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'settings': settings.map((setting) => setting.toJson()).toList(),
      };
}

// Response class for saving a user setting
class SaveSettingResponse {
  final String message;
  final int settingId;

  SaveSettingResponse({
    required this.message,
    required this.settingId,
  });

  factory SaveSettingResponse.fromJson(Map<String, dynamic> json) =>
      SaveSettingResponse(
        message: json['message'] as String,
        settingId: json['setting_id'] as int,
      );

  Map<String, dynamic> toJson() => {
        'message': message,
        'setting_id': settingId,
      };
}

// Response class for deleting a user setting
class DeleteSettingResponse {
  final String message;

  DeleteSettingResponse({
    required this.message,
  });

  factory DeleteSettingResponse.fromJson(Map<String, dynamic> json) =>
      DeleteSettingResponse(
        message: json['message'] as String,
      );

  Map<String, dynamic> toJson() => {
        'message': message,
      };
}

// Entity representing a user setting
class UserSetting {
  final String key;
  final String value;

  UserSetting({
    required this.key,
    required this.value,
  });

  factory UserSetting.fromJson(Map<String, dynamic> json) => UserSetting(
        key: json['key'] as String,
        value: json['value'] as String,
      );

  Map<String, dynamic> toJson() => {
        'key': key,
        'value': value,
      };
}
