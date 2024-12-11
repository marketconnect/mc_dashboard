import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:mc_dashboard/core/dio/dio_logger.dart';

Future<Dio> setupDio() async {
  final cacheStore = MemCacheStore(maxSize: 20971520, maxEntrySize: 2621440);
  final cacheOptions = CacheOptions(
    store: cacheStore,
    policy: CachePolicy.forceCache,
    hitCacheOnErrorExcept: [401, 403],
    maxStale: const Duration(days: 1),
  );

  final dio = Dio();
  dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));
  dio.interceptors.add(DioLoggingInterceptor());
  dio.options.connectTimeout = Duration(seconds: 5);
  dio.options.receiveTimeout = Duration(seconds: 3);

  return dio;
}
