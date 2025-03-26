import 'package:mc_dashboard/domain/entities/wb_seller_warehouse.dart';
import 'package:mc_dashboard/presentation/product_cards_screen/product_cards_view_model.dart';

// Interface for the API client
abstract class WbSellerWarehousesServiceApiClient {
  Future<List<WbSellerWarehouse>> fetchWarehouses({required String token});
}

// Interface for the token repository
abstract class WbSellerWarehousesServiceWbTokenRepo {
  Future<String?> getWbToken();
}

class WbSellerWarehousesService
    implements ProductCardsWbSellerWarehousesService {
  final WbSellerWarehousesServiceApiClient apiClient;
  final WbSellerWarehousesServiceWbTokenRepo wbTokenRepo;

  const WbSellerWarehousesService({
    required this.apiClient,
    required this.wbTokenRepo,
  });

  @override
  Future<List<WbSellerWarehouse>> fetchSellerWarehouses() async {
    final token = await wbTokenRepo.getWbToken();
    if (token == null) {
      throw Exception("WB token is not set");
    }

    return await apiClient.fetchWarehouses(token: token);
  }
}
