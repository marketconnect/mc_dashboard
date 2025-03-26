import 'package:mc_dashboard/domain/entities/ozon_fbo_stock.dart';
import 'package:mc_dashboard/infrastructure/repositories/secure_token_storage_repo.dart';
import 'package:mc_dashboard/presentation/ozon_product_cards_screen/ozon_product_cards_view_model.dart';

abstract class OzonFboStocksServiceApiClient {
  Future<OzonFboStocksResponse> fetchStocks({
    required String apiKey,
    required String clientId,
    List<String>? skus,
    String? stockTypes,
    List<String>? warehouseIds,
    int? limit,
    int? offset,
  });
}

class OzonFboStocksService implements OzonProductCardsOzonFboStocksService {
  final OzonFboStocksServiceApiClient apiClient;
  final SecureTokenStorageRepo tokenRepo;

  // Cache for stocks response
  OzonFboStocksResponse? _cachedStocksResponse;
  DateTime? _lastCacheUpdate;
  static const _cacheExpirationDuration = Duration(minutes: 1);

  OzonFboStocksService({
    required this.apiClient,
    required this.tokenRepo,
  });

  @override
  Future<OzonFboStocksResponse> fetchStocks({
    List<String>? skus,
    String? stockTypes,
    List<String>? warehouseIds,
    int? limit,
    int? offset,
  }) async {
    // Check if cache is valid
    final now = DateTime.now();
    if (_cachedStocksResponse != null && _lastCacheUpdate != null) {
      final cacheAge = now.difference(_lastCacheUpdate!);
      if (cacheAge < _cacheExpirationDuration) {
        return _cachedStocksResponse!;
      }
    }

    final apiKey = await tokenRepo.getOzonToken();
    final clientId = await tokenRepo.getOzonId();

    if (apiKey == null || clientId == null) {
      throw Exception("Ozon credentials are not set");
    }

    // Fetch new data
    final response = await apiClient.fetchStocks(
      apiKey: apiKey,
      clientId: clientId,
      skus: skus,
      stockTypes: stockTypes,
      warehouseIds: warehouseIds,
      limit: limit,
      offset: offset,
    );

    // Update cache
    _cachedStocksResponse = response;
    _lastCacheUpdate = now;

    return response;
  }
}
