import 'package:mc_dashboard/domain/entities/wb_stocks_report.dart';
import 'package:mc_dashboard/presentation/product_cards_screen/product_cards_view_model.dart';

abstract class WbStocksReportsServiceApiClient {
  Future<WbStocksReport> fetchStocksReport({
    required String token,
    List<int>? nmIDs,
    List<int>? subjectIDs,
    List<String>? brandNames,
    List<int>? tagIDs,
    required DateTime startDate,
    required DateTime endDate,
    String stockType = 'wb',
    required bool skipDeletedNm,
    required List<String> availabilityFilters,
    required String orderByField,
    required String orderByMode,
    int limit = 100,
    required int offset,
  });
}

abstract class WbStocksReportsServiceWbTokenRepo {
  Future<String?> getWbToken();
}

class WbStocksReportsService implements ProductCardsWbStocksReportsService {
  final WbStocksReportsServiceApiClient apiClient;
  final WbStocksReportsServiceWbTokenRepo wbTokenRepo;

  WbStocksReportsService({
    required this.apiClient,
    required this.wbTokenRepo,
  });

  @override
  Future<WbStocksReport> fetchStocksReport({
    List<int>? nmIDs,
    List<int>? subjectIDs,
    List<String>? brandNames,
    List<int>? tagIDs,
    required DateTime startDate,
    required DateTime endDate,
    String? stockType,
    required bool skipDeletedNm,
    required List<String> availabilityFilters,
    required String orderByField,
    required String orderByMode,
    int limit = 100,
    required int offset,
  }) async {
    final token = await wbTokenRepo.getWbToken();
    if (token == null) {
      throw Exception("Для получения данных нужно добавить токен Wildberries");
    }

    return await apiClient.fetchStocksReport(
      token: token,
      nmIDs: nmIDs,
      subjectIDs: subjectIDs,
      brandNames: brandNames,
      tagIDs: tagIDs,
      startDate: startDate,
      endDate: endDate,
      stockType: 'wb',
      skipDeletedNm: skipDeletedNm,
      availabilityFilters: availabilityFilters,
      orderByField: orderByField,
      orderByMode: orderByMode,
      limit: limit,
      offset: offset,
    );
  }
}
