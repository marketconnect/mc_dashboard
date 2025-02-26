import 'package:mc_dashboard/core/utils/basket_num.dart';
import 'package:mc_dashboard/domain/entities/card_info.dart';
import 'package:mc_dashboard/presentation/product_detail_screen/product_detail_view_model.dart';

abstract class CardInfoServiceApiClient {
  Future<CardInfo> fetchCardInfo(String cardUrl);
}

class CardInfoService implements ProductDetailCardInfoService {
  final CardInfoServiceApiClient apiClient;

  CardInfoService({required this.apiClient});

  @override
  Future<CardInfo> fetchCardInfo(String productId) async {
    final basket = getBasketNum(int.parse(productId));
    final imageUrl = calculateImageUrl(basket, int.parse(productId));
    final cardUrl = calculateCardUrl(imageUrl);
    return await apiClient.fetchCardInfo(cardUrl);
  }
}
