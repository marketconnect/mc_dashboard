import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/infrastructure/api/kw_lemmas.dart';

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
    } catch (e) {
      return const Right([]);
    }
  }
}
