import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/.env.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/domain/services/auth_service.dart';
import 'package:http/http.dart' as http;

class AuthApiClient implements AuthServiceAuthApiClient {
  const AuthApiClient();
  static const baseUrl = McAuthService.baseUrl;

  @override
  Future<Either<AppErrorBase, String>> register(
      String username, String password) async {
    try {
      final url = Uri.parse('$baseUrl/register');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final token = body['token'] as String?;
        if (token == null) {
          return left(AppErrorBase('Token not found in response',
              name: 'register', sendTo: true, source: 'AuthApiClient'));
        }
        return right(token);
      } else {
        return left(AppErrorBase('Status code: ${response.statusCode}',
            name: 'register', sendTo: true, source: 'AuthApiClient'));
      }
    } catch (e) {
      return left(AppErrorBase('Caught error: $e',
          name: 'register', sendTo: true, source: 'AuthApiClient'));
    }
  }

  @override
  Future<Either<AppErrorBase, String>> login(
      String username, String password) async {
    try {
      final url = Uri.parse('$baseUrl/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final token = body['token'] as String?;
        if (token == null) {
          return left(AppErrorBase('Token not found in response',
              name: 'login', sendTo: true, source: 'AuthApiClient'));
        }
        return right(token);
      } else {
        return left(AppErrorBase('Status code: ${response.statusCode}',
            name: 'login', sendTo: true, source: 'AuthApiClient'));
      }
    } catch (e) {
      return left(AppErrorBase('Caught error: $e',
          name: 'login', sendTo: true, source: 'AuthApiClient'));
    }
  }
}
