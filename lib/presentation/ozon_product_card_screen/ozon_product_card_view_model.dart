import 'package:flutter/material.dart';
import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';
import 'package:mc_dashboard/domain/entities/ozon_product.dart';
import 'package:mc_dashboard/domain/entities/ozon_price.dart';
import 'package:mc_dashboard/domain/entities/ozon_product_info.dart';
import 'package:mc_dashboard/domain/entities/product_cost_data.dart';
import 'package:mc_dashboard/domain/services/ozon_products_service.dart';

abstract class OzonProductCardOzonPricesService {
  Future<OzonPricesResponse> fetchPrices({
    String? cursor,
    List<String>? offerIds,
    List<int>? productIds,
    String? visibility,
    int? limit,
  });
}

abstract class OzonProductCardOzonProductInfoService {
  Future<OzonProductInfoResponse> fetchProductInfo({
    required List<String> offerIds,
  });
}

abstract class OzonProductCardProductCostService {
  Future<ProductCostData?> getOzonProductCost(int nmID);
  Future<void> saveProductCost(ProductCostData costData);
}

abstract class OzonProductCardOzonPriceService {
  Future<Map<String, dynamic>> updatePrices(List<Map<String, dynamic>> prices);
}

class OzonProductCardViewModel extends ViewModelBase {
  final OzonProductsService _productsService;
  final OzonProductCardOzonPricesService _pricesService;
  final OzonProductCardOzonProductInfoService _productInfoService;
  final OzonProductCardProductCostService _productCostService;
  final OzonProductCardOzonPriceService _ozonPriceService;

  final String offerId;
  final int productId;
  final int sku;
  OzonProduct? _product;
  OzonPrice? _price;
  OzonProductInfo? _productInfo;
  ProductCostData? _productCostData;
  String? _errorMessage;

  bool _isFBO = true;

  OzonProductCardViewModel({
    required OzonProductsService productsService,
    required OzonProductCardOzonPricesService pricesService,
    required OzonProductCardOzonProductInfoService productInfoService,
    required OzonProductCardProductCostService productCostService,
    required OzonProductCardOzonPriceService ozonPriceService,
    required this.offerId,
    required this.productId,
    required this.sku,
    required super.context,
  })  : _productsService = productsService,
        _pricesService = pricesService,
        _productInfoService = productInfoService,
        _productCostService = productCostService,
        _ozonPriceService = ozonPriceService;

  OzonProduct? get product => _product;
  OzonPrice? get price => _price;
  OzonProductInfo? get productInfo => _productInfo;
  ProductCostData? get productCostData => _productCostData;
  String? get errorMessage => _errorMessage;

  bool get isFBO => _isFBO;

  void setDeliveryType(bool isFBO) {
    _isFBO = isFBO;
    if (_productCostData != null) {
      saveProductCost(_productCostData!);
    }
    notifyListeners();
  }

  Map<String, double> calculateForMargin({
    required double desiredMargin,
    required double costPrice,
    required double delivery,
    required double packaging,
    required double paidAcceptance,
    required double totalReturnCost,
    required double logistics,
    required double storage,
    required double commissionPercent,
    required int taxRate,
  }) {
    double finalPrice = 100.0;
    double oldPrice = 0.0;
    int iterationCount = 0;
    const int maxIterations = 20;
    const double epsilon = 0.01;

    while ((finalPrice - oldPrice).abs() > epsilon &&
        iterationCount < maxIterations) {
      iterationCount++;
      oldPrice = finalPrice;

      // Commission calculation
      final double commission = finalPrice * (commissionPercent / 100);

      // Tax calculation
      final double taxCost = finalPrice * (taxRate / 100);

      // Total costs including all expenses
      final double totalCosts = costPrice +
          delivery +
          packaging +
          paidAcceptance +
          totalReturnCost +
          logistics +
          storage +
          commission +
          taxCost;

      // Calculate price based on desired margin
      final double marginRatio = desiredMargin / 100;
      finalPrice = totalCosts / (1 - marginRatio);
    }

    // Final calculations
    final double commission = finalPrice * (commissionPercent / 100);
    final double taxCost = finalPrice * (taxRate / 100);
    final double totalCosts = costPrice +
        delivery +
        packaging +
        paidAcceptance +
        totalReturnCost +
        logistics +
        storage +
        commission +
        taxCost;

    final double netProfit = finalPrice - totalCosts;

    // Break-even price calculation
    final double breakEvenPrice = (totalCosts - taxCost - commission) /
        (1 - (commissionPercent / 100) - (taxRate / 100));

    return {
      "finalPrice": finalPrice,
      "netProfit": netProfit,
      "breakEvenPrice": breakEvenPrice,
      "commission": commission,
      "taxCost": taxCost,
      "totalCosts": totalCosts,
    };
  }

