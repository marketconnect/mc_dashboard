import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';
import 'package:mc_dashboard/core/utils/basket_num.dart';
import 'package:mc_dashboard/core/utils/similarity.dart';
import 'package:mc_dashboard/core/utils/strings_ext.dart';
import 'package:mc_dashboard/domain/entities/box_tariff.dart';
import 'package:mc_dashboard/domain/entities/card_info.dart';
import 'package:mc_dashboard/domain/entities/detailed_order_item.dart';
import 'package:mc_dashboard/domain/entities/feedback_info.dart';
import 'package:mc_dashboard/domain/entities/key_phrase.dart';
import 'package:mc_dashboard/domain/entities/kw_lemmas.dart';
import 'package:mc_dashboard/domain/entities/lemmatize.dart';
import 'package:mc_dashboard/domain/entities/normquery_product.dart';
import 'package:mc_dashboard/domain/entities/order.dart';
import 'package:mc_dashboard/domain/entities/stock.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/domain/entities/tariff.dart';
import 'package:mc_dashboard/domain/entities/token_info.dart';
import 'package:mc_dashboard/domain/entities/warehouse.dart';
import 'package:mc_dashboard/domain/entities/wb_product.dart';

import 'package:mc_dashboard/presentation/product_screen/table_row_model.dart';
import 'package:mc_dashboard/routes/main_navigation_route_names.dart';

// Stocks service
abstract class ProductViewModelStocksService {
  Future<Either<AppErrorBase, List<Stock>>> getMonthStocks({
    int? productId,
  });
}

// Orders service
abstract class ProductViewModelNormqueryService {
  Future<Either<AppErrorBase, List<NormqueryProduct>>> get(
      {required List<int> ids});
}

// Orders service
abstract class ProductViewModelOrderService {
  Future<Either<AppErrorBase, List<OrderWb>>> getOneMonthOrders({
    int? productId,
  });
}

// Warehouses service
abstract class ProductViewModelWhService {
  Future<Either<AppErrorBase, List<Warehouse>>> getWarehouses({
    required List<int> ids,
  });
}

// Auth service
abstract class ProductAuthService {
  Future<Either<AppErrorBase, TokenInfo>> getTokenInfo();
  // String? getPaymentUrl();
  logout();
}

// Kw lemma service
abstract class ProductViewModelKwLemmaService {
  Future<Either<AppErrorBase, List<KwLemmaItem>>> get({required List<int> ids});
}

// Lemmatize service
abstract class ProductViewModelLemmatizeService {
  Future<Either<AppErrorBase, LemmatizeResponse>> get(
      {required LemmatizeRequest req});
}

// Detailed Orders service
abstract class ProductViewModelDetailedOrdersService {
  Future<Either<AppErrorBase, List<DetailedOrderItem>>> fetchDetailedOrders({
    int? subjectId,
    int? productId,
    int? isFbs,
    String pageSize = '10000',
  });
}

// Saved key phrases service
abstract class ProductViewModelSavedKeyPhrasesService {
  Future<Either<AppErrorBase, void>> addPhrases({
    required String token,
    required List<KeyPhrase> phrases,
  });
}

abstract class ProductViewModelTariffsService {
  Future<Either<AppErrorBase, List<Tariff>>> fetchTariffs({
    required String token,
    String locale,
  });
  Future<Either<AppErrorBase, List<BoxTariff>>> fetchBoxTariffs({
    required String token,
    required String date,
  });
}

abstract class ProductViewModelApiKeyService {
  Future<String?> getWbToken();
}

abstract class WbProductsService {
  Future<Either<AppErrorBase, List<WbProduct>>> fetchProducts(List<int> nmIds);
}

class ProductViewModel extends ViewModelBase {
  ProductViewModel(
      {required super.context,
      required this.productId,
      required this.stocksService,
      required this.whService,
      required this.ordersService,
      required this.authService,
      required this.normqueryService,
      required this.kwLemmaService,
      required this.detailedOrdersService,
      required this.lemmatizeService,
      required this.tariffsService,
      required this.apiKeyService,
      required this.wbProductsService,
      required this.productPrice});
  final int productId;
  final int productPrice;

  final ProductViewModelStocksService stocksService;
  final ProductViewModelApiKeyService apiKeyService;
  final ProductViewModelTariffsService tariffsService;
  final WbProductsService wbProductsService;
  final ProductViewModelOrderService ordersService;
  final ProductViewModelWhService whService;
  final ProductViewModelNormqueryService normqueryService;
  final ProductAuthService authService;
  final ProductViewModelKwLemmaService kwLemmaService;
  final ProductViewModelLemmatizeService lemmatizeService;
  final ProductViewModelDetailedOrdersService detailedOrdersService;

