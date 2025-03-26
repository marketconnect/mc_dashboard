import 'package:mc_dashboard/domain/entities/ozon_product_info.dart';
import 'package:mc_dashboard/presentation/ozon_product_card_screen/ozon_product_card_view_model.dart';
import 'package:mc_dashboard/presentation/ozon_product_cards_screen/ozon_product_cards_view_model.dart';

abstract class OzonProductInfoServiceApiClient {
  Future<OzonProductInfoResponse> fetchProductInfo({
    required String apiKey,
    required String clientId,
    required List<String> offerIds,
  });
}

abstract class OzonProductInfoSecureTokenStorageRepo {
  Future<String?> getOzonToken();
  Future<String?> getOzonId();
}

class OzonProductInfoService
    implements
        OzonProductCardsOzonProductInfoService,
        OzonProductCardOzonProductInfoService {
  final OzonProductInfoServiceApiClient apiClient;
  final OzonProductInfoSecureTokenStorageRepo tokenRepo;

  const OzonProductInfoService({
    required this.apiClient,
    required this.tokenRepo,
  });

  @override
  Future<OzonProductInfoResponse> fetchProductInfo({
    required List<String> offerIds,
  }) async {
    final apiKey = await tokenRepo.getOzonToken();
    final clientId = await tokenRepo.getOzonId();

    if (apiKey == null || clientId == null) {
      throw Exception("Ozon credentials are not set");
    }

    return await apiClient.fetchProductInfo(
      apiKey: apiKey,
      clientId: clientId,
      offerIds: offerIds,
    );
  }
}
