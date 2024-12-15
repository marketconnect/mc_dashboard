import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';
import 'package:mc_dashboard/core/utils/basket_num.dart';
import 'package:mc_dashboard/domain/entities/card_info.dart';
import 'package:mc_dashboard/domain/entities/order.dart';
import 'package:mc_dashboard/domain/entities/stock.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/domain/entities/warehouse.dart';

abstract class ProductViewModelStocksService {
  Future<Either<AppErrorBase, List<Stock>>> getLastDayStocks({
    int? productId,
  });
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

class ProductViewModel extends ViewModelBase {
  final int productId;
  final int productPrice;
  final ProductViewModelStocksService stocksService;
  final ProductViewModelOrderService ordersService;
  final ProductViewModelWhService whService;
  ProductViewModel(
      {required super.context,
      required this.productId,
      required this.stocksService,
      required this.whService,
      required this.ordersService,
      required this.productPrice}) {
    _asyncInit();
  }

  String? _basketNum;
  String _name = "";
  String _rating = "0.0";
  String get rating => _rating;
  final List<String> _images = [];
  int orders30d = 0;
  int _pics = 1;
  Map<String, int> ratingDistribution = {};
  String get name => _name;
  List<String> get images => _images;
  List<String> pros = [];

  // final List<Stock> _stocks = [];
  // List<Stock> get stocks => _stocks;
  List<Map<String, dynamic>> _warehouseShares = [];
  List<Map<String, dynamic>> get warehouseShares => _warehouseShares;

  // orders
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> get orders => _orders;

  // prices
  List<Map<String, dynamic>> _priceHistory = [];
  List<Map<String, dynamic>> get priceHistory => _priceHistory;

  // warehouses
  Map<String, double> _warehousesOrdersSum = {};

  Map<String, double> get warehousesOrdersSum => _warehousesOrdersSum;
  void setPros(List<String> value) {
    // lowercase
    value = value.map((e) => e.toLowerCase()).toList();
    Set<String> set = Set.from(value.sublist(0, 30));
    pros = set.toList();
  }

  List<String> cons = [];
  void setCons(List<String> value) {
    // lowercase
    value = value.map((e) => e.toLowerCase()).toList();
    final n = value.length > 30 ? 30 : value.length;
    ;
    Set<String> set = Set.from(value.sublist(0, n));
    cons = set.toList();
  }

  // Methods
  Future<void> _asyncInit() async {
    setLoading();
    _basketNum = getBasketNum(productId);
    final values = await Future.wait([
      fetchCardInfo(calculateCardUrl(calculateImageUrl(_basketNum, productId))),
      ordersService.getOneMonthOrders(productId: productId),
      stocksService.getLastDayStocks(productId: productId),
    ]);
    final cardInfo = values[0] as CardInfo;
    final feedbackInfo = await fetchFeedbacks(cardInfo.imtId);
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
    }

    final whOrEither =
        await whService.getWarehouses(ids: whIds.toSet().toList());
    if (whOrEither.isRight()) {
      final warehousesList =
          whOrEither.fold((l) => throw UnimplementedError, (r) => r);
      _warehouseShares = calculateWarehouseShares(stocks, warehousesList);
      _warehousesOrdersSum = getTotalOrdersByWarehouse(orders, warehousesList);
    }

    _pics = cardInfo.photoCount;
    _name = cardInfo.imtName;
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
    setLoaded();
  }
}
