import 'package:mc_dashboard/domain/entities/wb_box_tariff.dart';
import 'package:mc_dashboard/domain/entities/wb_tariff.dart';
import 'package:mc_dashboard/infrastructure/api/wb_tariffs_api_client.dart';
import 'package:mc_dashboard/infrastructure/repositories/secure_token_storage_repo.dart';
import 'package:mc_dashboard/presentation/product_card_screen/product_card_view_model.dart';
import 'package:mc_dashboard/presentation/product_cards_screen/product_cards_view_model.dart';

abstract class WbTariffsServiceWbTokenRepo {
  Future<String?> getWbToken();
}

abstract class WbTariffsServiceApiClient {
  Future<List<WbTariff>> fetchTariffs({required String token, String locale});
  Future<List<WbBoxTariff>> fetchBoxTariffs(
      {required String token, required String date});
}

class WbTariffsService
    implements ProductCardWbTariffsService, ProductCardsWbTariffsService {
  final WbTariffsServiceApiClient apiClient;
  final WbTariffsServiceWbTokenRepo wbTokenRepo;
  static final WbTariffsService _instance = WbTariffsService._internal(
      WbTariffsApiClient(), SecureTokenStorageRepo());

  factory WbTariffsService() {
    return _instance;
  }

  // Приватный внутренний конструктор
  WbTariffsService._internal(this.apiClient, this.wbTokenRepo);

  // Кешированные тарифы
  List<WbTariff>? _cachedTariffs;
  final Map<String, List<WbBoxTariff>> _cachedBoxTariffs = {};

  @override
  Future<List<WbTariff>> fetchTariffs({String locale = 'ru'}) async {
    if (_cachedTariffs != null) {
      print("Returning cached tariffs");
      return _cachedTariffs!;
    }
    print("Fetching tariffs from API");
    // final token = Env.wbToken;
    final token = await wbTokenRepo.getWbToken();
    if (token == null) {
      throw Exception("WB token is not set");
    }
    _cachedTariffs = await apiClient.fetchTariffs(token: token, locale: locale);
    return _cachedTariffs!;
  }

  @override
  Future<List<WbBoxTariff>> fetchBoxTariffs({required String date}) async {
    if (_cachedBoxTariffs.containsKey(date)) {
      print("Returning cached box tariffs for date: $date");
      return _cachedBoxTariffs[date]!;
    }

    print("Fetching box tariffs from API for date: $date");
    // final token = Env.wbToken;
    final token = await wbTokenRepo.getWbToken();
    if (token == null) {
      throw Exception("WB token is not set");
    }
    final tariffs = await apiClient.fetchBoxTariffs(token: token, date: date);
    _cachedBoxTariffs[date] = tariffs;
    return tariffs;
  }
}
