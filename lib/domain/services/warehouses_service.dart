import 'package:fpdart/fpdart.dart';

import 'package:mc_dashboard/infrastructure/api/warehouses.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/domain/entities/warehouse.dart';
import 'package:mc_dashboard/presentation/product_screen/product_view_model.dart';

class WhService implements ProductViewModelWhService {
  final WarehousesApiClient whApiClient;

  const WhService({required this.whApiClient});

  @override
  Future<Either<AppErrorBase, List<Warehouse>>> getWarehouses({
    required List<int> ids,
  }) async {
    try {
      final result = await whApiClient.getWarehouses(ids: ids);

      return Right(result.warehouses);
    } catch (e) {
      return const Right([]);
    }
  }
}
