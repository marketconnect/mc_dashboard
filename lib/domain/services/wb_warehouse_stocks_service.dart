import 'package:mc_dashboard/domain/entities/wb_warehouse_stock.dart';
import 'package:mc_dashboard/presentation/product_cards_screen/product_cards_view_model.dart';

// Interface for the API client
abstract class WbWarehouseStocksServiceApiClient {
  Future<List<WbSellerStock>> fetchStocks({
    required String token,
    required int warehouseId,
    required List<String> skus,
  });
}

// Interface for the token repository
abstract class WbWarehouseStocksServiceWbTokenRepo {
  Future<String?> getWbToken();
}

class WbWarehouseStocksService implements ProductCardsWbWarehouseStocksService {
  final WbWarehouseStocksServiceApiClient apiClient;
  final WbWarehouseStocksServiceWbTokenRepo wbTokenRepo;
  final Map<String, List<WbSellerStock>> _cachedStocks = {};

  WbWarehouseStocksService({
    required this.apiClient,
    required this.wbTokenRepo,
  });

  @override
  Future<List<WbSellerStock>> fetchSellerStocks({
    required int warehouseId,
    required List<String> skus,
  }) async {
    final cacheKey = '$warehouseId-${skus.join(",")}';
    // Debug print

    if (_cachedStocks.containsKey(cacheKey)) {
      // Debug print
      return _cachedStocks[cacheKey]!;
    }

    final token = await wbTokenRepo.getWbToken();
    if (token == null) {
      throw Exception("WB token is not set");
    }

    final stocks = await apiClient.fetchStocks(
      token: token,
      warehouseId: warehouseId,
      skus: skus,
    );

    // Debug print
    _cachedStocks[cacheKey] = stocks;
    return stocks;
  }
}
