import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';
import 'package:mc_dashboard/domain/entities/subject_summary_item.dart';

abstract class ChoosingNicheViewModelSubjectsSummaryService {
  Future<Either<AppErrorBase, List<SubjectSummaryItem>>> fetchSubjectsSummary();
}

class ChoosingNicheViewModel extends ViewModelBase {
  ChoosingNicheViewModel(
      {required super.context,
      required this.subjectsSummaryService,
      required this.onNavigateToSubjectProducts}) {
    _asyncInit();
  }

  final void Function(int subjectId, String subjectName)
      onNavigateToSubjectProducts;
  final ChoosingNicheViewModelSubjectsSummaryService subjectsSummaryService;

  // Fields ////////////////////////////////////////////////////////////////////

  bool _expandedContainer = false;

  bool get expandedContainer => _expandedContainer;

  void toggleExpandedContainer() {
    _expandedContainer = !_expandedContainer;
    notifyListeners();
  }

  bool isFilterVisible = false;

  void toggleFilterVisibility() {
    isFilterVisible = !isFilterVisible;
    notifyListeners();
  }

  int? sortColumnIndex;
  bool isAscending = true;
  List<SubjectSummaryItem> _originalSubjectsSummary = [];

  final List<SubjectSummaryItem> _subjectsSummary = [];
  void setSubjectsSummary(List<SubjectSummaryItem> value) {
    for (var item in value) {
      // if (item.totalOrders == 0) {
      //   continue;
      // }
      final newSubject = item.copyWith(
        totalRevenue: (item.totalRevenue / 100).ceil(),
        medianPrice: (item.medianPrice / 100).ceil(),
      );
      _subjectsSummary.add(newSubject);
      _originalSubjectsSummary.add(newSubject);
    }
  }

  String get tableHeaderText => _subjectsSummary.length ==
          _originalSubjectsSummary.length
      ? "Всего предметов: ${_subjectsSummary.length}"
      : "Всего предметов: ${_subjectsSummary.length} из ${_originalSubjectsSummary.length}";

  List<SubjectSummaryItem> get subjectsSummary => _subjectsSummary;

  Map<String, double> currentDataMap = {};

  String? selectedParentName;

  // When in expanded BarChartWidgets container a user chooses a subject Name
  // the tableViewController is null. So to save the selected subject Name
  // we save it here. And in the TableWidget in the initState we use it to scroll
  String? scrollToSubjectNameValue;
  resetScrollToSubjectNameValue() => scrollToSubjectNameValue = null;

  TableViewController? tableViewController;
  void setTableViewController(TableViewController value) {
    if (value == tableViewController) return;
    tableViewController = value;
  }

  (String, String) _metric = ("Выручка", "₽");
  void setMetric((String, String) value) => _metric = value;
  (String, String) get metric => _metric;

  final Map<String, Map<String, TextEditingController>> _filterControllers = {};

  final double tableRowHeight = 48.0;

  List<String> get filters => [
        "Выручка (₽)",
        "Кол-во заказов",
        "Товары",
        "Медианная цена (₽)",
        "Процент тов. с заказами"
      ];

  List<String> get metrics => [
        "Выручка",
        "Количество товаров",
        "Количество заказов",
        "Товары с заказами",
      ];

  Map<String, Map<String, TextEditingController>> get filterControllers =>
      _filterControllers;

  // Search fields
  String _searchQuery = '';
  bool _isSearchVisible = false;

  bool get isSearchVisible => _isSearchVisible;

  // Search end

  // Methods
  _asyncInit() async {
    setLoading();
    final result = await subjectsSummaryService.fetchSubjectsSummary();

    if (result.isRight()) {
      final fetchedSubjectsSummary =
          result.fold((l) => throw UnimplementedError(), (r) => r);

      setSubjectsSummary(fetchedSubjectsSummary);
      _updateTopParentRevenue();
      _initializeFilterControllers();
    } else {
      setError("Сервер временно недоступен");
    }

    setLoaded();
  }

