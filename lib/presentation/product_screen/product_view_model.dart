import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';
import 'package:mc_dashboard/core/utils/basket_num.dart';
import 'package:mc_dashboard/domain/entities/card_info.dart';
import 'package:mc_dashboard/domain/entities/feedback_info.dart';
import 'package:mc_dashboard/domain/entities/normquery_product.dart';
import 'package:mc_dashboard/domain/entities/order.dart';
import 'package:mc_dashboard/domain/entities/stock.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/domain/entities/warehouse.dart';

abstract class ProductViewModelStocksService {
  Future<Either<AppErrorBase, List<Stock>>> getMonthStocks({
    int? productId,
  });
}

abstract class ProductViewModelNormqueryService {
  Future<Either<AppErrorBase, List<NormqueryProduct>>> get(
      {required List<int> ids});
}

abstract class ProductViewModelOrderService {
  Future<Either<AppErrorBase, List<OrderWb>>> getOneMonthOrders({
    int? productId,
  });
}

abstract class ProductViewModelWhService {
  Future<Either<AppErrorBase, List<Warehouse>>> getWarehouses({
    required List<int> ids,
  });
}

abstract class ProductAuthService {
  Future<Either<AppErrorBase, Map<String, String?>>> getTokenAndType();
  String? getPaymentUrl();
}

class ProductViewModel extends ViewModelBase {
  ProductViewModel(
      {required super.context,
      required this.productId,
      required this.stocksService,
      required this.whService,
      required this.onNavigateBack,
      required this.ordersService,
      required this.authService,
      required this.normqueryService,
      required this.onNavigateToEmptyProductScreen,
      required this.productPrice}) {
    _asyncInit();
  }
  final int productId;
  final int productPrice;
  final ProductViewModelStocksService stocksService;
  final ProductViewModelOrderService ordersService;
  final ProductViewModelWhService whService;
  final ProductViewModelNormqueryService normqueryService;
  final ProductAuthService authService;
  final void Function() onNavigateBack;
  final void Function() onNavigateToEmptyProductScreen;

  // Fields

  Map<String, String?> _tokenInfo = {};
  Map<String, String?> get tokenInfo => _tokenInfo;

  bool get isFree => _tokenInfo["type"] == "free";

  String? _paymentUrl;
  String? get paymentUrl => _paymentUrl;

  String? _basketNum;
  String _name = "";
  String _subjectName = "";
  String _rating = "0.0";
  String get rating => _rating;
  final List<String> _images = [];
  int orders30d = 0;
  int _pics = 1;
  Map<String, int> ratingDistribution = {};
  String get name => _name;
  String get subjectName => _subjectName;
  List<String> get images =>
      _images.map((el) => el.replaceAll("c246x328", "big")).toList();
  List<String> pros = [];

  // final List<Stock> _stocks = [];
  // List<Stock> get stocks => _stocks;
  List<Map<String, dynamic>> _warehouseShares = [];
  List<Map<String, dynamic>> get warehouseShares => _warehouseShares;
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

  // Normqueries
  List<NormqueryProduct> _normqueries = [];
  List<NormqueryProduct> get normqueries => _normqueries;

  void setPros(List<String> value) {
    // lowercase
    value = value.map((e) => e.toLowerCase()).toList();
    final n = value.length > 30 ? 30 : value.length;

    Set<String> set = Set.from(value.sublist(0, n));
    pros = set.toList();
  }

  List<String> cons = [];
  void setCons(List<String> value) {
    // lowercase
    value = value.map((e) => e.toLowerCase()).toList();
    final n = value.length > 30 ? 30 : value.length;

    Set<String> set = Set.from(value.sublist(0, n));
    cons = set.toList();
  }

  // Methods
  Future<void> _asyncInit() async {
    setLoading();
    _basketNum = getBasketNum(productId);
    // TODO may be do it subsequent
    final vals = await Future.wait([
      fetchCardInfo(
          calculateCardUrl(calculateImageUrl(_basketNum, productId))), // 0
      authService.getTokenAndType(), // 1
    ]);

    final cardInfo = vals[0] as CardInfo;
    final tokenInfoOrEither =
        vals[1] as Either<AppErrorBase, Map<String, String?>>;
    if (tokenInfoOrEither.isRight()) {
      _tokenInfo = tokenInfoOrEither.fold((l) => {}, (r) => r);
    }
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
      // _orders.map((e) => (e['totalOrders'] as int));
    }

    // Stocks
    final stocksOrEither = values[2] as Either<AppErrorBase, List<Stock>>;
    List<Stock> stocks = [];
    if (stocksOrEither.isRight()) {
      stocks = stocksOrEither.fold((l) => <Stock>[], (r) => r);
      whIds.addAll(stocks.map((e) => e.warehouseId));
      _dailyStocksSums = calculateDailyStockSums(stocks);
    }

    // Normqueries
    if (!isFree) {
      final normqueryOrEither = await normqueryService.get(ids: [productId]);
      if (normqueryOrEither.isRight()) {
        _normqueries =
            normqueryOrEither.fold((l) => <NormqueryProduct>[], (r) => r);
      }
    } else {
      _normqueries = generateRandomNormqueryProducts(15);
    }

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

    _pics = cardInfo.photoCount;
    _name = cardInfo.imtName;
    _subjectName = cardInfo.subjName;
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
    _paymentUrl = authService.getPaymentUrl();
    setLoaded();
  }
}
