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
  final ChoosingNicheViewModelSubjectsSummaryService subjectsSummaryService;

  ChoosingNicheViewModel(
      {required super.context, required this.subjectsSummaryService}) {
    _asyncInit();
  }

  int? sortColumnIndex;
  bool isAscending = true;
  List<SubjectSummaryItem> _originalSubjectsSummary = [];

  final List<SubjectSummaryItem> _subjectsSummary = [];

  List<SubjectSummaryItem> get subjectsSummary => _subjectsSummary;

  Map<String, double> currentDataMap = {};

  String? selectedParentName;

  final TableViewController tableViewController = TableViewController();

  String diagramHeader = "Выручка";

  // Methods
  _asyncInit() async {
    setLoading();
    final result = await subjectsSummaryService.fetchSubjectsSummary();
    if (result.isRight()) {
      subjectsSummary =
          result.fold((l) => throw UnimplementedError(), (r) => r);
      _updateTopParentRevenue();
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

    currentDataMap = _getTopEntries(parentRevenueMap, 10);
  }

  void updateTopSubjectRevenue(String parentName, int columnIndex) {
    selectedParentName = parentName;
    final subjectMap = <String, double>{};

    for (var item in subjectsSummary) {
      if (item.subjectParentName == parentName) {
        switch (columnIndex) {
          case 1:
            diagramHeader = "Выручка";
            subjectMap[item.subjectName] = (subjectMap[item.subjectName] ?? 0) +
                item.totalRevenue.toDouble();
            break;
          case 2:
            diagramHeader = "Количество товаров";
            subjectMap[item.subjectName] =
                (subjectMap[item.subjectName] ?? 0) + item.totalSkus.toDouble();
            break;
          case 3:
            diagramHeader = "Количество заказов";
            subjectMap[item.subjectName] = (subjectMap[item.subjectName] ?? 0) +
                item.totalOrders.toDouble();
            break;

          case 5:
            diagramHeader = "Товары с заказами";
            subjectMap[item.subjectName] = (subjectMap[item.subjectName] ?? 0) +
                item.skusWithOrders.toDouble();
            break;
          default:
            break;
        }
      }
    }

    currentDataMap = _getTopEntries(subjectMap, 10);
    notifyListeners();
  }

  Map<String, double> _getTopEntries(Map<String, double> map, int topCount) {
    final sortedEntries = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries.take(topCount));
  }

  void scrollToSubjectName(String subjectName) {
    final index = subjectsSummary.indexWhere(
      (item) => item.subjectName == subjectName,
    );

    if (index != -1) {
      tableViewController.verticalScrollController.animateTo(
        index * 48.0, // Высота строки (rowHeight) * индекс строки
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
}
