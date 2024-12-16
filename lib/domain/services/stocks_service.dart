import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import 'package:mc_dashboard/api/stocks.dart';

import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';

import 'package:mc_dashboard/domain/entities/stock.dart';
import 'package:mc_dashboard/presentation/product_screen/product_view_model.dart';

class StocksService implements ProductViewModelStocksService {
  final StocksApiClient stocksApiClient;

  StocksService({required this.stocksApiClient});

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

      print(
          'Fetching stocks: productId=$productId, startDate=$startDateStr, endDate=$endDateStr');

      final result = await stocksApiClient.getStocks(
        productId: productId,
        pageSize: 10000,
        startDate: startDateStr,
        endDate: endDateStr,
      );
      print("stockds ${result.stocks.where((e) => e.quantity > 0)}");

      return Right(result.stocks);
    } on DioException catch (e, stackTrace) {
      if (e.response?.statusCode == 404) {
        return const Right([]);
      }

      if (e.response?.data == null) {
        final error = AppErrorBase(
          'DioException: ',
          name: 'getOneMonthStocks',
          sendTo: true,
          source: 'StocksService',
          args: [
            'productId: $productId',
          ],
          stackTrace: stackTrace.toString(),
        );
        AppLogger.log(error);
        return Left(error);
      }

      final responseMessage = e.response?.data?['message'] ?? e.message;
      final error = AppErrorBase(
        'DioException: $responseMessage',
        name: 'getOneMonthStocks',
        sendTo: true,
        source: 'StocksService',
        args: [
          'productId: $productId',
        ],
        stackTrace: stackTrace.toString(),
      );
      AppLogger.log(error);
      return Left(error);
    } catch (e, stackTrace) {
      final error = AppErrorBase(
        'Unexpected error: $e',
        name: 'getOneMonthStocks',
        sendTo: true,
        source: 'StocksService',
        args: [
          'productId: $productId',
        ],
        stackTrace: stackTrace.toString(),
      );
      AppLogger.log(error);
      return Left(error);
    }
  }
}
