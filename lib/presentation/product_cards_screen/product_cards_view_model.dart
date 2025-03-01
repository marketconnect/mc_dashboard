import 'package:flutter/material.dart';
import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';
import 'package:mc_dashboard/domain/entities/good.dart';
import 'package:mc_dashboard/domain/entities/product_card.dart';
import 'package:mc_dashboard/domain/entities/product_cost_data.dart';
import 'package:mc_dashboard/domain/entities/wb_box_tariff.dart';
import 'package:mc_dashboard/domain/entities/wb_tariff.dart';
import 'package:mc_dashboard/routes/main_navigation_route_names.dart';

abstract class ProductCardsWbContentApi {
  Future<List<ProductCard>> fetchAllProductCards();
}

abstract class ProductCardsWbTariffsService {
  Future<List<WbTariff>> fetchTariffs({String locale = 'ru'});
  Future<List<WbBoxTariff>> fetchBoxTariffs({required String date});
}

abstract class ProductCardsWbProductCostService {
  Future<List<ProductCostData>> getAllCostData();
}

abstract class ProductCardsGoodsService {
  Future<List<Good>> getGoods({
    int? filterNmID,
  });
}

class ProductCardsViewModel extends ViewModelBase {
  final ProductCardsWbContentApi wbApiContentService;
  final ProductCardsGoodsService goodsService;
  final ProductCardsWbProductCostService wbProductCostService;
  final ProductCardsWbTariffsService wbTariffsService;

  List<ProductCard> productCards = [];
  String? errorMessage;
  Map<int, double> goodsPrices = {};
  ProductCardsViewModel(
      {required this.wbApiContentService,
      required this.goodsService,
      required this.wbTariffsService,
      required this.wbProductCostService,
      required super.context});

  Map<int, ProductCostData> productCosts = {};

  @override
  List<WbTariff> allTariffs = [];
  List<WbBoxTariff> allBoxTariffs = [];

  @override
  Future<void> asyncInit() async {
    setLoading();
    try {
      // Грузим товары
      productCards = await wbApiContentService.fetchAllProductCards();

      // Грузим цены
      final goods = await goodsService.getGoods();
      for (var g in goods) {
        if (g.sizes.isNotEmpty) {
          goodsPrices[g.nmID] = g.sizes.first.clubDiscountedPrice;
        }
      }

      // Грузим costData
      final costDataList = await wbProductCostService.getAllCostData();
      for (var c in costDataList) {
        productCosts[c.nmID] = c;
      }

      // Грузим тарифы
      allTariffs = await wbTariffsService.fetchTariffs();
      final today = DateTime.now();
      final formattedDate =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
      allBoxTariffs =
          await wbTariffsService.fetchBoxTariffs(date: formattedDate);

      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    }
    setLoaded();
    notifyListeners();
  }

  Future<void> fetchProductCards() async {
    setLoading();
    try {
      productCards = await wbApiContentService.fetchAllProductCards();
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    }
    setLoaded();
  }

  Future<void> fetchGoodsPrices() async {
    try {
      List<Good> goods = await goodsService.getGoods();
      for (var good in goods) {
        if (good.sizes.isNotEmpty) {
          goodsPrices[good.nmID] = good.sizes.first.clubDiscountedPrice;
        }
      }
      notifyListeners();
    } catch (e) {
      errorMessage = "Ошибка загрузки цен: ${e.toString()}";
    }
  }

  Future<void> fetchProductCosts() async {
    try {
      final productCosts = await wbProductCostService.getAllCostData();
      this.productCosts = productCosts.fold(
          {},
          (previousValue, element) => {
                ...previousValue,
                ...{element.nmID: element}
              });
      notifyListeners();
    } catch (e) {
      errorMessage = "Ошибка загрузки цен: ${e.toString()}";
    }
  }

  // Navigations

  void navTo(int imtID, int nmID) {
    Navigator.of(context).pushNamed(
      MainNavigationRouteNames.productCard,
      arguments: {'imtID': imtID, 'nmID': nmID},
    );
  }
}
