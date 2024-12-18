import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/presentation/login_screen/login_view_model.dart';

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

class AuthService implements LoginViewModelAuthService {
  final AuthServiceAuthApiClient apiClient;
  final AuthServiceStorage authServiceStorage;

  const AuthService(
      {required this.apiClient, required this.authServiceStorage});

  @override
  Future<Either<AppErrorBase, void>> register(
      String username, String password) async {
    final tokenEither = await apiClient.register(username, password);
    return tokenEither.fold(
      (error) => left(error),
      (token) => authServiceStorage.saveToken(token),
    );
  }

  @override
  Future<Either<AppErrorBase, void>> login(
      String username, String password) async {
    final tokenEither = await apiClient.login(username, password);
    return tokenEither.fold(
      (error) => left(error),
      (token) => authServiceStorage.saveToken(token),
    );
  }
}
