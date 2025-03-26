import 'package:flutter/material.dart';
import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';
import 'package:mc_dashboard/domain/entities/ozon_product.dart';
import 'package:mc_dashboard/domain/entities/ozon_price.dart';
import 'package:mc_dashboard/domain/entities/ozon_fbo_stock.dart';
import 'package:mc_dashboard/domain/entities/ozon_fbs_stock.dart';
import 'package:mc_dashboard/domain/entities/ozon_product_info.dart';
import 'package:mc_dashboard/domain/entities/product_cost_data.dart';
import 'package:mc_dashboard/domain/services/ozon_products_service.dart';

import 'package:mc_dashboard/presentation/product_cards_screen/product_cards_view_model.dart';
import 'package:mc_dashboard/routes/main_navigation_route_names.dart';

abstract class OzonFbsStocksService {
  Future<OzonFbsStocksResponse> fetchStocks({
    String? cursor,
    List<String>? offerIds,
    List<int>? productIds,
    String? visibility,
    Map<String, bool>? withQuant,
    int? limit,
  });
}

abstract class OzonProductCardsOzonProductInfoService {
  Future<OzonProductInfoResponse> fetchProductInfo({
    required List<String> offerIds,
  });
}

abstract class OzonProductCardsOzonProductsService {
  Future<OzonProductsResponse> fetchProducts({
    List<String>? offerIds,
    List<int>? productIds,
    String? visibility,
    String? lastId,
    int? limit,
  });
}

abstract class OzonProductCardsOzonFboStocksService {
  Future<OzonFboStocksResponse> fetchStocks({
    List<String>? skus,
    String? stockTypes,
    List<String>? warehouseIds,
    int? limit,
    int? offset,
  });
}

abstract class OzonProductCardsOzonPricesService {
  Future<OzonPricesResponse> fetchPrices({
    String? cursor,
    List<String>? offerIds,
    List<int>? productIds,
    String? visibility,
    int? limit,
  });
}

abstract class OzonProductCardsProductCardsProductCostService {
  Future<List<ProductCostData>> getAllCostOzonData();
}

class OzonProductCardsViewModel extends ViewModelBase {
  final OzonProductsService _productsService;
  final OzonProductCardsOzonPricesService _pricesService;
  final OzonProductCardsOzonFboStocksService _fboStocksService;
  final OzonFbsStocksService _fbsStocksService;
  final OzonProductCardsProductCardsProductCostService _productCostService;
  final OzonProductCardsOzonProductInfoService _productInfoService;
  final ProductCardsViewModel _wbViewModel;

  List<OzonProduct> _productCards = [];
  Map<String, OzonPrice> _prices = {};
  Map<String, OzonFboStock> _fboStocks = {};
  Map<String, OzonFbsStock> _fbsStocks = {};
  Map<int, ProductCostData> productCosts = {};
  Map<String, OzonProductInfo> _productInfo = {};
  bool _isLoading = false;
  String _loadingStatus = '';
  String? _errorMessage;
  final Map<String, String> _costDataSuggestions = {};

  OzonProductCardsViewModel({
    required OzonProductsService productsService,
    required OzonProductCardsOzonPricesService pricesService,
    required OzonProductCardsOzonFboStocksService fboStocksService,
    required OzonFbsStocksService fbsStocksService,
    required OzonProductCardsProductCardsProductCostService productCostService,
    required OzonProductCardsOzonProductInfoService productInfoService,
    required ProductCardsViewModel wbViewModel,
    required super.context,
  })  : _productsService = productsService,
        _pricesService = pricesService,
        _fboStocksService = fboStocksService,
        _productCostService = productCostService,
        _fbsStocksService = fbsStocksService,
        _productInfoService = productInfoService,
        _wbViewModel = wbViewModel;

  List<OzonProduct> get productCards => _productCards;
  Map<String, OzonPrice> get prices => _prices;
  Map<String, OzonFboStock> get fboStocks => _fboStocks;
  Map<String, OzonFbsStock> get fbsStocks => _fbsStocks;
  Map<String, OzonProductInfo> get productInfo => _productInfo;
  String get loadingStatus => _loadingStatus;
  String? get errorMessage => _errorMessage;
  Map<String, String> get costDataSuggestions => _costDataSuggestions;

  @override
  void setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  @override
  Future<void> asyncInit() async {
    if (!_isLoading) {
      _isLoading = true;
      await loadData();
      _isLoading = false;
    }
  }

