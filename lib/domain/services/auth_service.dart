import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/.env.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/core/utils/dates.dart';
import 'package:mc_dashboard/presentation/choosing_niche_screen/choosing_niche_view_model.dart';

import 'package:mc_dashboard/presentation/login_screen/login_view_model.dart';
import 'package:mc_dashboard/presentation/mailing_screen/mailing_view_model.dart';
import 'package:mc_dashboard/presentation/product_screen/product_view_model.dart';
import 'package:mc_dashboard/presentation/seo_requests_extend_screen/seo_requests_extend_view_model.dart';
import 'package:mc_dashboard/presentation/subject_products_screen/subject_products_view_model.dart';

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
        ChoosingNicheAuthService,
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

  // Get token type (free or premium)
  String? getTokenType(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = json
          .decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      final scopes = payload['scopes'] as int? ?? 0;

      if ((scopes & 0x002) == 0x002) return "premium";
      if ((scopes & 0x001) == 0x001) return "free";
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get token and its type for use in the application
  @override
  Future<Either<AppErrorBase, Map<String, String?>>> getTokenAndType() async {
    // get token from storage
    final tokenEither = authServiceStorage.getToken();

    final token = tokenEither.fold((l) => null, (r) => r);
    // Token is not expired
    if (token != null && !isTokenExpired(token)) {
      return right({'token': token, 'type': getTokenType(token)});
    }

    // Token is expired
    // step 1 login
    await login();

    // step 2 try again
    final newTokenEither = authServiceStorage.getToken();
    final newToken = newTokenEither.fold((l) => null, (r) => r);
    if (newToken != null) {
      return right({'token': newToken, 'type': getTokenType(newToken)});
    } else {
      return left(AppErrorBase('Token not found in storage',
          name: 'getTokenAndType', sendTo: true, source: 'AuthService'));
    }
  }

  // Clear token from storage
  @override
  Future<Either<AppErrorBase, void>> logout() async {
    return authServiceStorage.clearToken();
  }

  User? getFirebaseAuthUserInfo() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      return user;
    } else {
      return null;
    }
  }

  //
  @override
  String? getPaymentUrl() {
    final email = getFirebaseAuthUserInfo()?.email;

    if (email == null) {
      return null;
    }
    final endDate = DateTime.now().add(Duration(days: 30));
    final order = simpleEncrypt(
      email,
      endDate.toIso8601String().substring(0, 10),
    );
    final endDateStr = endDate.toIso8601String().substring(0, 10);
    return '${SiteSettings.paymentUrl}?amount=${PaymentSettings.amount}&order=$order&email=$email&description=Подписка на месяц до ${formatDate(endDateStr)}';
  }

  String simpleEncrypt(String email, String date) {
    final data = "$email|$date";

    String encoded = base64UrlEncode(utf8.encode(data));

    encoded = encoded.replaceAll('=', '');

    return encoded;
  }
}
