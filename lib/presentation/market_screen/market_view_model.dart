import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';

abstract class MarketScreenTokensService {
  Future<bool> areAllTokensSet();
}

class MarketViewModel extends ViewModelBase {
  final MarketScreenTokensService tokensService;
  MarketViewModel({required super.context, required this.tokensService});
  bool isAllTokensSet = false;

  @override
  Future<void> asyncInit() async {
    isAllTokensSet = await tokensService.areAllTokensSet();
  }
}