  // Fields ////////////////////////////////////////////////////////////////////

  // tariffs
  // List<Tariff> _tariffs = [];
  // List<Tariff> get tariffs => _tariffs;

  // token and sub info
  TokenInfo? _tokenInfo;
  bool get isFree => _tokenInfo == null || _tokenInfo!.type == "free";

  // get tariffs for product
  Tariff? _productTariff;
  Tariff? get productTariff => _productTariff;
  Tariff? getProductTariff(List<Tariff> tariffs) {
    if (_subjectId == 0) return null;

    final t = tariffs.where((e) {
      return e.subjectID == _subjectId;
    });
    return t.isNotEmpty ? t.first : null;
  }

  int _price = 0;
  int get price => _price == 0 ? productPrice : _price;
  // logistics tariff
  double _logisticsTariff = 0.0;
  double get logisticsTariff => _logisticsTariff;

  // basket num
  String? _basketNum;

  // total orders in 30 days
  int orders30d = 0;

  // rating
  String _rating = "0.0";
  String get rating => _rating;

  // pics
  int _pics = 1;

  // rating distribution
  Map<String, int> ratingDistribution = {};

  // name
  String _name = "";
  String get name => _name;

  // description
  String _description = "";
  String get description => _description;

  // characteristics
  String _characteristics = "";
  String get characteristics => _characteristics;

  String _characteristicValues = "";

  // subject id
  int _subjectId = 0;
  int get subjectId => _subjectId;

  // subject
  String _subjectName = "";
  String get subjectName => _subjectName;

  int _supplierId = 0;
  String _brand = "";

  // images
  final List<String> _images = [];
  List<String> get images =>
      _images.map((el) => el.replaceAll("c246x328", "big")).toList();

  // kw lemmas
  final List<KwLemmaItem> _kwLemmas = [];
  List<KwLemmaItem> get kwLemmas => _kwLemmas;

  // warehouse shares
  List<Map<String, dynamic>> _warehouseShares = [];
  List<Map<String, dynamic>> get warehouseShares => _warehouseShares;

  // total wh stocks
  int _totalWhStocks = 0;
  int get totalWhStocks => _totalWhStocks;

  // orders
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> get orders => _orders;

  // prices
  List<Map<String, dynamic>> _priceHistory = [];
  List<Map<String, dynamic>> get priceHistory => _priceHistory;

  // warehouses
  Map<String, double> _warehousesOrdersSum = {};
  Map<String, double> get warehousesOrdersSum => _warehousesOrdersSum;

  // Stocks
  Map<String, int> _dailyStocksSums = {};
  Map<String, int> get dailyStocksSums => _dailyStocksSums;

  // Used Normqueries
  List<NormqueryProduct> _normqueries = [];
  List<NormqueryProduct> get normqueries => _normqueries;

  // Unused Normqueries
  List<NormqueryProduct> _unusedNormqueries = [];
  List<NormqueryProduct> get unusedNormqueries => _unusedNormqueries;

  int _wbDiscount = 0; // Скидка в %
  double _returnRate = 10.0;
  int get wbDiscount => _wbDiscount;
  double get returnRate => _returnRate;
  void increaseDiscount() {
    _wbDiscount += 1;
    notifyListeners();
  }

  void decreaseDiscount() {
    if (_wbDiscount > 0) {
      _wbDiscount -= 1;
      notifyListeners();
    }
  }

  void increaseReturnRate() {
    if (_returnRate < 100) {
      _returnRate += 1.0;
      notifyListeners();
    }
  }

  void decreaseReturnRate() {
    if (_returnRate > 0) {
      _returnRate -= 1.0;
      notifyListeners();
    }
  }

  double calculateNetProfit() {
    if (productPrice == 0 || productTariff == null || logisticsTariff == 0) {
      return 0.0;
    }
    final discountedPrice = productPrice + (productPrice * (_wbDiscount / 100));
    final commission = (productPrice * productTariff!.paidStorageKgvp) / 100;
    final netProfit = discountedPrice - commission - logisticsTariff;
    return netProfit;
  }

  // pros and cons
  List<String> pros = [];
  List<String> cons = [];

  String _lemmatizedName = "";
  String _lemmatizedDescription = "";
  String _lemmatizedCharacteristics = "";

