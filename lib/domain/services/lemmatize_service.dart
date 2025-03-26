import 'package:fpdart/fpdart.dart';

import 'package:mc_dashboard/infrastructure/api/lemmatize.dart';

import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';

import 'package:mc_dashboard/domain/entities/lemmatize.dart';
import 'package:mc_dashboard/presentation/product_screen/product_view_model.dart';

class LemmatizeService implements ProductViewModelLemmatizeService {
  final LemmatizeApiClient apiClient;

  LemmatizeService({required this.apiClient});

  @override
  Future<Either<AppErrorBase, LemmatizeResponse>> get(
      {required LemmatizeRequest req}) async {
    try {
      final result = await apiClient.lemmatize(req);

      return Right(result);
    } catch (e, stackTrace) {
      final error = AppErrorBase(
        'Exception: $e',
        name: 'get',
        sendTo: true,
        source: 'LemmatizeService',
        args: [
          'req: $req',
        ],
        stackTrace: stackTrace.toString(),
      );
      AppLogger.log(error);
      return Left(error);
    }
  }
}
