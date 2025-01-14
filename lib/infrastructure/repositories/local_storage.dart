import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/domain/services/auth_service.dart';
import 'package:web/web.dart' as web;

class LocalStorageRepo implements AuthServiceStorage {
  const LocalStorageRepo();

  @override
  Either<AppErrorBase, void> saveToken(String token) {
    try {
      web.window.localStorage.setItem('access_token', token);
      return right(null);
    } catch (e) {
      return left(AppErrorBase(
        'Caught error: $e',
        name: 'saveTokenToLocalStorage',
        sendTo: true,
        source: 'LocalStorageRepo',
      ));
    }
  }

  @override
  Either<AppErrorBase, String?> getToken() {
    try {
      final token = web.window.localStorage.getItem('access_token');
      return right(token);
    } catch (e) {
      return left(AppErrorBase(
        'Caught error: $e',
        name: 'getTokenFromLocalStorage',
        sendTo: true,
        source: 'LocalStorageRepo',
      ));
    }
  }

  @override
  Either<AppErrorBase, void> clearToken() {
    try {
      web.window.localStorage.removeItem('access_token');
      return right(null);
    } catch (e) {
      return left(AppErrorBase(
        'Caught error: $e',
        name: 'clearTokenFromLocalStorage',
        sendTo: true,
        source: 'LocalStorageRepo',
      ));
    }
  }

  static String? getTokenStatic() {
    try {
      final token = web.window.localStorage.getItem('access_token');
      return token;
    } catch (e) {
      return null;
    }
  }
}