  // Seo table rows
  final Map<String, List<SEOTableRowModel>> _seoTableSections = {};
  Map<String, List<SEOTableRowModel>> get seoTableSections => _seoTableSections;

  bool _normqueriesLoaded = false;
  bool get normqueriesLoaded => _normqueriesLoaded;

  bool _seoLoaded = false;
  bool get seoLoaded => _seoLoaded;

  bool _unusedQueriesLoaded = false;
  bool get unusedQueriesLoaded => _unusedQueriesLoaded;
  // setters ///////////////////////////////////////////////////////////////////
  void setKwLemmas(List<KwLemmaItem> value) {
    _kwLemmas.clear();
    _kwLemmas.addAll(value);
  }

  void setSeoTableSections(Map<String, List<SEOTableRowModel>> value) =>
      _seoTableSections.addAll(value);

  void setPros(List<String> value) {
    // lowercase
    value = value.map((e) => e.toLowerCase()).toList();
    final n = value.length > 30 ? 30 : value.length;

    Set<String> set = Set.from(value.sublist(0, n));
    pros = set.toList();
  }

  void setCons(List<String> value) {
    // lowercase
    value = value.map((e) => e.toLowerCase()).toList();
    final n = value.length > 30 ? 30 : value.length;

    Set<String> set = Set.from(value.sublist(0, n));
    cons = set.toList();
  }

