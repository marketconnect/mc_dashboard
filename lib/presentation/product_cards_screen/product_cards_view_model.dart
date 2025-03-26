import 'package:flutter/material.dart';
import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';
import 'package:mc_dashboard/domain/entities/good.dart';
import 'package:mc_dashboard/domain/entities/product_card.dart';
import 'package:mc_dashboard/domain/entities/product_cost_data.dart';
import 'package:mc_dashboard/domain/entities/wb_box_tariff.dart';
import 'package:mc_dashboard/domain/entities/wb_pallet_tariff.dart';
import 'package:mc_dashboard/domain/entities/wb_stock.dart';
import 'package:mc_dashboard/domain/entities/wb_tariff.dart';
import 'package:mc_dashboard/domain/entities/wb_warehouse_stock.dart';
import 'package:mc_dashboard/routes/main_navigation_route_names.dart';

import 'package:mc_dashboard/domain/entities/wb_seller_warehouse.dart';

abstract class ProductCardsWbContentApi {
  Future<List<ProductCard>> fetchAllProductCards();
}

abstract class ProductCardsWbTariffsService {
  Future<List<WbTariff>> fetchTariffs({String locale = 'ru'});
  Future<List<WbBoxTariff>> fetchBoxTariffs({required String date});
  Future<List<WbPalletTariff>> fetchPalletTariffs({required String date});
}

abstract class ProductCardsWbProductCostService {
  Future<List<ProductCostData>> getAllCostWbData();
}

abstract class ProductCardsGoodsService {
  Future<List<Good>> getGoods({
    int? filterNmID,
  });
}

abstract class ProductCardsWbSellerWarehousesService {
  Future<List<WbSellerWarehouse>> fetchSellerWarehouses();
}

abstract class ProductCardsWbStocksService {
  Future<List<WbStock>> fetchStocks(String dateFrom);
}

abstract class ProductCardsWbWarehouseStocksService {
  Future<List<WbSellerStock>> fetchSellerStocks({
    required int warehouseId,
    required List<String> skus,
  });
}

class ProductCardsViewModel extends ViewModelBase {
  final ProductCardsWbContentApi wbApiContentService;
  final ProductCardsGoodsService goodsService;
  final ProductCardsWbProductCostService wbProductCostService;
  final ProductCardsWbTariffsService wbTariffsService;
  final ProductCardsWbWarehouseStocksService warehouseStocksService;
  final ProductCardsWbSellerWarehousesService sellerWarehousesService;
  final ProductCardsWbStocksService wbStocksService;

  List<ProductCard> productCards = [];
  String? errorMessage;
  Map<int, double> goodsPrices = {};
  ProductCardsViewModel(
      {required this.wbApiContentService,
      required this.goodsService,
      required this.wbTariffsService,
      required this.wbProductCostService,
      required this.warehouseStocksService,
      required this.sellerWarehousesService,
      required this.wbStocksService,
      required super.context});

  Map<int, ProductCostData> productCosts = {};

  List<WbTariff> allTariffs = [];
  List<WbBoxTariff> allBoxTariffs = [];
  List<WbPalletTariff> allPalletTariffs = [];

  late Map<int, WbTariff?> subjectIdToTariff;
  late Map<String, WbBoxTariff?> warehouseToBoxTariff;
  late Map<String, WbPalletTariff?> warehouseToPalletTariff;

  Map<int, double?> profitByNmId = {};
  Map<int, double?> marginByNmId = {};

  final Map<int, int> stocksByNmId = {};

  List<WbSellerWarehouse> warehouses = [];
  final Map<int, Map<int, int>> stocksByWarehouseAndNmId = {};
  final Map<int, int> totalStocksByNmId = {};
  final Map<int, int> totalStocksWBByNmId = {};

  // Add map to store stocks by size (chrtID)
  final Map<int, Map<int, int>> stocksByChrtId = {};
  // For tooltip
  final Map<int, Map<String, int>> wbStocksByWarehouseAndNmId = {};

