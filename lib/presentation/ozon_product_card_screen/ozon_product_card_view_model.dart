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

class OzonProductCardViewModel extends ViewModelBase {
  final OzonProductsService _productsService;
  final OzonProductCardOzonPricesService _pricesService;
  final OzonProductCardOzonProductInfoService _productInfoService;
  final OzonProductCardProductCostService _productCostService;

  final String offerId;
  final int productId;
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
    required this.offerId,
    required this.productId,
    required super.context,
  })  : _productsService = productsService,
        _pricesService = pricesService,
        _productInfoService = productInfoService,
        _productCostService = productCostService;

  OzonProduct? get product => _product;
  OzonPrice? get price => _price;
  OzonProductInfo? get productInfo => _productInfo;
  ProductCostData? get productCostData => _productCostData;
  String? get errorMessage => _errorMessage;

  bool get isFBO => _isFBO;

  void setDeliveryType(bool isFBO) {
    _isFBO = isFBO;
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
    if (_productCostData == null) return;

    final updatedCostData = ProductCostData(
      nmID: _productCostData!.nmID,
      mpType: _productCostData!.mpType,
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

    try {
      await _productCostService.saveProductCost(updatedCostData);
      _productCostData = updatedCostData;
      notifyListeners();
    } catch (e) {
      _errorMessage = "Error updating product cost: ${e.toString()}";
      notifyListeners();
    }
  }

  Future<void> saveProductCost(ProductCostData costData) async {
    try {
      await _productCostService.saveProductCost(costData);
      _productCostData = costData;

      notifyListeners();
    } catch (e) {
      _errorMessage = "Error saving product cost: ${e.toString()}";
      notifyListeners();
    }
  }

  double? calcProfitFbs() {
    if (_price == null || _productCostData == null) return null;
    final price = _price!.price.price;
    final cost = _productCostData!.costPrice;
    final commission = _price!.commissions.salesPercentFbs;
    final delivery = _price!.commissions.fbsDelivToCustomerAmount;
    final returnRate = _productCostData!.returnRate / 100;
    final taxRate = _productCostData!.taxRate / 100;

    return price * (1 - commission / 100) -
        cost -
        delivery -
        (price * returnRate) -
        (price * taxRate);
  }

  double? calcProfitFbo() {
    if (_price == null || _productCostData == null) return null;
    final price = _price!.price.price;
    final cost = _productCostData!.costPrice;
    final commission = _price!.commissions.salesPercentFbo;
    final delivery = _price!.commissions.fboDelivToCustomerAmount;
    final returnRate = _productCostData!.returnRate / 100;
    final taxRate = _productCostData!.taxRate / 100;

    return price * (1 - commission / 100) -
        cost -
        delivery -
        (price * returnRate) -
        (price * taxRate);
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
}