  double heightOfScreen = 0;
  // Methods ///////////////////////////////////////////////////////////////////
  @override
  Future<void> asyncInit() async {
    print("Init product view model");
    // heightOfScreen = MediaQuery.of(context).size.height;
    _basketNum = getBasketNum(productId);

    final vals = await Future.wait([
      fetchCardInfo(
          calculateCardUrl(calculateImageUrl(_basketNum, productId))), // 0
      authService.getTokenInfo(), // 1
      apiKeyService.getWbToken()
    ]);

    // card info
    final cardInfo = vals[0] as CardInfo;
    _pics = cardInfo.photoCount;
    _name = cardInfo.imtName;

    _description = cardInfo.description;

    _characteristics = cardInfo.characteristicFull;
    _characteristicValues = cardInfo.characteristicValues;
    _subjectId = cardInfo.subjId;

    _subjectName = cardInfo.subjName;
    _supplierId = cardInfo.supplierId;
    _brand = cardInfo.brand;

    // token and sub info
    final tokenInfoOrEither = vals[1] as Either<AppErrorBase, TokenInfo>;

    if (tokenInfoOrEither.isLeft()) {
      final error =
          tokenInfoOrEither.fold((l) => l, (r) => throw UnimplementedError());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error.message ?? 'Unknown error'),
        ));
      }

      return;
    }

    _tokenInfo =
        tokenInfoOrEither.fold((l) => throw UnimplementedError(), (r) => r);

    // get tariffs for product
    final token = vals[2] as String?;
    if (token != null) {
      final tariffs = await loadTariffs(token);
      if (tariffs != null) {
        _productTariff = getProductTariff(tariffs);
      }

      // details
      final a = await wbProductsService.fetchProducts([productId]);

      if (a.isRight()) {
        final volume =
            a.fold((l) => throw UnimplementedError(), (r) => r.first.volume);
        _price = a.fold(
            (l) => throw UnimplementedError(), (r) => r.first.price.toInt());
        // fetchBoxTariffs
        final date = getTomorrowDate();
        final boxTariffsOrEither =
            await tariffsService.fetchBoxTariffs(token: token, date: date);
        if (boxTariffsOrEither.isLeft()) {
          final err = boxTariffsOrEither.fold(
              (l) => l, (r) => throw UnimplementedError());
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(err.message ?? 'Unknown error'),
            ));
          }
          notifyListeners();
          return;
        }
        if (boxTariffsOrEither.isRight()) {
          final boxTariffs = boxTariffsOrEither.fold(
              (l) => throw UnimplementedError(), (r) => r);
          // _boxTariffs = getBoxTariff(boxTariffs, volume);
          final fbsBoxTarrif = boxTariffs
              .where((e) => e.warehouseName == "Маркетплейс")
              .toList();

          if (fbsBoxTarrif.isNotEmpty) {
            final boxDeliveryBase = fbsBoxTarrif.first.boxDeliveryBase;
            final boxDeliveryLiter = fbsBoxTarrif.first.boxDeliveryLiter;
            _logisticsTariff = calculateTariff(
                volume.toDouble(), boxDeliveryBase, boxDeliveryLiter);
          } else {}

          if (fbsBoxTarrif.isNotEmpty) {
            final boxDeliveryBase = fbsBoxTarrif.first.boxDeliveryBase;
            final boxDeliveryLiter = fbsBoxTarrif.first.boxDeliveryLiter;
            _logisticsTariff = calculateTariff(
                volume.toDouble(), boxDeliveryBase, boxDeliveryLiter);
          }
        }
      }
    }
    // final tariffs = vals[2] as List<Tariff>;
    final values = await Future.wait([
      fetchFeedbacks(cardInfo.imtId), // 0
      ordersService.getOneMonthOrders(productId: productId), // 1
      stocksService.getMonthStocks(productId: productId), // 2
    ]);
    final feedbackInfo = values[0] as FeedbackInfo;
    List<int> whIds = [];
    // Orders
    final ordersEither = values[1] as Either<AppErrorBase, List<OrderWb>>;
    List<OrderWb> orders = [];
    if (ordersEither.isRight()) {
      orders = ordersEither.fold((l) => <OrderWb>[], (r) => r);
      _orders = aggregateOrdersByDay(orders);
      _priceHistory = aggregatePricesByDay(orders);

      whIds.addAll(orders.map((e) => e.warehouseId));
      // sum all orders
      orders30d = getTotalOrders(orders);
    }

    // Stocks
    final stocksOrEither = values[2] as Either<AppErrorBase, List<Stock>>;
    List<Stock> stocks = [];
    if (stocksOrEither.isRight()) {
      stocks = stocksOrEither.fold((l) => <Stock>[], (r) => r);
      whIds.addAll(stocks.map((e) => e.warehouseId));
      _dailyStocksSums = calculateDailyStockSums(stocks);
    }

    // free ////////////////////////////////////////////////////// free
    // _normqueries = generateRandomNormqueryProducts(15);
    // final randomSeoTableSections = generateRandomSEOTableRows(15);
    // setSeoTableSections(randomSeoTableSections);
    List<NormqueryProduct> uNormqueries = [];
    for (final normquery in _normqueries) {
      uNormqueries.add(normquery);
    }
    _unusedNormqueries = uNormqueries;

    final whOrEither =
        await whService.getWarehouses(ids: whIds.toSet().toList());
    if (whOrEither.isRight()) {
      final warehousesList =
          whOrEither.fold((l) => throw UnimplementedError, (r) => r);
      final whShares = calculateWarehouseShares(stocks, warehousesList);
      _warehouseShares = whShares.$1;
      _totalWhStocks = whShares.$2;
      _warehousesOrdersSum = getTotalOrdersByWarehouse(orders, warehousesList);
    }

    final image = calculateImageUrl(_basketNum, productId);
    _images.add(image);

    ratingDistribution = feedbackInfo.valuationDistributionPercent;

    _rating = feedbackInfo.valuation;
    setPros(feedbackInfo.pros);
    setCons(feedbackInfo.cons);

    for (int i = 2; i <= _pics; i++) {
      final imageNext = image.replaceFirst('/1.webp', '/$i.webp');
      _images.add(imageNext);
    }
  } // _asyncInit

  Future<void> loadNormqueries() async {
    // Normqueries
    final normqueryOrEither = await normqueryService.get(ids: [productId]);
    if (normqueryOrEither.isRight()) {
      _normqueries =
          normqueryOrEither.fold((l) => <NormqueryProduct>[], (r) => r);
    }
    final normqueryIds = _normqueries.map((e) => e.normqueryId).toList();
    final kwLemmasOrEither = await kwLemmaService.get(ids: normqueryIds);
    //
    if (kwLemmasOrEither.isRight()) {
      final kwLemmas = kwLemmasOrEither.fold((l) => <KwLemmaItem>[], (r) => r);
      setKwLemmas(kwLemmas);
    }

    _normqueriesLoaded = true;
    notifyListeners();
  }

  Future<void> loadSeo() async {
    // Здесь вызываете lemmatizeService + формируете _seoTableSections
    final lemmatizedOrEither = await lemmatizeService.get(
      req: LemmatizeRequest(
        title: _name,
        characteristics: _characteristicValues,
        description: _description,
      ),
    );

    if (lemmatizedOrEither.isRight()) {
      // create cosine similarity
      final lemmatized =
          lemmatizedOrEither.fold((l) => throw UnimplementedError, (r) => r);
      _lemmatizedName = lemmatized.title;
      _lemmatizedDescription = lemmatized.description;
      _lemmatizedCharacteristics = lemmatized.characteristics;
      final fetchedSeoTableSections = await generateSEOTableSections(
          _normqueries,
          _kwLemmas,
          _lemmatizedName,
          _lemmatizedDescription,
          _lemmatizedCharacteristics,
          calculateCosineSimilarity);

      setSeoTableSections(fetchedSeoTableSections);
    }
    _seoLoaded = true;
    notifyListeners();
  }

  Future<void> loadUnusedQueries() async {
    // Unused queries
    // get top 20 products ids
    final detailedOrdersForUnusedQueriesOrEither = await detailedOrdersService
        .fetchDetailedOrders(subjectId: subjectId, isFbs: 0, pageSize: '20');

    if (detailedOrdersForUnusedQueriesOrEither.isRight()) {
      final detailedOrdersForUnusedQueries =
          detailedOrdersForUnusedQueriesOrEither.fold(
              (l) => throw UnimplementedError, (r) => r);
      final top20productsIds =
          detailedOrdersForUnusedQueries.map((e) => e.productId).toList();
      // get top 20 normqueries
      final normqueryOrEither =
          await normqueryService.get(ids: top20productsIds);
      if (normqueryOrEither.isRight()) {
        final fetchedNormqueries =
            normqueryOrEither.fold((l) => throw UnimplementedError, (r) => r);
        List<NormqueryProduct> uNormqueries = [];
        // exclude normqueries that are already used
        for (final normquery in fetchedNormqueries) {
          if ((!_normqueries
                  .any((e) => e.normqueryId == normquery.normqueryId) &&
              !uNormqueries
                  .any((e) => e.normqueryId == normquery.normqueryId))) {
            uNormqueries.add(normquery);
          }
        }
        _unusedNormqueries = uNormqueries.toSet().toList();
      }
    }

    _unusedQueriesLoaded = true;
    notifyListeners();
  }

  String getSeoNameDescChar(String name) {
    final keys = seoTableSections.keys.toList();
    int pos = 0;
    double titleSim = 0;
    double descSim = 0;
    double charSim = 0;
    for (int i = 0; i < keys.length; i++) {
      final seoSectionRows = seoTableSections[keys[i]]!;
      for (int j = 0; j < seoSectionRows.length; j++) {
        if (seoSectionRows[j].normquery == name) {
          pos = seoSectionRows[j].pos;
          if (keys[i] == 'title') {
            titleSim = seoSectionRows[j].titleSimilarity;
          } else if (keys[i] == 'description') {
            descSim = seoSectionRows[j].descriptionSimilarity;
          } else if (keys[i] == 'characteristics') {
            charSim = seoSectionRows[j].characteristicsSimilarity;
          }
        }
      }
    }

    return 'Заголовок:${(titleSim * 100).toStringAsFixed(1)}% Описание:${(descSim * 100).toStringAsFixed(1)}% Характеристики:${(charSim * 100).toStringAsFixed(1)}%; Место:$pos';
  }

  Future<List<Tariff>?> loadTariffs(String token) async {
    // Получаем токен Wildberries через ApiKeyService

    // Запрашиваем тарифы
    final tariffsOrEither = await tariffsService.fetchTariffs(
      token: token,
      locale: "ru",
    );

    if (tariffsOrEither.isRight()) {
      return tariffsOrEither.fold((l) => [], (r) => r);
    }

    notifyListeners();
    return null;
  }

  // Navigation
  void onNavigateToEmptyProductScreen() {
    Navigator.of(context).pushNamed(
      MainNavigationRouteNames.emptyProductScreen,
    );
  }

  void onNavigateBack() {
    Navigator.of(context).pop();
  }

  void onNavigateToSubjectProductsScreen() {
    Navigator.of(context).pushNamed(
      MainNavigationRouteNames.subjectProductsScreen,
      arguments: {'subjectId': _subjectId, 'subjectName': _subjectName},
    );
  }

  void onNavigateToSubscriptionScreen() {
    Navigator.of(context).pushNamed(
      MainNavigationRouteNames.subscriptionScreen,
    );
  }
}

double calculateTariff(
    double volumeLiters, double boxDeliveryBase, double boxDeliveryLiter) {
  volumeLiters /= 10; // Делим на 10, чтобы привести к исходному значению
  if (volumeLiters <= 1) {
    return boxDeliveryBase;
  }
  return (volumeLiters - 1) * boxDeliveryLiter + boxDeliveryBase;
}