  set subjectsSummary(List<SubjectSummaryItem> value) {
    _originalSubjectsSummary = List.from(value);
    _subjectsSummary.clear();
    for (var item in value) {
      final newSubject = item.copyWith(
        totalRevenue: (item.totalRevenue / 100).round(),
        medianPrice: (item.medianPrice / 100).round(),
      );
      _subjectsSummary.add(newSubject);
    }
  }

  void _initializeFilterControllers() {
    for (final filter in filters) {
      _filterControllers[filter] = {
        "min": TextEditingController(),
        "max": TextEditingController(),
      };
    }
  }

  void clearFilterControllers() {
    for (final controllerPair in _filterControllers.values) {
      controllerPair["min"]?.clear();
      controllerPair["max"]?.clear();
    }
    _subjectsSummary.clear();
    _subjectsSummary.addAll(_originalSubjectsSummary);

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

  void sortData(int columnIndex) {
    if (sortColumnIndex == columnIndex) {
      isAscending = !isAscending;
    } else {
      sortColumnIndex = columnIndex;
      isAscending = true;
    }

    subjectsSummary.sort((a, b) {
      final result = compareData(a, b, columnIndex);
      return isAscending ? result : -result;
    });
    notifyListeners();
  }

  int compareData(SubjectSummaryItem a, SubjectSummaryItem b, int columnIndex) {
    switch (columnIndex) {
      case 0:
        return (a.subjectParentName ?? '').compareTo(b.subjectParentName ?? '');
      case 1:
        return a.totalRevenue.compareTo(b.totalRevenue);
      case 2:
        return a.totalSkus.compareTo(b.totalSkus);
      case 3:
        return a.totalOrders.compareTo(b.totalOrders);
      case 4:
        return a.medianPrice.compareTo(b.medianPrice);
      case 5:
        return a.skusWithOrders.compareTo(b.skusWithOrders);
      default:
        return 0;
    }
  }

  void _updateTopParentRevenue() {
    final parentRevenueMap = <String, double>{};

    for (var item in subjectsSummary) {
      final parentName = item.subjectParentName ?? 'Unknown';
      parentRevenueMap[parentName] =
          (parentRevenueMap[parentName] ?? 0) + item.totalRevenue.toDouble();
    }

    currentDataMap = _getTopEntries(parentRevenueMap, 30);
  }

  void updateModelMetric(String metric) {
    int columnIndex;
    switch (metric) {
      case "Количество товаров":
        columnIndex = 2;
        break;
      case "Количество заказов":
        columnIndex = 3;
        break;
      case "Товары с заказами":
        columnIndex = 5;
        break;
      case "Выручка":
      default:
        columnIndex = 1;
        break;
    }
    if (selectedParentName != null) {
      updateTopSubjectValue(selectedParentName!, columnIndex);
    }
  }

  void updateTopSubjectValue(String parentName, int columnIndex) {
    selectedParentName = parentName;
    final subjectMap = <String, double>{};

    for (var item in subjectsSummary) {
      if (item.subjectParentName == parentName) {
        switch (columnIndex) {
          case 0:
            setMetric(("Выручка", "₽"));
            subjectMap[item.subjectName] = (subjectMap[item.subjectName] ?? 0) +
                item.totalRevenue.toDouble();
          case 1:
            setMetric(("Выручка", "₽"));
            subjectMap[item.subjectName] = (subjectMap[item.subjectName] ?? 0) +
                item.totalRevenue.toDouble();
            break;
          case 2:
            setMetric(("Количество товаров", "шт."));
            subjectMap[item.subjectName] =
                (subjectMap[item.subjectName] ?? 0) + item.totalSkus.toDouble();
            break;
          case 3:
            setMetric(("Количество заказов", "шт."));
            subjectMap[item.subjectName] = (subjectMap[item.subjectName] ?? 0) +
                item.totalOrders.toDouble();
            break;
          case 4:
            setMetric(("Выручка", "₽"));
            subjectMap[item.subjectName] = (subjectMap[item.subjectName] ?? 0) +
                item.totalRevenue.toDouble();

          case 5:
            setMetric(("Товары с заказами", "шт."));
            subjectMap[item.subjectName] = (subjectMap[item.subjectName] ?? 0) +
                item.skusWithOrders.toDouble();
            break;
          default:
            break;
        }
      }
    }

    currentDataMap = _getTopEntries(subjectMap, 30);
    notifyListeners();
  }

  Map<String, double> _getTopEntries(Map<String, double> map, int topCount) {
    final sortedEntries = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries.take(topCount));
  }

