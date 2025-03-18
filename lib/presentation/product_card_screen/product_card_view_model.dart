import 'package:flutter/material.dart';
import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';
import 'package:mc_dashboard/domain/entities/product_card.dart';
import 'package:mc_dashboard/domain/entities/product_cost_data.dart';
import 'package:mc_dashboard/domain/entities/wb_box_tariff.dart';
import 'package:mc_dashboard/domain/entities/wb_pallet_tariff.dart';
import 'package:mc_dashboard/domain/entities/wb_tariff.dart';

abstract class ProductCardWbContentApiService {
  Future<ProductCard> fetchProductCard({required int imtID, required int nmID});
}

abstract class ProductCardWbTariffsService {
  Future<List<WbTariff>> fetchTariffs({String locale = 'ru'});
  Future<List<WbBoxTariff>> fetchBoxTariffs({required String date});
  Future<List<WbPalletTariff>> fetchPalletTariffs({required String date});
}

abstract class ProductCardWbProductCostService {
  Future<ProductCostData?> getProductCost(int nmID);
  Future<void> saveProductCost(ProductCostData costData);
}

abstract class ProductCardWbPriceService {
  Future<Map<String, dynamic>> uploadPriceTask(
      List<Map<String, dynamic>> priceData);
}

class ProductCardViewModel extends ViewModelBase {
  final ProductCardWbContentApiService contentApiService;
  final ProductCardWbTariffsService tariffsService;
  final ProductCardWbProductCostService productCostService;
  final ProductCardWbPriceService wbPriceService;
  final int imtID;
  final int nmID;

  ProductCard? productCard;
  WbTariff? wbTariff;
  List<WbBoxTariff> boxTariffs = [];
  List<WbPalletTariff> palletTariffs = [];
  double volumeLiters = 0.0;
  String? errorMessage;
  String? selectedWarehouse;

  // Данные о стоимости
  ProductCostData? productCostData;

  ProductCardViewModel({
    required this.contentApiService,
    required this.tariffsService,
    required this.productCostService,
    required this.imtID,
    required this.nmID,
    required this.wbPriceService,
    required super.context,
  });

  @override
  Future<void> asyncInit() async {
    setLoading();
    try {
      await fetchProductCard();
      await fetchTariffs();
      await fetchBoxTariffs();
      await fetchPalletTariffs();
      await loadProductCost();
    } catch (e) {
      errorMessage = "Ошибка: ${e.toString()}";
    }
    setLoaded();
  }

  Future<void> fetchProductCard() async {
    try {
      final card =
          await contentApiService.fetchProductCard(imtID: imtID, nmID: nmID);
      productCard = card;

      volumeLiters = _calculateVolumeLiters();
      print("Volume liters: $volumeLiters");
    } catch (e) {
      errorMessage = "Ошибка загрузки карточки товара: ${e.toString()}";
    }
  }

  Future<void> fetchTariffs() async {
    if (productCard == null) return;
    try {
      final tariffs = await tariffsService.fetchTariffs();
      wbTariff = tariffs.firstWhere(
        (tariff) => tariff.subjectID == productCard!.subjectID,
        orElse: () => WbTariff(
            subjectID: 0,
            kgvpMarketplace: 0,
            paidStorageKgvp: 0,
            kgvpSupplier: 0,
            kgvpSupplierExpress: 0,
            parentID: 0,
            parentName: '',
            subjectName: ''),
      );
    } catch (e) {
      errorMessage = "Ошибка загрузки тарифов: ${e.toString()}";
    }
  }