  @override
  Future<void> asyncInit() async {
    setLoading();
    errorMessage = null;
    notifyListeners();

    try {
      productCards = await wbApiContentService.fetchAllProductCards();

      final goods = await goodsService.getGoods();

      for (var g in goods) {
        if (g.sizes.isNotEmpty) {
          goodsPrices[g.nmID] = g.sizes.first.clubDiscountedPrice;
        }
      }

      final costDataList = await wbProductCostService.getAllCostWbData();

      for (var c in costDataList) {
        productCosts[c.nmID] = c;
      }

      allTariffs = await wbTariffsService.fetchTariffs();

      final today = DateTime.now();
      final formattedDate =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
      allBoxTariffs =
          await wbTariffsService.fetchBoxTariffs(date: formattedDate);

      allPalletTariffs =
          await wbTariffsService.fetchPalletTariffs(date: formattedDate);

      subjectIdToTariff = {for (var t in allTariffs) t.subjectID: t};

      warehouseToBoxTariff = {for (var b in allBoxTariffs) b.warehouseName: b};

      warehouseToPalletTariff = {
        for (var p in allPalletTariffs) p.warehouseName: p
      };

      for (var card in productCards) {
        double? price = goodsPrices[card.nmID];
        final costData = productCosts[card.nmID];
        final wbTariff = subjectIdToTariff[card.subjectID];
        WbBoxTariff? boxTariff;
        WbPalletTariff? palletTariff;
        if (costData != null) {
          boxTariff = warehouseToBoxTariff[costData.warehouseName];
          palletTariff = warehouseToPalletTariff[costData.warehouseName];
        }

        double? profit = _calcProfitOnce(
          price: price,
          costData: costData,
          wbTariff: wbTariff,
          boxTariff: boxTariff,
          palletTariff: palletTariff,
          length: card.length,
          width: card.width,
          height: card.height,
        );

        double? margin = _calcMarginOnce(
          price: price,
          costData: costData,
          wbTariff: wbTariff,
          boxTariff: boxTariff,
          palletTariff: palletTariff,
          length: card.length,
          width: card.width,
          height: card.height,
        );

        profitByNmId[card.nmID] = profit;
        marginByNmId[card.nmID] = margin;
      }

      await fetchAllStocks();

      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    }
    setLoaded();
  }

  double? _calcProfitOnce({
    required double? price,
    required ProductCostData? costData,
    required WbTariff? wbTariff,
    required WbBoxTariff? boxTariff,
    required WbPalletTariff? palletTariff,
    required int length,
    required int width,
    required int height,
  }) {
    if (price == null ||
        price == 0 ||
        costData == null ||
        wbTariff == null ||
        boxTariff == null) {
      return null;
    }

    double volume = (length * width * height) / 1000.0;
    double logistics =
        calculateLogistics(boxTariff, palletTariff, volume, costData.isBox);

    double commissionPercent = wbTariff.kgvpMarketplace.ceilToDouble();
    double commission = price * (commissionPercent / 100);

    double costOfReturns = 0.0;
    if (costData.returnRate < 100) {
      const double returnLogisticsCost = 50.0;
      costOfReturns = (logistics + returnLogisticsCost) *
          (costData.returnRate / (100 - costData.returnRate));
    }

    double taxCost = price * (costData.taxRate / 100);
    double totalCosts = costData.costPrice +
        costData.delivery +
        costData.packaging +
        costData.paidAcceptance +
        logistics +
        commission +
        costOfReturns +
        taxCost;

    return price - totalCosts;
  }

  double calculateLogistics(WbBoxTariff? tariff, WbPalletTariff? tariffPallet,
      double volume, bool isBox) {
    if (!isBox && tariffPallet != null) {
      return volume < 1
          ? tariffPallet.palletDeliveryValueBase
          : (volume - 1) * tariffPallet.palletDeliveryValueLiter +
              tariffPallet.palletDeliveryValueBase;
    }
    if (isBox && tariff != null) {
      return volume < 1
          ? tariff.boxDeliveryBase
          : (volume - 1) * tariff.boxDeliveryLiter + tariff.boxDeliveryBase;
    }
    return 0.0;
  }

