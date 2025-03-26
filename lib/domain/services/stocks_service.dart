import 'package:fpdart/fpdart.dart';

import 'package:mc_dashboard/infrastructure/api/stocks.dart';

import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';

import 'package:mc_dashboard/domain/entities/stock.dart';
import 'package:mc_dashboard/presentation/product_screen/product_view_model.dart';

class StocksService implements ProductViewModelStocksService {
  final StocksApiClient stocksApiClient;

  const StocksService({required this.stocksApiClient});

  @override
  @override
  Future<Either<AppErrorBase, List<Stock>>> getMonthStocks({
    int? productId,
  }) async {
    try {
      final today = DateTime.now();
      final startDate = today.subtract(const Duration(days: 31));
      final endDate = today.subtract(const Duration(days: 1));

      final startDateStr = startDate.toIso8601String().substring(0, 10);
      final endDateStr = endDate.toIso8601String().substring(0, 10);

      final result = await stocksApiClient.getStocks(
        productId: productId,
        pageSize: 10000,
        startDate: startDateStr,
        endDate: endDateStr,
      );

      return Right(result.stocks);
    } catch (e) {
      return const Right([]);
    }
  }
}
