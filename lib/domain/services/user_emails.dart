import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/api/user_emails.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';

class UserEmailsService {
  final UserEmailsApiClient userEmailsApiClient;

  UserEmailsService({required this.userEmailsApiClient});

  Future<Either<AppErrorBase, List<String>>> fetchUserEmails({
    required String token,
    required int userId,
  }) async {
    try {
      final result = await userEmailsApiClient.getUserEmails(
        token: token,
        userId: userId,
      );
      return Right(result.emails);
    } on DioException catch (e, stackTrace) {
      final responseMessage = e.response?.data?['message'] ?? e.message;
      final error = AppErrorBase(
        'DioException: $responseMessage',
        name: 'fetchUserEmails',
        sendTo: true,
        source: 'UserEmailsService',
        args: ['userId: $userId'],
        stackTrace: stackTrace.toString(),
      );
      AppLogger.log(error);
      return Left(error);
    } catch (e, stackTrace) {
      final error = AppErrorBase(
        'Unexpected error: $e',
        name: 'fetchUserEmails',
        sendTo: true,
        source: 'UserEmailsService',
        args: ['userId: $userId'],
        stackTrace: stackTrace.toString(),
      );
      AppLogger.log(error);
      return Left(error);
    }
  }

  Future<Either<AppErrorBase, int>> saveUserEmail({
    required String token,
    required int userId,
    required String email,
  }) async {
    try {
      final result = await userEmailsApiClient.saveUserEmail(
        token: token,
        request: SaveEmailRequest(userId: userId, email: email),
      );
      return Right(result.emailId);
    } on DioException catch (e, stackTrace) {
      final responseMessage = e.response?.data?['message'] ?? e.message;
      final error = AppErrorBase(
        'DioException: $responseMessage',
        name: 'saveUserEmail',
        sendTo: true,
        source: 'UserEmailsService',
        args: ['userId: $userId', 'email: $email'],
        stackTrace: stackTrace.toString(),
      );
      AppLogger.log(error);
      return Left(error);
    } catch (e, stackTrace) {
      final error = AppErrorBase(
        'Unexpected error: $e',
        name: 'saveUserEmail',
        sendTo: true,
        source: 'UserEmailsService',
        args: ['userId: $userId', 'email: $email'],
        stackTrace: stackTrace.toString(),
      );
      AppLogger.log(error);
      return Left(error);
    }
  }

  Future<Either<AppErrorBase, String>> deleteUserEmail({
    required String token,
    required int userId,
    required String email,
  }) async {
    try {
      final result = await userEmailsApiClient.deleteUserEmail(
        token: token,
        request: DeleteEmailRequest(userId: userId, email: email),
      );
      return Right(result.message);
    } on DioException catch (e, stackTrace) {
      final responseMessage = e.response?.data?['message'] ?? e.message;
      final error = AppErrorBase(
        'DioException: $responseMessage',
        name: 'deleteUserEmail',
        sendTo: true,
        source: 'UserEmailsService',
        args: ['userId: $userId', 'email: $email'],
        stackTrace: stackTrace.toString(),
      );
      AppLogger.log(error);
      return Left(error);
    } catch (e, stackTrace) {
      final error = AppErrorBase(
        'Unexpected error: $e',
        name: 'deleteUserEmail',
        sendTo: true,
        source: 'UserEmailsService',
        args: ['userId: $userId', 'email: $email'],
        stackTrace: stackTrace.toString(),
      );
      AppLogger.log(error);
      return Left(error);
    }
  }
}
