import 'package:mc_dashboard/domain/entities/good.dart';
import 'package:mc_dashboard/presentation/product_card_screen/product_card_view_model.dart';
import 'package:mc_dashboard/presentation/product_cards_screen/product_cards_view_model.dart';

abstract class WbGoodsServiceApiClient {
  Future<List<Good>> fetchGoods({
    required String apiKey,
    int? filterNmID,
  });
}

abstract class WbGoodSeviceWbTokenRepo {
  Future<String?> getWbToken();
}

class WbGoodsService
    implements ProductCardsGoodsService, ProductCardGoodsService {
  final WbGoodsServiceApiClient apiClient;
  final WbGoodSeviceWbTokenRepo wbTokenRepo;

  WbGoodsService({required this.apiClient, required this.wbTokenRepo});

  @override
  Future<List<Good>> getGoods({
    int? filterNmID,
  }) async {
    final String? apiKey = await wbTokenRepo.getWbToken();
    if (apiKey == null) {
      throw Exception('Не удалось получить токен для доступа к API');
    }
    return await apiClient.fetchGoods(
      apiKey: apiKey,
      filterNmID: filterNmID,
    );
  }
}
