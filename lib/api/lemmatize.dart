import 'package:mc_dashboard/.env.dart';
import 'package:mc_dashboard/domain/entities/lemmatize.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'lemmatize.g.dart';

@RestApi(baseUrl: ApiSettings.stemUrl)
abstract class LemmatizeApiClient {
  factory LemmatizeApiClient(Dio dio, {String baseUrl}) = _LemmatizeApiClient;

  @POST("/lemmatize")
  Future<LemmatizeResponse> lemmatize(@Body() LemmatizeRequest request);
}
