import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/domain/entities/box_tariff.dart';
import 'package:mc_dashboard/domain/entities/tariff.dart';
import 'package:mc_dashboard/presentation/product_screen/product_view_model.dart';

abstract class TariffsServiceApiClient {
  Future<List<Tariff>> fetchTariffs({
    required String token,
    String locale,
  });
  Future<List<BoxTariff>> fetchBoxTariffs({
    required String token,
    required String date,
  });
}

class TariffsServiceImpl implements ProductViewModelTariffsService {
  final TariffsServiceApiClient apiClient;

  TariffsServiceImpl({required this.apiClient});

  @override
  Future<Either<AppErrorBase, List<Tariff>>> fetchTariffs({
    required String token,
    String locale = "ru",
  }) async {
    try {
      final tariffs = await apiClient.fetchTariffs(
        token: token,
        locale: locale,
      );
      return right(tariffs);
    } catch (e) {
      return left(AppErrorBase(
        'Ошибка получения тарифов: $e',
        name: 'fetchTariffs',
        sendTo: true,
      ));
    }
  }

  @override
  Future<Either<AppErrorBase, List<BoxTariff>>> fetchBoxTariffs({
    required String token,
    required String date,
  }) async {
    try {
      final tariffs = await apiClient.fetchBoxTariffs(
        token: token,
        date: date,
      );
      return right(tariffs);
    } catch (e) {
      return left(AppErrorBase(
        'Ошибка получения тарифов: $e',
        name: 'fetchTariffs',
        sendTo: true,
      ));
    }
  }
}
