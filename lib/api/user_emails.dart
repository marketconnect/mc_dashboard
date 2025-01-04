import 'package:mc_dashboard/.env.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'user_emails.g.dart';

@RestApi(baseUrl: ApiSettings.baseUrl)
abstract class UserEmailsApiClient {
  factory UserEmailsApiClient(Dio dio, {String baseUrl}) = _UserEmailsApiClient;

  @GET("/find_emails")
  Future<UserEmailsResponse> findUserEmails({
    @Header("Authorization") required String token,
    @Query("user_id") required int userId,
  });

  @POST("/save_email")
  Future<SaveEmailResponse> saveUserEmail({
    @Header("Authorization") required String token,
    @Body() required SaveEmailRequest request,
  });

  @DELETE("/delete_email")
  Future<DeleteEmailResponse> deleteUserEmail({
    @Header("Authorization") required String token,
    @Body() required DeleteEmailRequest request,
  });
}

// Request class for saving an email
class SaveEmailRequest {
  final int userId;
  final String email;

  SaveEmailRequest({
    required this.userId,
    required this.email,
  });

  factory SaveEmailRequest.fromJson(Map<String, dynamic> json) =>
      SaveEmailRequest(
        userId: json['user_id'] as int,
        email: json['email'] as String,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'email': email,
      };
}

// Request class for deleting an email
class DeleteEmailRequest {
  final int userId;
  final String email;

  DeleteEmailRequest({
    required this.userId,
    required this.email,
  });

  factory DeleteEmailRequest.fromJson(Map<String, dynamic> json) =>
      DeleteEmailRequest(
        userId: json['user_id'] as int,
        email: json['email'] as String,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'email': email,
      };
}

// Response class for fetching user emails
class UserEmailsResponse {
  final List<String> emails;

  UserEmailsResponse({
    required this.emails,
  });

  factory UserEmailsResponse.fromJson(Map<String, dynamic> json) =>
      UserEmailsResponse(
        emails: (json['emails'] as List<dynamic>)
            .map((item) => item as String)
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'emails': emails,
      };
}

// Response class for saving an email
class SaveEmailResponse {
  final String message;
  final int emailId;

  SaveEmailResponse({
    required this.message,
    required this.emailId,
  });

  factory SaveEmailResponse.fromJson(Map<String, dynamic> json) =>
      SaveEmailResponse(
        message: json['message'] as String,
        emailId: json['email_id'] as int,
      );

  Map<String, dynamic> toJson() => {
        'message': message,
        'email_id': emailId,
      };
}

// Response class for deleting an email
class DeleteEmailResponse {
  final String message;

  DeleteEmailResponse({
    required this.message,
  });

  factory DeleteEmailResponse.fromJson(Map<String, dynamic> json) =>
      DeleteEmailResponse(
        message: json['message'] as String,
      );

  Map<String, dynamic> toJson() => {
        'message': message,
      };
}