  Future<void> loadData() async {
    try {
      // Fetch products
      _loadingStatus = 'Загрузка товаров...';
      try {
        final productsResponse =
            await _productsService.fetchProducts(limit: 1000);

        if (productsResponse.items.isEmpty) {
          setError(
              'No products found. Please check your Ozon API credentials and permissions.');
          return;
        }
        final costDataList = await _productCostService.getAllCostOzonData();

        for (var c in costDataList) {
          productCosts[c.nmID] = c;
        }

        _productCards = productsResponse.items;

        // Check for missing cost data and find suggestions
        for (var product in _productCards) {
          final offerId = product.offerId;
          final costData = productCosts[int.tryParse(offerId) ?? 0];

          if (costData == null) {
            // Look for matching WB product
            try {
              final wbProduct = _wbViewModel.productCards.firstWhere(
                (card) => card.vendorCode == offerId,
              );

              final wbCostData = _wbViewModel.productCosts[wbProduct.nmID];
              if (wbCostData != null) {
                _costDataSuggestions[offerId] =
                    'Использовать расходы из Wildberries (${wbCostData.costPrice} ₽)';
              }
            } catch (e) {
              // No matching WB product found
            }
          }
        }
      } catch (e) {
        setError('Error fetching products: $e');
        return;
      }

      // Rest of the code...
      final offerIds = _productCards.map((p) => p.offerId).toList();

      try {
        _loadingStatus = 'Загрузка цен...';
        final pricesResponse = await _pricesService.fetchPrices(
          offerIds: offerIds,
          limit: 1000,
        );
        _prices = {
          for (var price in pricesResponse.items) price.offerId: price
        };
      } catch (e) {
        setError('Error fetching prices: $e');
      }

      try {
        _loadingStatus = 'Загрузка остатков FBO...';

        if (_productCards.length <= 1000) {
          // For small number of products, fetch all at once
          final fboStocksResponse = await _fboStocksService.fetchStocks(
            limit: _productCards.length,
            offset: 0,
          );

          // Group stocks by offer_id and sum up valid_stock_count
          final Map<String, int> offerStocks = {};
          for (var stock in fboStocksResponse.items) {
            offerStocks[stock.offerId] =
                (offerStocks[stock.offerId] ?? 0) + stock.validStockCount;
          }

          // Create OzonFboStock objects with summed counts
          _fboStocks = {
            for (var entry in offerStocks.entries)
              entry.key: OzonFboStock(
                offerId: entry.key,
                sku: 0,
                name: '',
                warehouseName: '',
                validStockCount: entry.value,
                waitingDocsStockCount: 0,
                expiringStockCount: 0,
                defectStockCount: 0,
              )
          };
        } else {
          // For large number of products, use pagination
          final allStocks = <OzonFboStock>[];
          int offset = 0;
          const limit = 1000;
          bool hasMore = true;

          while (hasMore) {
            try {
              final fboStocksResponse = await _fboStocksService.fetchStocks(
                limit: limit,
                offset: offset,
              );

              if (fboStocksResponse.items.isEmpty) {
                hasMore = false;
                break;
              }

              allStocks.addAll(fboStocksResponse.items);
              offset += limit;
              _loadingStatus =
                  'Загрузка остатков FBO: ${allStocks.length} товаров...';

              // Only wait if we have more items to fetch
              if (hasMore && offset < _productCards.length) {
                await Future.delayed(const Duration(minutes: 1));
              }
            } catch (e) {
              if (e.toString().contains('429')) {
                await Future.delayed(const Duration(minutes: 1));
              } else {
                hasMore = false;
              }
            }
          }

          _fboStocks = {for (var stock in allStocks) stock.offerId: stock};
        }
      } catch (e) {
        setError('Error fetching FBO stocks: $e');
      }

      try {
        _loadingStatus = 'Загрузка остатков FBS...';
        final fbsStocksResponse = await _fbsStocksService.fetchStocks(
          offerIds: offerIds,
          limit: 1000,
        );
        _fbsStocks = {
          for (var item in fbsStocksResponse.items)
            item.offerId: item.stocks.where((e) => e.type == 'fbs').isEmpty
                ? OzonFbsStock(
                    sku: 0,
                    present: 0,
                    reserved: 0,
                    shipmentType: '',
                    type: '',
                  )
                : item.stocks.where((e) => e.type == 'fbs').first
        };
        final productInfoResponse = await _productInfoService.fetchProductInfo(
          offerIds: offerIds,
        );
        _productInfo = {
          for (var item in productInfoResponse.items) item.offerId: item
        };
      } catch (e) {
        setError('Error fetching FBS stocks: $e');
      }

      _loadingStatus = '';
    } catch (e) {
      setError(e.toString());
      _loadingStatus = '';
    }
  }

