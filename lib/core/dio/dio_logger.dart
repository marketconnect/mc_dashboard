import 'package:dio/dio.dart';

class DioLoggingInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final isFromCache = response.extra['@fromNetwork@'] == false;
    if (isFromCache) {
      print("Cache Log: Данные из кеша.");
    } else {
      print("Cache Log: Данные с API.");
    }
    super.onResponse(response, handler);
  }
}
