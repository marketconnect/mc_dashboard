import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/domain/entities/promotions.dart';
import 'package:mc_dashboard/presentation/promotions_screen/promotions_view_model.dart';

abstract class PromotionsServiceApiClient {
  Future<List<Promotion>> fetchPromotions({
    required String token,
    required DateTime startDate,
    required DateTime endDate,
    required bool allPromo,
    int limit = 10,
    int offset = 0,
  });

  Future<PromotionDetails> fetchPromotionDetails({
    required String token,
    required List<int> promotionIds,
  });

  Future<List<PromotionNomenclature>> fetchPromotionNomenclatures({
    required String token,
    required int promotionId,
    required bool inAction,
    int limit = 10,
    int offset = 0,
  });
}

class PromotionsServiceImpl implements PromotionsViewModelService {
  final PromotionsServiceApiClient apiClient;

  PromotionsServiceImpl({required this.apiClient});

  @override
  Future<Either<AppErrorBase, List<Promotion>>> fetchPromotions({
    required String token,
    required DateTime startDate,
    required DateTime endDate,
    required bool allPromo,
  }) async {
    try {
      final promotions = await apiClient.fetchPromotions(
        token: token,
        startDate: startDate,
        endDate: endDate,
        allPromo: allPromo,
      );
      return right(promotions);
    } catch (e) {
      return left(AppErrorBase(
        'Ошибка получения списка акций: $e',
        name: 'fetchPromotionsForUser',
        sendTo: true,
      ));
    }
  }

  @override
  Future<Either<AppErrorBase, PromotionDetails>> fetchPromotionDetails({
    required String token,
    required List<int> promotionIds,
  }) async {
    try {
      final details = await apiClient.fetchPromotionDetails(
        token: token,
        promotionIds: promotionIds,
      );
      return right(details);
    } catch (e) {
      return left(AppErrorBase(
        'Ошибка получения деталей акции: $e',
        name: 'getPromotionDetails',
        sendTo: true,
      ));
    }
  }

  @override
  Future<Either<AppErrorBase, List<PromotionNomenclature>>>
      fetchPromotionNomenclatures({
    required String token,
    required int promotionId,
  }) async {
    try {
      final products = await apiClient.fetchPromotionNomenclatures(
        token: token,
        promotionId: promotionId,
        inAction: false,
      );
      return right(products);
    } catch (e) {
      return left(AppErrorBase(
        'Ошибка получения списка товаров для акции: $e',
        name: 'getPromotionEligibleProducts',
        sendTo: true,
      ));
    }
  }
}
