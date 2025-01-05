import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';

import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';

import 'package:mc_dashboard/domain/entities/token_info.dart';

import 'package:mc_dashboard/presentation/login_screen/login_view_model.dart';
import 'package:mc_dashboard/presentation/mailing_screen/mailing_view_model.dart';
import 'package:mc_dashboard/presentation/product_screen/product_view_model.dart';
import 'package:mc_dashboard/presentation/seo_requests_extend_screen/seo_requests_extend_view_model.dart';
import 'package:mc_dashboard/presentation/subject_products_screen/subject_products_view_model.dart';
import 'package:mc_dashboard/presentation/subscription_screen/subscription_view_model.dart';

abstract class AuthServiceAuthApiClient {
  Future<Either<AppErrorBase, String>> register(
      String username, String password);
  Future<Either<AppErrorBase, String>> login(String username, String password);
}

abstract class AuthServiceStorage {
  Either<AppErrorBase, void> saveToken(String token);
  Either<AppErrorBase, String?> getToken();
  Either<AppErrorBase, void> clearToken();
}

class AuthService
    implements
        LoginViewModelAuthService,
        // ChoosingNicheAuthService,
        SubscriptionAuthService,
        MailingAuthService,
        SeoRequestsExtendAuthService,
        SubjectProductsAuthService,
        ProductAuthService {
  final AuthServiceAuthApiClient apiClient;
  final AuthServiceStorage authServiceStorage;

  const AuthService(
      {required this.apiClient, required this.authServiceStorage});

  @override
  Future<Either<AppErrorBase, void>> register() async {
    final user = getFirebaseAuthUserInfo();
    if (user == null) {
      return left(AppErrorBase('User is null',
          name: 'register', sendTo: true, source: 'AuthService'));
    }
    final tokenEither = await apiClient.register(user.email!, user.uid);
    return tokenEither.fold(
      (error) => left(error),
      (token) => authServiceStorage.saveToken(token),
    );
  }

  @override
  Future<Either<AppErrorBase, void>> login() async {
    final user = getFirebaseAuthUserInfo();
    if (user == null) {
      return left(AppErrorBase('User is null',
          name: 'login', sendTo: true, source: 'AuthService'));
    }
    final tokenEither = await apiClient.login(user.email!, user.uid);
    return tokenEither.fold(
      (error) => left(error),
      (token) => authServiceStorage.saveToken(token),
    );
  }

  // Check if token is expired
  bool isTokenExpired(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return true;

    final payload = json
        .decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
    final exp = payload['exp'] as int?;
    if (exp == null) return true;

    final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    return now >= exp;
  }

  // Get token and its type for use in the application
  @override
  Future<Either<AppErrorBase, TokenInfo>> getTokenInfo() async {
    // get token from storage
    final tokenEither = authServiceStorage.getToken();

    final token = tokenEither.fold((l) => null, (r) => r);
    // Token is not expired
    if (token != null && !isTokenExpired(token)) {
      final payload = getPayload(token);
      final userId = getUserId(payload);
      final userType = getTokenType(payload);
      final endDate = getEndDate(payload);
      if (userId == null || userType == null || endDate == null) {
        return left(AppErrorBase(
            'Не удалось получить информацию о пользователе',
            name: 'getTokenAndType',
            sendTo: true,
            source: 'AuthService'));
      }
      return right(TokenInfo(
          token: token, userId: userId, type: userType, endDate: endDate));
    }

    // Token is expired
    // step 1 login
    await login();

    // step 2 try again
    final newTokenEither = authServiceStorage.getToken();
    final newToken = newTokenEither.fold((l) => null, (r) => r);
    if (newToken != null) {
      final newPayload = getPayload(newToken);
      final newuserId = getUserId(newPayload);
      final newUserType = getTokenType(newPayload);
      final newEndDate = getEndDate(newPayload);
      // final userId = getUserId(newToken);
      // final userType = getTokenType(newToken);
      if (newuserId == null || newUserType == null || newEndDate == null) {
        return left(AppErrorBase(
            'Не удалось получить информацию о пользователе',
            name: 'getTokenAndType',
            sendTo: true,
            source: 'AuthService'));
      }
      return right(TokenInfo(
          token: newToken,
          userId: newuserId,
          type: newUserType,
          endDate: newEndDate));
    } else {
      return left(AppErrorBase('Token not found in storage',
          name: 'getTokenAndType', sendTo: true, source: 'AuthService'));
    }
  }

  // Clear token from storage
  @override
  Future<Either<AppErrorBase, void>> logout() async {
    await FirebaseAuth.instance.signOut();
    return authServiceStorage.clearToken();
  }

  @override
  User? getFirebaseAuthUserInfo() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      return user;
    } else {
      return null;
    }
  }

  dynamic getPayload(String token) {
    try {
      // Separate token into 3 parts: Header, Payload, Signature
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Decode the payload
      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );

      return payload;
    } catch (e) {
      return null;
    }
  }

  int? getUserId(dynamic payload) {
    try {
      // Extract userId
      final userId = payload['userId'];
      if (userId is int) {
        return userId;
      } else if (userId is String) {
        return int.tryParse(
            userId); // If userId is a string, try to parse it as an int
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  String? getEndDate(dynamic payload) {
    try {
      // Extract endDate
      final endDate = payload['endDate'];
      if (endDate is String) {
        return endDate;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get token type (free or premium)
  String? getTokenType(dynamic payload) {
    try {
      final scopes = payload['scopes'] as int? ?? 0;

      if ((scopes & 0x002) == 0x002) return "premium";
      if ((scopes & 0x001) == 0x001) return "free";
      return null;
    } catch (e) {
      return null;
    }
  }

  String simpleEncrypt(String email, String date) {
    final data = "$email|$date";

    String encoded = base64UrlEncode(utf8.encode(data));

    encoded = encoded.replaceAll('=', '');

    return encoded;
  }
}