  Map<String, double> getCurrentCommissionValues() {
    if (_price == null) return {};

    return {
      "commissionPercent": _isFBO
          ? (_price!.commissions.salesPercentFbo)
          : (_price!.commissions.salesPercentFbs),
      "returnCost": _isFBO
          ? (_price!.commissions.fboReturnFlowAmount)
          : (_price!.commissions.fbsReturnFlowAmount),
      "deliveryCost": _isFBO
          ? (_price!.commissions.fboDirectFlowTransMaxAmount)
          : (_price!.commissions.fbsDirectFlowTransMaxAmount),
    };
  }

  double calculateTotalOzonFees(double commissionAmount, double deliveryCost) {
    return commissionAmount + deliveryCost;
  }

  @override
  Future<void> asyncInit() async {
    setLoading();
    try {
      await Future.wait([
        _fetchProduct(),
        _fetchPrice(),
        _fetchProductInfo(),
        _fetchProductCost(),
      ]);
    } catch (e) {
      _errorMessage = "Error loading product data: ${e.toString()}";
    }
    setLoaded();
  }

  Future<void> _fetchProduct() async {
    try {
      final response =
          await _productsService.fetchProducts(offerIds: [offerId]);
      if (response.items.isNotEmpty) {
        _product = response.items.first;
      }
    } catch (e) {
      _errorMessage = "Error fetching product: ${e.toString()}";
    }
  }

  Future<void> _fetchPrice() async {
    try {
      final response = await _pricesService.fetchPrices(
        offerIds: [offerId],
        limit: 1000,
      );
      if (response.items.isNotEmpty) {
        _price = response.items.first;
      }
    } catch (e) {
      _errorMessage = "Error fetching price: ${e.toString()}";
    }
  }

  Future<void> _fetchProductInfo() async {
    try {
      final response =
          await _productInfoService.fetchProductInfo(offerIds: [offerId]);
      if (response.items.isNotEmpty) {
        _productInfo = response.items.first;
      }
    } catch (e) {
      _errorMessage = "Error fetching product info: ${e.toString()}";
    }
  }

  Future<void> _fetchProductCost() async {
    try {
      _productCostData =
          await _productCostService.getOzonProductCost(productId);
    } catch (e) {
      _errorMessage = "Error fetching product cost: ${e.toString()}";
    }
  }

  void updateProductCostData({
    required double costPrice,
    required double delivery,
    required double packaging,
    required double paidAcceptance,
    required double returnRate,
    required int taxRate,
    required double desiredMargin1,
    required double desiredMargin2,
    required double desiredMargin3,
  }) async {
    if (_productCostData == null) {
      // Если данных нет, создаем новые
      _productCostData = ProductCostData(
        nmID: productId,
        mpType: "ozon",
        costPrice: costPrice,
        delivery: delivery,
        packaging: packaging,
        paidAcceptance: paidAcceptance,
        returnRate: returnRate,
        taxRate: taxRate,
        desiredMargin1: desiredMargin1,
        desiredMargin2: desiredMargin2,
        desiredMargin3: desiredMargin3,
      );
    } else {
      // Если данные есть, обновляем их
      _productCostData = _productCostData!.copyWith(
        costPrice: costPrice,
        delivery: delivery,
        packaging: packaging,
        paidAcceptance: paidAcceptance,
        returnRate: returnRate,
        taxRate: taxRate,
        desiredMargin1: desiredMargin1,
        desiredMargin2: desiredMargin2,
        desiredMargin3: desiredMargin3,
        mpType: "ozon",
      );
    }

    try {
      await _productCostService.saveProductCost(_productCostData!);
      notifyListeners();
    } catch (e) {
      _errorMessage = "Error updating product cost: ${e.toString()}";
      notifyListeners();
    }
  }

  Future<void> saveProductCost(ProductCostData costData) async {
    try {
      _productCostData = costData.copyWith(mpType: "ozon");
      await _productCostService.saveProductCost(_productCostData!);
      notifyListeners();
    } catch (e) {
      _errorMessage = "Error saving product cost: ${e.toString()}";
      notifyListeners();
    }
  }

  double? calcProfitFbs() {
    if (_price == null || _productCostData == null) return null;
    final price = _price!.price.price;
    // Вознаграждение Ozon
    final commissionAmount =
        price * (_price!.commissions.salesPercentFbs / 100);
    // Эквайринг
    final acquiring = _price!.acquiring;
    // Обработка отправления
    final firstMileMaxAmount = _price!.commissions.fbsFirstMileMaxAmount;
    // Логистика
    final directFlowTransMaxAmaount =
        _price!.commissions.fbsDirectFlowTransMaxAmount;
    // Последняя миля
    final delivToCustomerAmount = _price!.commissions.fbsDelivToCustomerAmount;
    // Возврат или отмена
    final double costOfReturns = _price!.commissions.fbsReturnFlowAmount;
    final double percentOfReturns = _productCostData!.returnRate;
    final returnFlowAmount = _calculateReturnCost(
        logistics: firstMileMaxAmount +
            directFlowTransMaxAmaount +
            delivToCustomerAmount,
        costOfReturns: costOfReturns,
        returnRate: percentOfReturns);
    // Налог
    double taxCost = price * (_productCostData!.taxRate / 100);

    final costs = _productCostData!.costPrice +
        _productCostData!.delivery +
        _productCostData!.packaging +
        _productCostData!.paidAcceptance;

    final totalCosts = costs +
        commissionAmount +
        acquiring +
        firstMileMaxAmount +
        directFlowTransMaxAmaount +
        delivToCustomerAmount +
        returnFlowAmount +
        taxCost;

    return price - totalCosts;
  }

