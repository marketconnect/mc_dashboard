import 'package:mc_dashboard/.env.dart';
import 'package:mc_dashboard/domain/entities/kw_lemmas.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'kw_lemmas.g.dart';

@RestApi(baseUrl: ApiSettings.baseUrl)
abstract class KwLemmasApiClient {
  factory KwLemmasApiClient(Dio dio, {String baseUrl}) = _KwLemmasApiClient;

  @GET("/kw_lemmas")
  Future<KwLemmasResponse> getKwLemmas({
    @Query("ids") required List<int> ids,
  });
}

class KwLemmasResponse {
  final List<KwLemmaItem> kwLemmas;

  KwLemmasResponse({required this.kwLemmas});

  factory KwLemmasResponse.fromJson(Map<String, dynamic> json) {
    return KwLemmasResponse(
      kwLemmas: (json['kw_lemmas'] as List<dynamic>)
          .map((item) => KwLemmaItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kw_lemmas': kwLemmas.map((item) => item.toJson()).toList(),
    };
  }
}