  void scrollToSubjectName(String subjectName) {
    if (tableViewController == null || _expandedContainer) {
      scrollToSubjectNameValue = subjectName;
      return;
    }

    final index = subjectsSummary.indexWhere(
      (item) => item.subjectName == subjectName,
    );

    if (index == -1) return;

    if (tableViewController!.verticalScrollController.hasClients) {
      tableViewController!.verticalScrollController.animateTo(
        index * tableRowHeight,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void filterData({
    int? minTotalRevenue,
    int? maxTotalRevenue,
    int? minTotalOrders,
    int? maxTotalOrders,
    int? minTotalSkus,
    int? maxTotalSkus,
    int? minMedianPrice,
    int? maxMedianPrice,
    int? minSkusWithOrders,
    int? maxSkusWithOrders,
  }) {
    _subjectsSummary.clear();
    _subjectsSummary.addAll(_originalSubjectsSummary.where((item) {
      final withinRevenue =
          (minTotalRevenue == null || item.totalRevenue >= minTotalRevenue) &&
              (maxTotalRevenue == null || item.totalRevenue <= maxTotalRevenue);

      final withinOrders =
          (minTotalOrders == null || item.totalOrders >= minTotalOrders) &&
              (maxTotalOrders == null || item.totalOrders <= maxTotalOrders);

      final withinSkus =
          (minTotalSkus == null || item.totalSkus >= minTotalSkus) &&
              (maxTotalSkus == null || item.totalSkus <= maxTotalSkus);

      final withinMedianPrice =
          (minMedianPrice == null || item.medianPrice >= minMedianPrice) &&
              (maxMedianPrice == null || item.medianPrice <= maxMedianPrice);

      final withinSkusWithOrders = (minSkusWithOrders == null ||
              item.skusWithOrders >= minSkusWithOrders) &&
          (maxSkusWithOrders == null ||
              item.skusWithOrders <= maxSkusWithOrders);

      return withinRevenue &&
          withinOrders &&
          withinSkus &&
          withinMedianPrice &&
          withinSkusWithOrders;
    }));

    notifyListeners();
  }

  // Searching
  void setSearchQuery(String query) {
    _searchQuery = query;
    filterBySubjectName(_searchQuery);
  }

  void filterBySubjectName(String query) {
    if (query.isEmpty) {
      // Если строка пустая, показываем все предметы
      _subjectsSummary.clear();
      _subjectsSummary.addAll(_originalSubjectsSummary);
    } else {
      final lowerQuery = query.toLowerCase();
      _subjectsSummary.clear();
      _subjectsSummary.addAll(_originalSubjectsSummary.where((item) {
        final fullName =
            '${item.subjectParentName ?? ''}/${item.subjectName}'.toLowerCase();
        return fullName.contains(lowerQuery);
      }));
    }
    notifyListeners();
  }

  void toggleSearchVisibility() {
    _isSearchVisible = !_isSearchVisible;
    if (!_isSearchVisible) {
      // Очистим поиск, если поле скрывается
      setSearchQuery('');
    }
    notifyListeners();
  }
}
