import 'package:flutter/material.dart';
import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';
import 'package:mc_dashboard/domain/entities/product.dart';
import 'package:mc_dashboard/routes/main_navigation_route_names.dart';

abstract class CardsService {
  Future<List<ProductData>> fetchProducts();
}

class AddCardsViewModel extends ViewModelBase {
  AddCardsViewModel({required this.cardsService, required super.context});

  final CardsService cardsService;
  List<ProductData> products = [];

  @override
  Future<void> asyncInit() async {
    // try {
    //   products = await cardsService.fetchProducts();
    // } catch (e) {
    //   setError(e.toString());
    // }
  }

  Future<void> loadProductsFromExcel() async {
    try {
      setLoading();
      products = await cardsService.fetchProducts();
      setLoaded();
    } catch (e) {
      setError(e.toString());
    }
  }

  // Navigation
  Future<void> routeToProductDetail(ProductData product) async {
    await Navigator.of(context)
        .pushNamed(MainNavigationRouteNames.productDetail, arguments: product);
  }
}
