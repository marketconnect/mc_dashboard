import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/api/kw_lemmas.dart';

import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/domain/entities/kw_lemmas.dart';
import 'package:mc_dashboard/presentation/product_screen/product_view_model.dart';

class KwLemmaService implements ProductViewModelKwLemmaService {
  final KwLemmasApiClient apiClient;

  KwLemmaService(this.apiClient);

  @override
  Future<Either<AppErrorBase, List<KwLemmaItem>>> get(
      {required List<int> ids}) async {
    if (ids.isEmpty) {
      return Right([]);
    }
    try {
      final result = await apiClient.getKwLemmas(ids: ids);

      return Right(result.kwLemmas);
    } on DioException catch (e, stackTrace) {
      if (e.response?.statusCode == 404) {
        return const Right([]);
      }

      // final responseMessage = e.response?.data?['message'] ?? e.message;
      final error = AppErrorBase(
        'DioException: $e',
        name: 'get',
        sendTo: true,
        source: 'KwLemmaService',
        args: [
          'ids: $ids',
        ],
        stackTrace: stackTrace.toString(),
      );
      AppLogger.log(error);
      return Left(error);
    } catch (e, stackTrace) {
      final error = AppErrorBase(
        'Unexpected error: $e',
        name: 'get',
        sendTo: true,
        source: 'KwLemmaService',
        args: [
          'productId: $ids',
        ],
        stackTrace: stackTrace.toString(),
      );
      AppLogger.log(error);
      return Left(error);
    }
  }
}
