import 'package:mc_dashboard/presentation/product_card_screen/product_card_view_model.dart';

abstract class WbPriceApiServiceApiClient {
  Future<Map<String, dynamic>> uploadPriceTask({
    required String token,
    required List<Map<String, dynamic>> priceData,
  });
}

abstract class WbPriceApiServiceWbTokenRepo {
  Future<String?> getWbToken();
}

class WbApiPriceService implements ProductCardWbPriceService {
  final WbPriceApiServiceApiClient apiClient;
  final WbPriceApiServiceWbTokenRepo wbTokenRepo;

  WbApiPriceService({required this.apiClient, required this.wbTokenRepo});

  @override
  Future<Map<String, dynamic>> uploadPriceTask(
      List<Map<String, dynamic>> priceData) async {
    final token = await wbTokenRepo.getWbToken();
    if (token == null) {
      throw Exception(
          "Для выполнения операции нужно добавить токен Wildberries");
    }
    return await apiClient.uploadPriceTask(
      token: token,
      priceData: priceData,
    );
  }
}
