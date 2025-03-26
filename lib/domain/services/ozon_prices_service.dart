import 'package:mc_dashboard/domain/entities/ozon_price.dart';
import 'package:mc_dashboard/infrastructure/repositories/secure_token_storage_repo.dart';
import 'package:mc_dashboard/presentation/ozon_product_card_screen/ozon_product_card_view_model.dart';
import 'package:mc_dashboard/presentation/ozon_product_cards_screen/ozon_product_cards_view_model.dart';

abstract class OzonPricesServiceApiClient {
  Future<OzonPricesResponse> fetchPrices({
    required String apiKey,
    required String clientId,
    String? cursor,
    List<String>? offerIds,
    List<int>? productIds,
    String? visibility,
    int? limit,
  });
}

class OzonPricesServiceImpl
    implements
        OzonProductCardsOzonPricesService,
        OzonProductCardOzonPricesService {
  final OzonPricesServiceApiClient apiClient;
  final SecureTokenStorageRepo tokenRepo;

  const OzonPricesServiceImpl({
    required this.apiClient,
    required this.tokenRepo,
  });

  @override
  Future<OzonPricesResponse> fetchPrices({
    String? cursor,
    List<String>? offerIds,
    List<int>? productIds,
    String? visibility,
    int? limit,
  }) async {
    final apiKey = await tokenRepo.getOzonToken();
    final clientId = await tokenRepo.getOzonId();

    if (apiKey == null || clientId == null) {
      throw Exception("Ozon credentials are not set");
    }

    return await apiClient.fetchPrices(
      apiKey: apiKey,
      clientId: clientId,
      cursor: cursor,
      offerIds: offerIds,
      productIds: productIds,
      visibility: visibility,
      limit: limit,
    );
  }
}