  double? calcProfitFbs(String offerId) {
    final price = prices[offerId]?.price.price;
    final commission = prices[offerId]?.commissions;
    final priceId = prices[offerId]?.productId;
    final costData = productCosts[priceId];
    if (price == null || commission == null || costData == null) {
      return null;
    }

    // Вознаграждение Ozon
    double commissionAmount = price * (commission.salesPercentFbs / 100);
    // Эквайринг
    final acquiring = prices[offerId]?.acquiring ?? 0;
    // Обработка отправления
    final firstMileMaxAmount = commission.fbsFirstMileMaxAmount;
    // Логистика
    final directFlowTransMaxAmount = commission.fbsDirectFlowTransMaxAmount;
    // Последняя миля
    final delivToCustomerAmount = commission.fbsDelivToCustomerAmount;
    // Возврат или отмена
    final double costOfReturns = commission.fbsReturnFlowAmount;
    final double percentOfReturns = costData.returnRate;
    final returnFlowAmount = _calculateReturnCost(
        logistics: firstMileMaxAmount +
            directFlowTransMaxAmount +
            delivToCustomerAmount,
        costOfReturns: costOfReturns,
        returnRate: percentOfReturns);
    // Налог
    double taxCost = price * (costData.taxRate / 100);

    double costs = costData.costPrice +
        costData.delivery +
        costData.packaging +
        costData.paidAcceptance;

    final totalCosts = costs +
        commissionAmount +
        acquiring +
        firstMileMaxAmount +
        directFlowTransMaxAmount +
        delivToCustomerAmount +
        returnFlowAmount +
        taxCost;
    return price - totalCosts;
  }

  double? calcProfitFbo(String offerId) {
    final price = prices[offerId]?.price.price;
    final priceId = prices[offerId]?.productId;
    final commission = prices[offerId]?.commissions;
    final costData = productCosts[priceId];
    if (price == null || commission == null || costData == null) {
      return null;
    }

    // Вознаграждение Ozon
    double commissionAmount = price * (commission.salesPercentFbo / 100);
    // Эквайринг
    final acquiring = prices[offerId]?.acquiring ?? 0;
    // Обработки отправления нет
    // Логистика
    final directFlowTransMaxAmount = commission.fboDirectFlowTransMaxAmount;
    // Последняя миля
    final delivToCustomerAmount = commission.fboDelivToCustomerAmount;
    // Возврат или отмена
    final double costOfReturns = commission.fboReturnFlowAmount;
    final double percentOfReturns = costData.returnRate;
    final returnFlowAmount = _calculateReturnCost(
        logistics: directFlowTransMaxAmount + delivToCustomerAmount,
        costOfReturns: costOfReturns,
        returnRate: percentOfReturns);
    // Налог
    double taxCost = price * (costData.taxRate / 100);

    double costs = costData.costPrice +
        costData.delivery +
        costData.packaging +
        costData.paidAcceptance;

    final totalCosts = costs +
        commissionAmount +
        acquiring +
        directFlowTransMaxAmount +
        delivToCustomerAmount +
        returnFlowAmount +
        taxCost;
    return price - totalCosts;
  }

  double? calcMarginFbs(String offerId) {
    final profit = calcProfitFbs(offerId);
    final price = prices[offerId]?.price.price;
    if (profit == null || profit <= 0 || price == null || price <= 0) {
      return null;
    }
    return (profit / price) * 100.0;
  }

  double? calcMarginFbo(String offerId) {
    final profit = calcProfitFbo(offerId);
    final price = prices[offerId]?.price.price;

    if (profit == null || profit <= 0 || price == null || price <= 0) {
      return null;
    }
    return (profit / price) * 100.0;
  }

  double _calculateReturnCost(
      {required double logistics,
      required double costOfReturns,
      required double? returnRate}) {
    if (returnRate == null || returnRate >= 100 || costOfReturns == 0) return 0;

    return (logistics + costOfReturns) * (returnRate / (100 - returnRate));
  }

  void navToOzonProductCardScreen(int productId, String offerId) {
    Navigator.pushNamed(context, MainNavigationRouteNames.ozonProductCardScreen,
        arguments: {'productId': productId, 'offerId': offerId});
  }
}
