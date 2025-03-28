import 'package:mc_dashboard/presentation/ozon_product_card_screen/ozon_product_card_view_model.dart';

abstract class OzonTokenRepository {
  Future<String?> getOzonToken();
  Future<String?> getOzonId();
}

abstract class OzonPriceServiceOzonPriceApiClient {
  Future<Map<String, dynamic>> updatePrices({
    required String clientId,
    required String apiKey,
    required List<Map<String, dynamic>> prices,
  });
}

class OzonPriceService implements OzonProductCardOzonPriceService {
  final OzonPriceServiceOzonPriceApiClient _apiClient;
  final OzonTokenRepository _tokenRepository;

  OzonPriceService({
    required OzonPriceServiceOzonPriceApiClient apiClient,
    required OzonTokenRepository tokenRepository,
  })  : _apiClient = apiClient,
        _tokenRepository = tokenRepository;

  @override
  Future<Map<String, dynamic>> updatePrices(
      List<Map<String, dynamic>> prices) async {
    final token = await _tokenRepository.getOzonToken();
    if (token == null) {
      throw Exception("Для выполнения операции нужно добавить токен Ozon");
    }

    final clientId = await _tokenRepository.getOzonId();
    if (clientId == null) {
      throw Exception("Для выполнения операции нужно добавить Client-Id Ozon");
    }

    return await _apiClient.updatePrices(
      clientId: clientId,
      apiKey: token,
      prices: prices,
    );
  }
}
