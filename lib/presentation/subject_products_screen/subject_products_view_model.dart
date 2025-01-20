import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';
import 'package:mc_dashboard/core/utils/strings_ext.dart';
import 'package:mc_dashboard/domain/entities/detailed_order_item.dart';
import 'package:mc_dashboard/domain/entities/saved_product.dart';
import 'package:mc_dashboard/domain/entities/subject_summary_item.dart';
import 'package:mc_dashboard/domain/entities/token_info.dart';

import 'package:mc_dashboard/routes/main_navigation_route_names.dart';

// Detailed Orders Service
abstract class SubjectProductsViewModelDetailedOrdersService {
  Future<Either<AppErrorBase, List<DetailedOrderItem>>> fetchDetailedOrders(
      {required int subjectId, required int isFbs});
}

// Auth Service
abstract class SubjectProductsAuthService {
  Future<Either<AppErrorBase, TokenInfo>> getTokenInfo();
}

// Subject Summary Service
abstract class SubjectProductsSubjectSummaryService {
  Future<Either<AppErrorBase, List<SubjectSummaryItem>>> fetchSubjectsSummary(
      int subjectId);
}

// Saved Products Service
abstract class SubjectProductsSavedProductsService {
  Future<Either<AppErrorBase, void>> addProducts({
    required String token,
    required List<SavedProduct> products,
  });
}

class SubjectProductsViewModel extends ViewModelBase {
  SubjectProductsViewModel(
      {required super.context,
      required this.subjectId,
      required this.subjectName,
      required this.onNavigateTo,
      required this.detailedOrdersService,
      required this.authService,
      required this.savedProductsService,
      required this.subjectSummaryService,
      required this.onSaveProductsToTrack});

  final int subjectId;
  final String subjectName;
  final SubjectProductsAuthService authService;
  final SubjectProductsViewModelDetailedOrdersService detailedOrdersService;
  final SubjectProductsSavedProductsService savedProductsService;
  final SubjectProductsSubjectSummaryService subjectSummaryService;
  final void Function(List<String>) onSaveProductsToTrack;

  // Navigation
  final void Function({
    required String routeName,
    Map<String, dynamic>? params,
  }) onNavigateTo;

  // Fields ////////////////////////////////////////////////////////////////////
  // Table Checkbox
  // Храним индексы выбранных строк
  final Set<int> _selectedRows = {};
  Set<int> get selectedRows => _selectedRows;

  List<DetailedOrderItem> _filteredOrders = [];

  List<DetailedOrderItem> get detailedOrders => _filteredOrders;

  bool isFilterVisible = false;

  final Map<String, Map<String, TextEditingController>> _filterControllers = {};

  List<String> get filters => [
        "Выручка (₽)",
        "Цена со скидкой (₽)",
        "Кол-во заказов",
      ];

  Map<String, Map<String, TextEditingController>> get filterControllers =>
      _filterControllers;

  final Map<int, (String, String)> _productImageProductName = {};

  TokenInfo? _tokenInfo;
  bool get isFree => _tokenInfo == null || _tokenInfo!.type == "free";

  int _totalRevenue = 0;
  int get totalRevenue => _totalRevenue;

  // Setters
  void addProductImage(int productId, String imageUrl, String productName) {
    _productImageProductName[productId] = (imageUrl, productName);
  }

  String? _token;

  // Methods ///////////////////////////////////////////////////////////////////

