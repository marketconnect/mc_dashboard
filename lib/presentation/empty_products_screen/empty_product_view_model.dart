import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';
import 'package:mc_dashboard/core/utils/basket_num.dart';
import 'package:mc_dashboard/routes/main_navigation_route_names.dart';

class EmptyProductViewModel extends ViewModelBase {
  EmptyProductViewModel({required super.context, required this.onNavigateTo});
  // Navigation
  final void Function({
    required String routeName,
    Map<String, dynamic>? params,
  }) onNavigateTo;
  // Fields
  String searchQuery = '';
  String? searchedProductName;
  int? sku;
  // Methods
  @override
  Future<void> asyncInit() async {}

  Future<void> onSearchChanged(String value) async {
    searchQuery = value;
    if (value.length > 4) {
      final valueInt = int.tryParse(value);
      if (valueInt == null) {
        notifyListeners();
        return;
      }

      final basketNum = getBasketNum(valueInt);
      final cardInfo = await fetchCardInfo(
          calculateCardUrl(calculateImageUrl(basketNum, valueInt)));

      searchedProductName = cardInfo.imtName;
      sku = valueInt;
    }

    notifyListeners();
  }

  // Navigation
  void onNavigateBack() {
    onNavigateTo(
      routeName: MainNavigationRouteNames.choosingNicheScreen,
    );
  }

  void onNavigateToProductScreen(int productId, int productPrice) {
    onNavigateTo(
      routeName: MainNavigationRouteNames.productScreen,
      params: {"productId": productId, "productPrice": productPrice},
    );
  }
}
