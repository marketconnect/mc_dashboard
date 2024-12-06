import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/core/utils/app_error.dart';
import 'package:mc_dashboard/domain/entities/subject_summary_item.dart';

abstract class ChoosingNicheViewModelSubjectsSummaryService {
  Future<Either<AppErrorBase, List<SubjectSummaryItem>>> fetchSubjectsSummary();
}

class ChoosingNicheViewModel extends ChangeNotifier {
  final ChoosingNicheViewModelSubjectsSummaryService subjectsSummaryService;

  ChoosingNicheViewModel({required this.subjectsSummaryService}) {
    _asyncInit();
  }

  int? sortColumnIndex;
  bool isAscending = true;
  final List<SubjectSummaryItem> _subjectsSummary = [];
  void set subjectsSummary(List<SubjectSummaryItem> value) {
    _subjectsSummary.clear();
    for (var item in value) {
      final newSubject = item.copyWith(
        totalRevenue: (item.totalRevenue / 100).round(),
        medianPrice: (item.medianPrice / 100).round(),
      );

      _subjectsSummary.add(newSubject);
    }
  }

  List<SubjectSummaryItem> get subjectsSummary => _subjectsSummary;

  Map<String, double> currentDataMap = {};

  _asyncInit() async {
    final result = await subjectsSummaryService.fetchSubjectsSummary();
    if (result.isRight()) {
      subjectsSummary =
          result.fold((l) => throw UnimplementedError(), (r) => r);
      _updateTopParentRevenue();
    }
    notifyListeners();
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

  void updateTopSubjectRevenue(String parentName) {
    final subjectRevenueMap = <String, double>{};

    for (var item in subjectsSummary) {
      if (item.subjectParentName == parentName) {
        subjectRevenueMap[item.subjectName] =
            (subjectRevenueMap[item.subjectName] ?? 0) +
                item.totalRevenue.toDouble();
      }
    }

    currentDataMap = _getTopEntries(subjectRevenueMap, 10);
    notifyListeners();
  }

  Map<String, double> _getTopEntries(Map<String, double> map, int topCount) {
    final sortedEntries = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries.take(topCount));
  }
}
