import 'package:dio/dio.dart';

class DioLoggingInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final isFromCache = response.extra['@fromNetwork@'] == false;
    if (isFromCache) {
      // ignore: avoid_print
      print("Cache Log: data from cache.");
    } else {
      // ignore: avoid_print
      print("Cache Log: data from api.");
    }
    super.onResponse(response, handler);
  }
}
