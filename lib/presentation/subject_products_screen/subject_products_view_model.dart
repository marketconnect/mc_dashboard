import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';
import 'package:mc_dashboard/domain/entities/detailed_order_item.dart';

abstract class SubjectProductsViewModelDetailedOrdersService {
  Future<Either<AppErrorBase, List<DetailedOrderItem>>> fetchDetailedOrders(
      {required int subjectId});
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

  List<DetailedOrderItem> _originalOrders = [];
  List<DetailedOrderItem> _filteredOrders = [];

  List<DetailedOrderItem> get detailedOrders => _filteredOrders;

  bool isFilterVisible = false;

  final Map<String, Map<String, TextEditingController>> _filterControllers = {
    "price": {
      "min": TextEditingController(),
      "max": TextEditingController(),
    },
    "orders": {
      "min": TextEditingController(),
      "max": TextEditingController(),
    },
  };

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
    _filteredOrders = List.from(_originalOrders);
    notifyListeners();
  }

  void applyFilters() {
    int? parseFilter(String? value) =>
        value != null && value.isNotEmpty ? int.tryParse(value) : null;

    final minPrice = parseFilter(_filterControllers["price"]!["min"]!.text);
    final maxPrice = parseFilter(_filterControllers["price"]!["max"]!.text);
    final minOrders = parseFilter(_filterControllers["orders"]!["min"]!.text);
    final maxOrders = parseFilter(_filterControllers["orders"]!["max"]!.text);

    _filteredOrders = _originalOrders.where((order) {
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

  final List<DetailedOrderItem> _detailedOrders = [];
  void setDetailedOrders(List<DetailedOrderItem> value) {
    _detailedOrders.clear();
    _originalDetailedOrders = List.from(value);
    _detailedOrders.addAll(value);
  }

  String get tableHeaderText => _detailedOrders.length ==
          _originalDetailedOrders.length
      ? "Всего товаров: ${_detailedOrders.length}"
      : "Всего товаров: ${_detailedOrders.length} из ${_originalDetailedOrders.length}";

  Map<String, double> currentDataMap = {};

  String? selectedProductName;

  String? scrollToProductNameValue;
  resetScrollToProductNameValue() => scrollToProductNameValue = null;

  TableViewController? tableViewController;
  void setTableViewController(TableViewController value) {
    if (value == tableViewController) return;
    tableViewController = value;
  }

  // Methods ///////////////////////////////////////////////////////////////////

  _asyncInit() async {
    setLoading();
    final result =
        await detailedOrdersService.fetchDetailedOrders(subjectId: subjectId);

    if (result.isRight()) {
      final fetchedOrders =
          result.fold((l) => throw UnimplementedError(), (r) => r);

      setDetailedOrders(fetchedOrders);
      _updateTopProducts();
    } else {
      setError("Сервер временно недоступен");
    }

    setLoaded();
  }

  void _updateTopProducts() {
    final productRevenueMap = <String, double>{};

    for (var item in detailedOrders) {
      final productName = item.productId.toString();
      productRevenueMap[productName] =
          (productRevenueMap[productName] ?? 0) + item.price.toDouble();
    }

    currentDataMap = _getTopEntries(productRevenueMap, 30);
  }

  Map<String, double> _getTopEntries(Map<String, double> map, int topCount) {
    final sortedEntries = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries.take(topCount));
  }

  void scrollToProductName(String productName) {
    if (tableViewController == null || _expandedContainer) {
      scrollToProductNameValue = productName;
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final index = detailedOrders.indexWhere(
        (item) => item.productId.toString() == productName,
      );

      if (tableViewController!.verticalScrollController.hasClients &&
          index != -1) {
        tableViewController!.verticalScrollController.animateTo(
          index * 48.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void sortData(int columnIndex) {
    if (sortColumnIndex == columnIndex) {
      isAscending = !isAscending;
    } else {
      sortColumnIndex = columnIndex;
      isAscending = true;
    }

    _detailedOrders.sort((a, b) {
      final result = compareData(a, b, columnIndex);
      return isAscending ? result : -result;
    });
    notifyListeners();
  }

  int compareData(DetailedOrderItem a, DetailedOrderItem b, int columnIndex) {
    switch (columnIndex) {
      case 0:
        return a.productId.compareTo(b.productId);
      case 1:
        return a.price.compareTo(b.price);
      case 2:
        return a.orders.compareTo(b.orders);
      default:
        return 0;
    }
  }

  void filterData({
    int? minPrice,
    int? maxPrice,
    int? minOrders,
    int? maxOrders,
  }) {
    _detailedOrders.clear();
    _detailedOrders.addAll(_originalDetailedOrders.where((item) {
      final withinPrice = (minPrice == null || item.price >= minPrice) &&
          (maxPrice == null || item.price <= maxPrice);

      final withinOrders = (minOrders == null || item.orders >= minOrders) &&
          (maxOrders == null || item.orders <= maxOrders);

      return withinPrice && withinOrders;
    }));

    notifyListeners();
  }
}
