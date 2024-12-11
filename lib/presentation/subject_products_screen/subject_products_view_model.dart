import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';
import 'package:mc_dashboard/domain/entities/detailed_order_item.dart';

abstract class SubjectProductsViewModelDetailedOrdersService {
  Future<Either<AppErrorBase, List<DetailedOrderItem>>> fetchDetailedOrders(
      {required int subjectId, required int isFbs});
}

class SubjectProductsViewModel extends ViewModelBase {
  final int subjectId;
  final String subjectName;
  SubjectProductsViewModel({
    required super.context,
    required this.subjectId,
    required this.subjectName,
    required this.detailedOrdersService,
  }) {
    _asyncInit();
  }

  final SubjectProductsViewModelDetailedOrdersService detailedOrdersService;

  // Fields ////////////////////////////////////////////////////////////////////

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
    //  since price is in kopeks, we need to convert it to rubles
    value = value
        .map((item) => item.copyWith(price: (item.price / 100).ceil()))
        .toList();
    _filteredOrders.clear();
    _originalDetailedOrders = List.from(value);
    _filteredOrders.addAll(value);
  }

  String get tableHeaderText => _filteredOrders.length ==
          _originalDetailedOrders.length
      ? "Всего товаров: ${_filteredOrders.length >= 10000 ? "более 10000" : _filteredOrders.length}"
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
  // Methods ///////////////////////////////////////////////////////////////////

  _asyncInit() async {
    setLoading();
    final result = await detailedOrdersService.fetchDetailedOrders(
        subjectId: subjectId, isFbs: 0);

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

  Future<void> switchToFbs() async {
    if (isFbs) {
      _asyncInit();
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
}