  double? _calcMarginOnce({
    required double? price,
    required ProductCostData? costData,
    required WbTariff? wbTariff,
    required WbBoxTariff? boxTariff,
    required WbPalletTariff? palletTariff,
    required int length,
    required int width,
    required int height,
  }) {
    final profit = _calcProfitOnce(
      price: price,
      costData: costData,
      wbTariff: wbTariff,
      boxTariff: boxTariff,
      palletTariff: palletTariff,
      length: length,
      width: width,
      height: height,
    );
    if (profit == null || profit <= 0 || price == null || price <= 0) {
      return null;
    }
    return (profit / price) * 100.0;
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
      final productCosts = await wbProductCostService.getAllCostWbData();
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

  Future<void> fetchAllStocks() async {
    try {
      warehouses = await sellerWarehousesService.fetchSellerWarehouses();

      // Get all SKUs from all sizes
      final List<String> skus = productCards
          .expand((card) => card.sizes.expand((size) => size.skus))
          .toList();

      if (skus.isEmpty) {
        return;
      }

      stocksByWarehouseAndNmId.clear();
      totalStocksByNmId.clear();
      stocksByChrtId.clear();
      totalStocksWBByNmId.clear();
      wbStocksByWarehouseAndNmId.clear();
      // Fetch seller warehouse stocks
      for (var warehouse in warehouses) {
        final stocks = await warehouseStocksService.fetchSellerStocks(
          warehouseId: warehouse.id,
          skus: skus,
        );

        stocksByWarehouseAndNmId[warehouse.id] = {};
        stocksByChrtId[warehouse.id] = {};

        for (var stock in stocks) {
          // Find the product card and size with matching SKU
          for (var card in productCards) {
            for (var size in card.sizes) {
              if (size.skus.contains(stock.sku)) {
                stocksByWarehouseAndNmId[warehouse.id]![card.nmID] =
                    (stocksByWarehouseAndNmId[warehouse.id]![card.nmID] ?? 0) +
                        stock.amount;
                totalStocksByNmId[card.nmID] =
                    (totalStocksByNmId[card.nmID] ?? 0) + stock.amount;
                stocksByChrtId[warehouse.id]![size.chrtID] = stock.amount;
                break;
              }
            }
          }
        }
      }

      // Fetch WB stocks

      final dateFrom = '2019-06-20';

      final wbStocks = await wbStocksService.fetchStocks(dateFrom);

      for (var stock in wbStocks) {
        // Find the product card with matching nmId
        for (var card in productCards) {
          if (card.nmID == stock.nmId) {
            totalStocksWBByNmId[card.nmID] =
                (totalStocksWBByNmId[card.nmID] ?? 0) + stock.quantity;
            wbStocksByWarehouseAndNmId[card.nmID] ??= {};
            wbStocksByWarehouseAndNmId[card.nmID]![stock.warehouseName] =
                (wbStocksByWarehouseAndNmId[card.nmID]![stock.warehouseName] ??
                        0) +
                    stock.quantity;
            break;
          }
        }
      }

      notifyListeners();
    } catch (e) {
      errorMessage = 'Error fetching stocks: $e';
      notifyListeners();
    }
  }

  // Navigations

  void navTo(int imtID, int nmID) {
    Navigator.of(context).pushNamed(
      MainNavigationRouteNames.productCard,
      arguments: {'imtID': imtID, 'nmID': nmID},
    );
  }

  void onNavigateToSubjectProductsScreen(
      {required int selectedSubjectId, required String selectedSubjectName}) {
    Navigator.of(context).pushNamed(
      MainNavigationRouteNames.subjectProductsScreen,
      arguments: {
        'subjectId': selectedSubjectId,
        'subjectName': selectedSubjectName
      },
    );
  }

  Future<void> loadData() async {
    setLoading();
    errorMessage = null;
    notifyListeners();

    try {
      await fetchAllStocks();

      setLoaded();
      notifyListeners();
    } catch (e) {
      setLoaded();
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  String getWbStockTooltipText(int nmId) {
    //
    if (totalStocksWBByNmId[nmId] == null || totalStocksWBByNmId[nmId] == 0) {
      return "Нет в наличии";
    }

    final Map<String, int>? warehouseStocks = wbStocksByWarehouseAndNmId[nmId];

    if (warehouseStocks == null || warehouseStocks.isEmpty) {
      return "Всего: ${totalStocksWBByNmId[nmId]} шт.";
    }

    final List<String> warehouseBreakdown = [];
    warehouseStocks.forEach((warehouseName, quantity) {
      if (quantity > 0) {
        warehouseBreakdown.add("$warehouseName - $quantity шт.");
      }
    });

    if (warehouseBreakdown.isEmpty) {
      return "Всего: ${totalStocksWBByNmId[nmId]} шт.";
    }

    return warehouseBreakdown.join('\n');
  }
}
