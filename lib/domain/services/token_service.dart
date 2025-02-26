import 'package:mc_dashboard/presentation/market_screen/market_view_model.dart';
import 'package:mc_dashboard/presentation/product_screen/product_view_model.dart';
import 'package:mc_dashboard/presentation/tokens_screen/tokens_view_model.dart';

abstract class TokenServiceStorage {
  Future<void> saveWbToken(String token);
  Future<void> saveOzonToken(String token);
  Future<void> saveOzonId(String id);

  Future<String?> getWbToken();
  Future<String?> getOzonToken();
  Future<String?> getOzonId();

  Future<void> removeWbToken();
  Future<void> removeOzonToken();
  Future<void> removeOzonId();
}

class TokenService
    implements
        TokensScreenTokensService,
        ProductViewModelApiKeyService,
        MarketScreenTokensService {
  final TokenServiceStorage tokenStorage;

  TokenService({required this.tokenStorage});

  // Установка токенов
  @override
  Future<void> setWbToken(String token) async {
    await tokenStorage.saveWbToken(token);
  }

  @override
  Future<void> setOzonToken(String token) async {
    await tokenStorage.saveOzonToken(token);
  }

  @override
  Future<void> setOzonId(String id) async {
    await tokenStorage.saveOzonId(id);
  }

  // Получение токенов
  @override
  Future<String?> getWbToken() async {
    return await tokenStorage.getWbToken();
  }

  @override
  Future<String?> getOzonToken() async {
    return await tokenStorage.getOzonToken();
  }

  @override
  Future<String?> getOzonId() async {
    return await tokenStorage.getOzonId();
  }

  @override
  Future<void> removeWbToken() async {
    await tokenStorage.removeWbToken();
  }

  @override
  Future<void> removeOzonToken() async {
    await tokenStorage.removeOzonToken();
  }

  @override
  Future<void> removeOzonId() async {
    await tokenStorage.removeOzonId();
  }

  // Проверка, все ли токены установлены
  @override
  Future<bool> areAllTokensSet() async {
    final wbToken = await getWbToken();
    final ozonToken = await getOzonToken();
    final ozonId = await getOzonId();
    return wbToken != null &&
        wbToken.isNotEmpty &&
        ozonToken != null &&
        ozonToken.isNotEmpty &&
        ozonId != null &&
        ozonId.isNotEmpty;
  }
}
