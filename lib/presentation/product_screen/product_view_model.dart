import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';
import 'package:mc_dashboard/core/utils/basket_num.dart';
import 'package:mc_dashboard/core/utils/similarity.dart';
import 'package:mc_dashboard/domain/entities/card_info.dart';
import 'package:mc_dashboard/domain/entities/feedback_info.dart';
import 'package:mc_dashboard/domain/entities/kw_lemmas.dart';
import 'package:mc_dashboard/domain/entities/lemmatize.dart';
import 'package:mc_dashboard/domain/entities/normquery_product.dart';
import 'package:mc_dashboard/domain/entities/order.dart';
import 'package:mc_dashboard/domain/entities/stock.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/domain/entities/warehouse.dart';
import 'package:mc_dashboard/presentation/product_screen/table_row_model.dart';
import 'package:url_launcher/url_launcher.dart';

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
  logout();
}

abstract class ProductViewModelKwLemmaService {
  Future<Either<AppErrorBase, List<KwLemmaItem>>> get({required List<int> ids});
}

abstract class ProductViewModelLemmatizeService {
  Future<Either<AppErrorBase, LemmatizeResponse>> get(
      {required LemmatizeRequest req});
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
      required this.kwLemmaService,
      required this.onNavigateToEmptyProductScreen,
      required this.lemmatizeService,
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
  final ProductViewModelKwLemmaService kwLemmaService;
  final ProductViewModelLemmatizeService lemmatizeService;
  final void Function() onNavigateBack;
  final void Function() onNavigateToEmptyProductScreen;

  // Fields ////////////////////////////////////////////////////////////////////

  // token and sub info
  Map<String, String?> _tokenInfo = {};
  bool get isFree => _tokenInfo["type"] == "free";

  // payment url
  String? _paymentUrl;
  String? get paymentUrl => _paymentUrl;

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

  // subject
  String _subjectName = "";
  String get subjectName => _subjectName;

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

  // Normqueries
  List<NormqueryProduct> _normqueries = [];
  List<NormqueryProduct> get normqueries => _normqueries;

  // pros and cons
  List<String> pros = [];
  List<String> cons = [];

  String _lemmatizedName = "";
  String _lemmatizedDescription = "";
  String _lemmatizedCharacteristics = "";

  // Seo table rows
  Map<String, List<SEOTableRowModel>> _seoTableSections = {};
  Map<String, List<SEOTableRowModel>> get seoTableSections => _seoTableSections;
  // setters ///////////////////////////////////////////////////////////////////
  void setKwLemmas(List<KwLemmaItem> value) {
    _kwLemmas.clear();
    _kwLemmas.addAll(value);
  }

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

  // Methods ///////////////////////////////////////////////////////////////////
  Future<void> _asyncInit() async {
    setLoading();
    _basketNum = getBasketNum(productId);

    final vals = await Future.wait([
      fetchCardInfo(
          calculateCardUrl(calculateImageUrl(_basketNum, productId))), // 0
      authService.getTokenAndType(), // 1
    ]);

    // card info
    final cardInfo = vals[0] as CardInfo;

    // token and sub info
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

    // kw lemmas
    final normqueryIds = _normqueries.map((e) => e.normqueryId).toList();
    final kwLemmasOrEither = await kwLemmaService.get(ids: normqueryIds);
    if (kwLemmasOrEither.isRight()) {
      final kwLemmas = kwLemmasOrEither.fold((l) => <KwLemmaItem>[], (r) => r);
      setKwLemmas(kwLemmas);
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

    // set card info
    _pics = cardInfo.photoCount;
    _name = cardInfo.imtName;
    _description = cardInfo.description;

    _characteristics = cardInfo.characteristics;

    final lemmatizedOrEither = await lemmatizeService.get(
      req: LemmatizeRequest(
        title: cardInfo.imtName,
        characteristics: cardInfo.characteristics,
        description: cardInfo.description,
      ),
    );

    if (lemmatizedOrEither.isRight()) {
      final lemmatized =
          lemmatizedOrEither.fold((l) => throw UnimplementedError, (r) => r);
      _lemmatizedName = lemmatized.title;
      _lemmatizedDescription = lemmatized.description;
      _lemmatizedCharacteristics = lemmatized.characteristics;
      _seoTableSections = await generateSEOTableSections(
          _normqueries,
          _kwLemmas,
          _lemmatizedName,
          _lemmatizedDescription,
          _lemmatizedCharacteristics,
          calculateCosineSimilarity);
    }
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

  // payment
  void onPaymentComplete() {
    if (paymentUrl != null) {
      launchUrl(Uri.parse(paymentUrl!));
      authService.logout();
    }
  }
}
