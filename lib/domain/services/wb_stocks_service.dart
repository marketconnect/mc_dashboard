import 'package:mc_dashboard/presentation/product_cards_screen/product_cards_view_model.dart';

import '../entities/wb_stock.dart';

abstract class WbStocksServiceApiClient {
  Future<List<WbStock>> fetchStocks({
    required String token,
    required String dateFrom,
  });
}

abstract class WbStocksServiceWbTokenRepo {
  Future<String?> getWbToken();
}

class WbStocksService implements ProductCardsWbStocksService {
  final WbStocksServiceApiClient apiClient;
  final WbStocksServiceWbTokenRepo wbTokenRepo;

  const WbStocksService({
    required this.apiClient,
    required this.wbTokenRepo,
  });

  @override
  Future<List<WbStock>> fetchStocks(String dateFrom) async {
    final token = await wbTokenRepo.getWbToken();
    if (token == null) {
      throw Exception("WB token is not set");
    }

    return await apiClient.fetchStocks(
      token: token,
      dateFrom: dateFrom,
    );
  }
}
