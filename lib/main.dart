import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/material.dart';
import 'package:mc_dashboard/di/di_container.dart';

import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

abstract class AppFactory {
  Widget makeApp();
}

final appFactory = makeAppFactory();

final cacheStore = HiveCacheStore(null);
final cacheOptions = CacheOptions(
  store: cacheStore,
  policy: CachePolicy.request, // Стандартная политика кеша
  hitCacheOnErrorExcept: [
    401,
    403
  ], // Кеш использовать при любых ошибках, кроме 401/403
  priority: CachePriority.normal, // Приоритет кеша
  maxStale: const Duration(days: 7), // Максимальный срок устаревания кеша
);
void main() {
  final app = appFactory.makeApp();
  runApp(app);
}
