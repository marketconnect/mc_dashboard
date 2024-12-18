// import 'dart:html' as html;

// import 'package:fpdart/fpdart.dart';
// import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
// import 'package:mc_dashboard/domain/services/auth_service.dart';

// class CookiesRepo implements AuthServiceStorage {
//   const CookiesRepo();
//   @override
//   Either<AppErrorBase, void> saveToken(String token) {
//     try {
//       final cookie = 'access_token=$token; path=/; max-age=2592000'; // 30 дней
//       html.document.cookie = cookie;
//       return right(null);
//     } catch (e) {
//       return left(AppErrorBase('Catched err: $e',
//           name: 'saveTokenToCookies', sendTo: true, source: 'CookiesRepo'));
//     }
//   }

//   /// Получение токена из cookies
//   @override
//   Either<AppErrorBase, String?> getToken() {
//     try {
//       final cookies = html.document.cookie?.split('; ') ?? [];
//       for (final cookie in cookies) {
//         if (cookie.startsWith('access_token=')) {
//           return right(cookie.substring('access_token='.length));
//         }
//       }
//       return right(null);
//     } catch (e) {
//       return left(AppErrorBase('Catched err: $e',
//           name: 'getTokenFromCookies', sendTo: true, source: 'CookiesRepo'));
//     }
//   }

//   static String? getTokenFromCookiesStatic() {
//     try {
//       final cookies = html.document.cookie?.split('; ') ?? [];
//       for (final cookie in cookies) {
//         if (cookie.startsWith('access_token=')) {
//           return cookie.substring('access_token='.length);
//         }
//       }
//       return null;
//     } catch (e) {
//       return null;
//     }
//   }

//   /// Очистка токена из cookies
//   @override
//   Either<AppErrorBase, void> clearToken() {
//     try {
//       html.document.cookie = 'access_token=; path=/; max-age=0';
//       return right(null);
//     } catch (e) {
//       return left(AppErrorBase('Catched err: $e',
//           name: 'getTokenFromCookies', sendTo: true, source: 'CookiesRepo'));
//     }
//   }
// }
