import 'package:mc_dashboard/domain/entities/ozon_product.dart';
import 'package:mc_dashboard/infrastructure/repositories/secure_token_storage_repo.dart';
import 'package:mc_dashboard/presentation/ozon_product_cards_screen/ozon_product_cards_view_model.dart';
import 'package:mc_dashboard/presentation/product_cost_import_screen/product_cost_import_view_model.dart';

abstract class OzonProductsServiceApiClient {
  Future<OzonProductsResponse> fetchProducts({
    required String apiKey,
    required String clientId,
    List<String>? offerIds,
  });
}

class OzonProductsService
    implements
        OzonProductCardsOzonProductsService,
        ProductCostImportOzonProductsService {
  final OzonProductsServiceApiClient apiClient;
  final SecureTokenStorageRepo tokenRepo;

  const OzonProductsService({
    required this.apiClient,
    required this.tokenRepo,
  });

  @override
  Future<OzonProductsResponse> fetchProducts({
    List<String>? offerIds,
    List<int>? productIds,
    String? visibility,
    String? lastId,
    int? limit,
  }) async {
    final apiKey = await tokenRepo.getOzonToken();
    final clientId = await tokenRepo.getOzonId();

    if (apiKey == null || clientId == null) {
      throw Exception("Ozon credentials are not set");
    }

    return await apiClient.fetchProducts(
      apiKey: apiKey,
      clientId: clientId,
      offerIds: offerIds,
    );
  }
}