  Future<void> uploadProductPrices(List<Map<String, dynamic>> priceData) async {
    try {
      await wbPriceService.uploadPriceTask(priceData);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Цена успешно обновлена"),
          ),
        );
      }
      notifyListeners();
    } catch (e) {
      errorMessage = "Ошибка загрузки цен: ${e.toString()}";
    }
  }

  Future<void> fetchBoxTariffs() async {
    try {
      final today = DateTime.now();
      final formattedDate =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
      boxTariffs = await tariffsService.fetchBoxTariffs(date: formattedDate);
    } catch (e) {
      errorMessage = "Ошибка загрузки тарифов на короба: ${e.toString()}";
    }
  }

  Future<void> fetchPalletTariffs() async {
    try {
      final today = DateTime.now();
      final formattedDate =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
      palletTariffs =
          await tariffsService.fetchPalletTariffs(date: formattedDate);
    } catch (e) {
      errorMessage = "Ошибка загрузки тарифов на короба: ${e.toString()}";
    }
  }

  Future<void> loadProductCost() async {
    try {
      productCostData = await productCostService.getProductCost(nmID);

      productCostData ??= ProductCostData(
        nmID: nmID,
        costPrice: 0.0,
        delivery: 0.0,
        packaging: 0.0,
        paidAcceptance: 0.0,
        returnRate: 10.0,
        taxRate: 7,
        desiredMargin1: 30.0,
        desiredMargin2: 35.0,
        desiredMargin3: 40.0,
        warehouseName: "Маркетплейс",
        isBox: true, // По умолчанию "Короб"
      );

      selectedWarehouse = productCostData?.warehouseName ?? "Маркетплейс";

      notifyListeners(); // Обновляем UI
    } catch (e) {
      errorMessage = "Ошибка загрузки данных себестоимости: ${e.toString()}";
    }
  }

  Future<void> saveProductCost(ProductCostData costData) async {
    try {
      print(
          "Save product cost: ${costData.desiredMargin1} ${costData.costPrice} ${costData.desiredMargin3}");
      await productCostService.saveProductCost(costData.copyWith(
        warehouseName: selectedWarehouse,
      ));
      productCostData = costData;
    } catch (e) {
      errorMessage = "Ошибка сохранения данных себестоимости: ${e.toString()}";
    }
  }

  double _calculateVolumeLiters() {
    if (productCard == null) return 0.0;
    return (productCard!.length * productCard!.width * productCard!.height) /
        1000.0;
  }

  void updateProductCostData({
    double? costPrice,
    double? delivery,
    double? packaging,
    double? paidAcceptance,
    double? returnRate,
    int? taxRate,
    double? desiredMargin1,
    double? desiredMargin2,
    double? desiredMargin3,
    String? warehouseName,
    bool? isBox,
  }) {
    if (productCostData == null) return;

    if (warehouseName != null) {
      selectedWarehouse = warehouseName;
    }
    print("updateProductCostData isBox: ${isBox ?? productCostData!.isBox}");
    productCostData = productCostData!.copyWith(
      costPrice: costPrice ?? productCostData!.costPrice,
      delivery: delivery ?? productCostData!.delivery,
      packaging: packaging ?? productCostData!.packaging,
      paidAcceptance: paidAcceptance ?? productCostData!.paidAcceptance,
      returnRate: returnRate ?? productCostData!.returnRate,
      taxRate: taxRate ?? productCostData!.taxRate,
      desiredMargin1: desiredMargin1 ?? productCostData!.desiredMargin1,
      desiredMargin2: desiredMargin2 ?? productCostData!.desiredMargin2,
      desiredMargin3: desiredMargin3 ?? productCostData!.desiredMargin3,
      warehouseName: warehouseName ?? productCostData!.warehouseName,
      isBox: isBox ?? productCostData!.isBox,
    );

    notifyListeners();
  }

  @override
  void dispose() {
    if (productCostData != null) {
      saveProductCost(productCostData!);
    }
    super.dispose();
  }
}

double calculateReturnCost(double logistics, double? returnRate) {
  const double returnLogisticsCost = 50.0;
  if (returnRate == null || returnRate == 100) {
    return 0.0;
  }
  return (logistics + returnLogisticsCost) * (returnRate / (100 - returnRate));
}
