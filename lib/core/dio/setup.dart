import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:mc_dashboard/core/dio/dio_logger.dart';

Future<Dio> setupDio() async {
  final cacheStore = MemCacheStore(maxSize: 20971520, maxEntrySize: 2621440);

  final cacheOptions = CacheOptions(
    store: cacheStore,
    policy:
        CachePolicy.refresh, // ✅ Используем refresh (не берет ошибки из кэша)
    hitCacheOnErrorExcept: [
      400,
      404,
      401,
      403,
      500,
      504
    ], // ✅ Ошибки НЕ берутся из кэша
    keyBuilder: CacheOptions.defaultCacheKeyBuilder,
    maxStale: const Duration(days: 1), // Кэш живет 1 день
    priority: CachePriority.high,
    allowPostMethod: false,
  );

  final dio = Dio();
  dio.interceptors
      .add(DioCacheInterceptor(options: cacheOptions)); // ✅ Вернули кэш
  dio.interceptors.add(DioLoggingInterceptor());

  dio.options
    ..connectTimeout = const Duration(seconds: 120)
    ..receiveTimeout = const Duration(seconds: 120);

  return dio;
}
