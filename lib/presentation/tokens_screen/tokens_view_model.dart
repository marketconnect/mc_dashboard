import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';

abstract class TokensScreenTokensService {
  Future<void> setWbToken(String token);
  Future<void> setOzonToken(String token);
  Future<void> setOzonId(String id);
  Future<String?> getWbToken();
  Future<String?> getOzonToken();
  Future<String?> getOzonId();

  Future<void> removeWbToken();
  Future<void> removeOzonToken();
  Future<void> removeOzonId();
  Future<bool> areAllTokensSet();
}

class TokensViewModel extends ViewModelBase {
  final TokensScreenTokensService tokensService;

  String? wbToken;
  String? ozonToken;
  String? ozonId;
  bool allTokensSet = false;
  String? errorMessage;

  TokensViewModel({required this.tokensService, required super.context});

  @override
  Future<void> asyncInit() async {
    await loadTokens();
  }

  Future<void> loadTokens() async {
    setLoading();
    try {
      wbToken = await tokensService.getWbToken();
      ozonToken = await tokensService.getOzonToken();
      ozonId = await tokensService.getOzonId();
      allTokensSet = await tokensService.areAllTokensSet();
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Ошибка загрузки токенов: ${e.toString()}';
    }
    setLoaded();
  }

  Future<void> saveWbToken(String token) async {
    await tokensService.setWbToken(token);
    await loadTokens();
  }

  Future<void> saveOzonToken(String token) async {
    await tokensService.setOzonToken(token);
    await loadTokens();
  }

  Future<void> saveOzonId(String id) async {
    await tokensService.setOzonId(id);
    await loadTokens();
  }

  Future<void> removeWbToken() async {
    await tokensService.removeWbToken();
    await loadTokens();
  }

  Future<void> removeOzonToken() async {
    await tokensService.removeOzonToken();
    await loadTokens();
  }

  Future<void> removeOzonId() async {
    await tokensService.removeOzonId();
    await loadTokens();
  }
}