  double? calcProfitFbo() {
    if (_price == null || _productCostData == null) return null;
    final price = _price!.price.price;
    // Вознаграждение Ozon
    final commissionAmount =
        price * (_price!.commissions.salesPercentFbo / 100);
    // Эквайринг
    final acquiring = _price!.acquiring;
    // Обработки отправления нет
    // Логистика
    final directFlowTransMaxAmount =
        _price!.commissions.fboDirectFlowTransMaxAmount;
    // Последняя миля
    final delivToCustomerAmount = _price!.commissions.fboDelivToCustomerAmount;
    // Возврат или отмена
    final double costOfReturns = _price!.commissions.fboReturnFlowAmount;
    final double percentOfReturns = _productCostData!.returnRate;
    final returnFlowAmount = _calculateReturnCost(
        logistics: directFlowTransMaxAmount + delivToCustomerAmount,
        costOfReturns: costOfReturns,
        returnRate: percentOfReturns);
    // Налог
    final double taxCost = price * (_productCostData!.taxRate / 100);

    final costs = _productCostData!.costPrice +
        _productCostData!.delivery +
        _productCostData!.packaging +
        _productCostData!.paidAcceptance;

    final totalCosts = costs +
        commissionAmount +
        acquiring +
        directFlowTransMaxAmount +
        delivToCustomerAmount +
        returnFlowAmount +
        taxCost;

    return price - totalCosts;
  }

  double? calcMarginFbs() {
    final profit = calcProfitFbs();
    if (profit == null || _price == null) return null;
    return (profit / _price!.price.price) * 100;
  }

  double? calcMarginFbo() {
    final profit = calcProfitFbo();
    if (profit == null || _price == null) return null;
    return (profit / _price!.price.price) * 100;
  }

  double _calculateReturnCost(
      {required double logistics,
      required double costOfReturns,
      required double? returnRate}) {
    if (returnRate == null || returnRate >= 100 || costOfReturns == 0) return 0;

    return (logistics + costOfReturns) * (returnRate / (100 - returnRate));
  }

  double get returnCostFbs => _calculateReturnCost(
        logistics: _price!.commissions.fbsFirstMileMaxAmount +
            _price!.commissions.fbsDirectFlowTransMaxAmount +
            _price!.commissions.fbsDelivToCustomerAmount,
        costOfReturns: _price!.commissions.fbsReturnFlowAmount,
        returnRate: _productCostData!.returnRate,
      );

  double get returnCostFbo => _calculateReturnCost(
        logistics: _price!.commissions.fboDirectFlowTransMaxAmount +
            _price!.commissions.fboDelivToCustomerAmount,
        costOfReturns: _price!.commissions.fboReturnFlowAmount,
        returnRate: _productCostData!.returnRate,
      );

  Future<void> updatePrice(double newPrice) async {
    try {
      // Округляем новую цену до целого числа
      final roundedNewPrice = newPrice.round();

      // Определяем минимальную разницу между old_price и price согласно требованиям API
      double minDifference;
      if (roundedNewPrice < 400) {
        minDifference = 20;
      } else if (roundedNewPrice <= 10000) {
        minDifference = roundedNewPrice * 0.06; // 5% от цены
      } else {
        minDifference = 500;
      }

      // Устанавливаем old_price как новую цену плюс минимальная разница
      final effectiveOldPrice = (roundedNewPrice + minDifference).round();

      final priceData = {
        "auto_action_enabled": "UNKNOWN",
        "currency_code": "RUB",
        "min_price": "0",
        "min_price_for_auto_actions_enabled": false,
        "net_price": "0",
        "offer_id": offerId,
        "old_price": effectiveOldPrice.toString(),
        "price": roundedNewPrice.toString(),
        "price_strategy_enabled": "UNKNOWN",
        "product_id": productId,
        "quant_size": 1,
        "vat": "0.1"
      };

      final response = await _ozonPriceService.updatePrices([priceData]);

      if (response['result'] != null && response['result'].isNotEmpty) {
        final result = response['result'][0];
        if (result['updated'] == true) {
          // Обновляем локальное состояние цены
          if (_price != null) {
            _price = _price!.copyWith(
              price: _price!.price.copyWith(
                price: roundedNewPrice.toDouble(),
                oldPrice: effectiveOldPrice.toDouble(),
              ),
            );
          }
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Цена успешно обновлена"),
              ),
            );
          }
          notifyListeners();
        } else {
          _errorMessage =
              "Ошибка при обновлении цены: ${result['errors'][0]['message']}";
          notifyListeners();
        }
      } else {
        _errorMessage = "Неожиданный ответ от сервера";
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Ошибка при обновлении цены: ${e.toString()}";
      notifyListeners();
    }
  }
}
