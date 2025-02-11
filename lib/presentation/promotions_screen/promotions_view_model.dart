import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/domain/entities/promotions.dart';

// Promotions service
abstract class PromotionsViewModelService {
  Future<Either<AppErrorBase, List<Promotion>>> fetchPromotions({
    required String token,
    required DateTime startDate,
    required DateTime endDate,
    required bool allPromo,
  });

  Future<Either<AppErrorBase, PromotionDetails>> fetchPromotionDetails({
    required String token,
    required List<int> promotionIds,
  });
  Future<Either<AppErrorBase, List<PromotionNomenclature>>>
      fetchPromotionNomenclatures({
    required String token,
    required int promotionId,
  });
}

abstract class PromotionsViewModelApiKeyService {
  Future<String?> getWbToken();
}

class PromotionsViewModel extends ViewModelBase {
  PromotionsViewModel({
    required super.context,
    required this.promotionsService,
    required this.apiKeyService,
  });

  final PromotionsViewModelService promotionsService;
  final PromotionsViewModelApiKeyService apiKeyService;

  List<Promotion> _promotions = [];
  List<Promotion> get promotions => _promotions;

  String? _token;
  bool get hasToken => _token != null;

  Map<int, PromotionDetails> promotionDetailsMap = {};
  Map<int, List<PromotionNomenclature>> promotionNomenclaturesMap = {};

  String? errorMessage;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Methods
  Future<void> loadAllPromotionNomenclatures() async {
    if (_token == null) return;
    // Параллельно загружаем номенклатуры для каждой акции.
    await Future.wait(
        promotions.map((promo) => loadPromotionNomenclatures(promo.id)));
  }

  /// Вычисляемое свойство, формирующее данные по товарам из акций.
  Map<int, Map<int, PromotionNomenclature>> get promotionProductsData {
    final Map<int, Map<int, PromotionNomenclature>> productData = {};
    for (var promo in promotions) {
      final nomenclatures = promotionNomenclaturesMap[promo.id] ?? [];
      for (var item in nomenclatures) {
        productData.putIfAbsent(item.id, () => {});
        productData[item.id]![promo.id] = item;
      }
    }
    return productData;
  }

  @override
  Future<void> asyncInit() async {
    await refreshData();
  }

  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();

    final tokenOrNull = await apiKeyService.getWbToken();
    if (tokenOrNull == null) {
      errorMessage = "Не удалось получить API токен";
      _isLoading = false;
      notifyListeners();
      return;
    }
    _token = tokenOrNull;

    await loadPromotions();
    await loadAllPromotionNomenclatures(); // Загружаем номенклатуры один раз
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadPromotions() async {
    if (_token == null) return;

    final DateTime startDate = DateTime.now();
    final DateTime endDate = startDate.add(const Duration(days: 14));

    final promotionsOrEither = await promotionsService.fetchPromotions(
      token: _token!,
      startDate: startDate,
      endDate: endDate,
      allPromo: false,
    );

    if (promotionsOrEither.isRight()) {
      _promotions = promotionsOrEither.fold((l) => [], (r) => r);
      notifyListeners();
    } else {
      errorMessage = "Ошибка загрузки акций";
      notifyListeners();
    }
  }

  Future<void> loadPromotionDetails(int promotionId) async {
    if (_token == null) return;

    final detailsOrEither = await promotionsService.fetchPromotionDetails(
      token: _token!,
      promotionIds: [promotionId],
    );

    if (detailsOrEither.isRight()) {
      promotionDetailsMap[promotionId] =
          detailsOrEither.fold((l) => null, (r) => r)!;
      notifyListeners();
    } else {
      errorMessage = "Ошибка загрузки деталей акции";
      notifyListeners();
    }
  }

  Future<void> loadPromotionNomenclatures(int promotionId) async {
    if (_token == null) {
      errorMessage = "Токен отсутствует";
      notifyListeners();
      return;
    }

    final nomenclaturesOrEither =
        await promotionsService.fetchPromotionNomenclatures(
      token: _token!,
      promotionId: promotionId,
    );

    nomenclaturesOrEither.fold(
      (error) {
        errorMessage = error.message;
        print("Ошибка загрузки товаров акции: ${error.message}");
      },
      (nomenclatures) {
        promotionNomenclaturesMap[promotionId] = nomenclatures;
        notifyListeners();
      },
    );
  }

  Future<Map<int, Map<int, PromotionNomenclature>>>
      getPromotionProductsData() async {
    // Загружаем номенклатуры для всех акций (если не загружены)
    await Future.wait(
        promotions.map((promo) => loadPromotionNomenclatures(promo.id)));

    final Map<int, Map<int, PromotionNomenclature>> productData = {};
    for (var promo in promotions) {
      final nomenclatures = promotionNomenclaturesMap[promo.id] ?? [];
      for (var item in nomenclatures) {
        productData.putIfAbsent(item.id, () => {});
        productData[item.id]![promo.id] = item;
      }
    }
    return productData;
  }
}
