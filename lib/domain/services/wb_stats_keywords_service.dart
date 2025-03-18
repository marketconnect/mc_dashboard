import 'package:mc_dashboard/domain/entities/wb_stats_keywords.dart';
import 'package:mc_dashboard/presentation/wb_stats_keywords_screen/wb_stats_keywords_view_model.dart';

abstract class WbStatsKeywordsWbTokenRepo {
  Future<String?> getWbToken();
}

abstract class WbStatsKeywordsWbStatsKeywordsApiClient {
  Future<List<WbStatsKeywords>> getStatsKeywords({
    required String token,
    required int advertId,
    required String from,
    required String to,
  });
}

class WbStatsKeywordsService implements WbStatsKeywordsWbStatsKeywordsService {
  final WbStatsKeywordsWbStatsKeywordsApiClient apiClient;
  final WbStatsKeywordsWbTokenRepo wbTokenRepo;

  WbStatsKeywordsService({required this.apiClient, required this.wbTokenRepo});

  @override
  Future<List<WbStatsKeywords>> getStatsKeywords({
    required int advertId,
    required String from,
    required String to,
  }) async {
    final token = await wbTokenRepo.getWbToken();

    if (token == null) {
      throw Exception("Для получения данных нужно добавить токен Wildberries");
    }

    return await apiClient.getStatsKeywords(
      token: token,
      advertId: advertId,
      from: from,
      to: to,
    );
  }
}