  @override
  Future<void> asyncInit() async {
    // Token
    final tokenInfoOrEither = await authService.getTokenInfo();
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
    if (_tokenInfo == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Не удалось получить токен'),
        ));
      }
      return;
    }

    _token = _tokenInfo!.token;
    // Detailed Orders
    final result = await detailedOrdersService.fetchDetailedOrders(
        subjectId: subjectId, isFbs: 0);

    if (result.isRight()) {
      final fetchedOrders =
          result.fold((l) => throw UnimplementedError(), (r) => r);
      setDetailedOrders(fetchedOrders);

      final subjectSummaryOrEither =
          await subjectSummaryService.fetchSubjectsSummary(subjectId);
      if (subjectSummaryOrEither.isRight()) {
        final fetchedSummary = subjectSummaryOrEither.fold(
            (l) => throw UnimplementedError(), (r) => r);

        final subjSum =
            fetchedSummary.where((item) => item.subjectId == subjectId);

        if (subjSum.isNotEmpty) {
          _totalRevenue = subjSum.first.totalRevenue;
        }
      }

      _updateSellerBrandDataMaps();

      _initializeFilterControllers();
    } else {
      setError("Сервер временно недоступен");
    }
  }

  void selectRow(int index) {
    if (_selectedRows.contains(index)) {
      _selectedRows.remove(index);
    } else {
      _selectedRows.add(index);
    }
    notifyListeners();
  }

  void toggleFilterVisibility() {
    isFilterVisible = !isFilterVisible;
    notifyListeners();
  }

  void clearFilterControllers() {
    for (final controllerPair in _filterControllers.values) {
      controllerPair["min"]?.clear();
      controllerPair["max"]?.clear();
    }
    _filteredOrders = List.from(_originalDetailedOrders);
    notifyListeners();
  }

  void applyFilters() {
    int? parseFilter(String? value) =>
        value != null && value.isNotEmpty ? int.tryParse(value) : null;

    final minPrice = parseFilter(_filterControllers["price"]!["min"]!.text);
    final maxPrice = parseFilter(_filterControllers["price"]!["max"]!.text);
    final minOrders = parseFilter(_filterControllers["orders"]!["min"]!.text);
    final maxOrders = parseFilter(_filterControllers["orders"]!["max"]!.text);

    _filteredOrders = _originalDetailedOrders.where((order) {
      final withinPrice = (minPrice == null || order.price >= minPrice) &&
          (maxPrice == null || order.price <= maxPrice);
      final withinOrders = (minOrders == null || order.orders >= minOrders) &&
          (maxOrders == null || order.orders <= maxOrders);

      return withinPrice && withinOrders;
    }).toList();

    notifyListeners();
  }

  @override
  void dispose() {
    for (final controllerPair in _filterControllers.values) {
      controllerPair["min"]?.dispose();
      controllerPair["max"]?.dispose();
    }
    super.dispose();
  }

  bool _expandedContainer = false;

  bool get expandedContainer => _expandedContainer;

  void toggleExpandedContainer() {
    _expandedContainer = !_expandedContainer;
    notifyListeners();
  }

  int? sortColumnIndex;
  bool isAscending = true;
  List<DetailedOrderItem> _originalDetailedOrders = [];

  void setDetailedOrders(List<DetailedOrderItem> value) {
    // filter out fake orders and zero orders
    value = value.where((order) => order.orders < 1000000).toList();

    //  since price is in kopeks, we need to convert it to rubles
    value = value
        .map((item) => item.copyWith(price: (item.price / 100).ceil()))
        .toList();
    _filteredOrders.clear();
    _originalDetailedOrders = List.from(value);
    _filteredOrders.addAll(value);
  }

  String get tableHeaderText => _originalDetailedOrders.isEmpty
      ? ""
      : _filteredOrders.length == _originalDetailedOrders.length
          ? "Всего товаров: ${_filteredOrders.length >= 10000 ? "более 10000" : _filteredOrders.length} (${((_totalRevenue / 100).toInt()).toString().formatWithThousands()} ₽)"
          : "Всего товаров: ${_filteredOrders.length} из ${_originalDetailedOrders.length}";

  Map<String, double> currentDataMap = {};

  String? selectedProductName;

  String? scrollToProductNameValue;
  resetScrollToProductNameValue() => scrollToProductNameValue = null;

  TableViewController? tableViewController;
  void setTableViewController(TableViewController value) {
    if (value == tableViewController) return;
    tableViewController = value;
  }

  final double tableRowHeight = 60.0;

  bool isFbs = false;

  Future<void> switchToFbs() async {
    if (isFbs) {
      await asyncInit();
      isFbs = false;
      return;
    }
    isFbs = true;
    final result = await detailedOrdersService.fetchDetailedOrders(
        subjectId: subjectId, isFbs: 1);

    if (result.isRight()) {
      final fetchedOrders =
          result.fold((l) => throw UnimplementedError(), (r) => r);

      setDetailedOrders(fetchedOrders);
      _updateSellerBrandDataMaps();
      _initializeFilterControllers();
    } else {
      setError("Сервер временно недоступен");
    }

    setLoaded();
  }

  void _initializeFilterControllers() {
    for (final filter in filters) {
      _filterControllers[filter] = {
        "min": TextEditingController(),
        "max": TextEditingController(),
      };
    }
  }

  void sortData(int columnIndex) {
    if (sortColumnIndex == columnIndex) {
      isAscending = !isAscending;
    } else {
      sortColumnIndex = columnIndex;
      isAscending = true;
    }

    _filteredOrders.sort((a, b) {
      final result = compareData(a, b, columnIndex);
      return isAscending ? result : -result;
    });
    notifyListeners();
  }

  int compareData(DetailedOrderItem a, DetailedOrderItem b, int columnIndex) {
    switch (columnIndex) {
      case 1:
        final aRevenue = a.price * a.orders;
        final bRevenue = b.price * b.orders;
        return aRevenue.compareTo(bRevenue);

      case 2:
        return a.price.compareTo(b.price);
      case 3:
        return a.supplier.compareTo(b.supplier);
      case 4:
        return a.brand.compareTo(b.brand);
      case 5:
        return a.orders.compareTo(b.orders);
      default:
        return 0;
    }
  }

  void filterData({
    int? minRevenue,
    int? maxRevenue,
    int? minPrice,
    int? maxPrice,
    int? minOrders,
    int? maxOrders,
  }) {
    _filteredOrders.clear();
    _filteredOrders.addAll(_originalDetailedOrders.where((item) {
      final withinPrice = (minPrice == null || item.price >= minPrice) &&
          (maxPrice == null || item.price <= maxPrice);

      final withinOrders = (minOrders == null || item.orders >= minOrders) &&
          (maxOrders == null || item.orders <= maxOrders);

      final withinRevenue =
          (minRevenue == null || item.price * item.orders >= minRevenue) &&
              (maxRevenue == null || item.price * item.orders <= maxRevenue);

      return withinPrice && withinOrders && withinRevenue;
    }));

    notifyListeners();
  }

  // Sellers and brands filtering
  Map<String, double> sellersDataMap = {};
  Map<String, double> brandsDataMap = {};
  String? _filteredSeller;
  String? get filteredSeller => _filteredSeller;
  String? _filteredBrand;
  String? get filteredBrand => _filteredBrand;

  bool get isSellerOrBrandFiltered =>
      _filteredSeller != null || _filteredBrand != null;

  void _updateSellerBrandDataMaps() {
    final sellerMap = <String, double>{};
    final brandMap = <String, double>{};
    for (var item in _originalDetailedOrders) {
      final revenue = (item.price * item.orders).toDouble();
      sellerMap[item.supplier] = (sellerMap[item.supplier] ?? 0) + revenue;
      brandMap[item.brand] = (brandMap[item.brand] ?? 0) + revenue;
    }

    sellersDataMap = _getTopEntries(sellerMap, 30);
    brandsDataMap = _getTopEntries(brandMap, 30);
  }

  Map<String, double> _getTopEntries(Map<String, double> map, int topCount) {
    final sortedEntries = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sortedEntries.take(topCount));
  }

  void filterBySeller(String seller) {
    _filteredSeller = seller;
    _filteredBrand = null;
    _applySellerBrandFilters();
  }

  void filterByBrand(String brand) {
    _filteredBrand = brand;
    _filteredSeller = null;
    _applySellerBrandFilters();
  }

  void clearSellerBrandFilter() {
    _filteredSeller = null;
    _filteredBrand = null;
    _filteredOrders = List.from(_originalDetailedOrders);
    notifyListeners();
  }

  void _applySellerBrandFilters() {
    _filteredOrders = _originalDetailedOrders.where((item) {
      if (_filteredSeller != null && item.supplier != _filteredSeller) {
        return false;
      }
      if (_filteredBrand != null && item.brand != _filteredBrand) return false;
      return true;
    }).toList();
    notifyListeners();
  }

  Future<void> saveProducts() async {
    if (isFree) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Чтобы получать рассылку, вы должны быть подписчиком.',
            style: TextStyle(
                fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize)),
        action: SnackBarAction(
          label: 'Оформить подписку',
          onPressed: () {
            onNavigateToSubscriptionScreen();
          },
        ),
        duration: Duration(seconds: 10),
      ));
      return;
    } // get selected orders
    final selectedOrders = _filteredOrders.where((item) {
      return _selectedRows.contains(item.productId);
    });

    // prepare products to save
    List<SavedProduct> productsToSave = [];
    for (var item in selectedOrders) {
      final imageUrlProductName = _productImageProductName[item.productId];
      if (imageUrlProductName != null) {
        productsToSave.add(SavedProduct(
            productId: item.productId.toString(),
            sellerId: item.supplierId.toString(),
            sellerName: item.supplier,
            brandId: item.brandId.toString(),
            brandName: item.brand,
            marketplaceType: "wb",
            imageUrl: imageUrlProductName.$1,
            name: imageUrlProductName.$2));
      }
    }

    // save products
    await savedProductsService.addProducts(
        token: _token!, products: productsToSave);

    // callback to update the SavedProductsScreen
    onSaveProductsToTrack(
        productsToSave.map((item) => item.productId).toList());
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Товары успешно добавлены',
        ),
        duration: Duration(seconds: 3),
      ));
    }
  }

  // Navigation
  void navigateToSeoRequestsExtendScreen() {
    final ids = _selectedRows.toList();
    onNavigateTo(
        routeName: MainNavigationRouteNames.seoRequestsExtend,
        params: {"productIds": ids});
  }

  void onNavigateToProductScreen(int productId, int productPrice) {
    onNavigateTo(
        routeName: MainNavigationRouteNames.productScreen,
        params: {"productId": productId, "productPrice": productPrice});
  }

  void onNavigateBack() {
    onNavigateTo(routeName: MainNavigationRouteNames.choosingNicheScreen);
  }

  void onNavigateToEmptySubject() {
    onNavigateTo(routeName: MainNavigationRouteNames.emptySubjectsScreen);
  }

  void onNavigateToSubscriptionScreen() {
    onNavigateTo(routeName: MainNavigationRouteNames.subscriptionScreen);
  }
}
