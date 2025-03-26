import 'package:mc_dashboard/domain/entities/ozon_fbs_stock.dart';
import 'package:mc_dashboard/infrastructure/repositories/secure_token_storage_repo.dart';
import 'package:mc_dashboard/presentation/ozon_product_cards_screen/ozon_product_cards_view_model.dart';

abstract class OzonFbsStocksServiceApiClient {
  Future<OzonFbsStocksResponse> fetchStocks({
    required String apiKey,
    required String clientId,
    String? cursor,
    List<String>? offerIds,
    List<int>? productIds,
    String? visibility,
    Map<String, bool>? withQuant,
    int? limit,
  });
}

class OzonFbsStocksServiceImpl implements OzonFbsStocksService {
  final OzonFbsStocksServiceApiClient apiClient;
  final SecureTokenStorageRepo tokenRepo;

  const OzonFbsStocksServiceImpl({
    required this.apiClient,
    required this.tokenRepo,
  });

  @override
  Future<OzonFbsStocksResponse> fetchStocks({
    String? cursor,
    List<String>? offerIds,
    List<int>? productIds,
    String? visibility,
    Map<String, bool>? withQuant,
    int? limit,
  }) async {
    final apiKey = await tokenRepo.getOzonToken();
    final clientId = await tokenRepo.getOzonId();

    if (apiKey == null || clientId == null) {
      throw Exception("Ozon credentials are not set");
    }

    return await apiClient.fetchStocks(
      apiKey: apiKey,
      clientId: clientId,
      cursor: cursor,
      offerIds: offerIds,
      productIds: productIds,
      visibility: visibility,
      withQuant: withQuant,
      limit: limit,
    );
  }
}
