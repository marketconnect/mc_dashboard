import 'package:flutter/cupertino.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';
import 'package:mc_dashboard/domain/entities/subject_summary_item.dart';
import 'package:mc_dashboard/routes/main_navigation_route_names.dart';

abstract class EmptySubjectViewModelSubjectsSummaryService {
  Future<Either<AppErrorBase, List<SubjectSummaryItem>>> fetchSubjectsSummary();
}

class EmptySubjectViewModel extends ViewModelBase {
  EmptySubjectViewModel({
    required super.context,
    required this.subjectsSummaryService,
  });
  final EmptySubjectViewModelSubjectsSummaryService subjectsSummaryService;

  // Fields
  String searchQuery = '';

  List<SubjectSummaryItem> get filteredSubjects {
    if (searchQuery.isEmpty) {
      return [];
    }
    final lowerQuery = searchQuery.toLowerCase();
    return _subjectsSummary.where((item) {
      return item.subjectName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  final List<SubjectSummaryItem> _subjectsSummary = [];
  List<SubjectSummaryItem> get subjectsSummary => _subjectsSummary;

  void setSubjectsSummary(List<SubjectSummaryItem> value) {
    for (var item in value) {
      final newSubject = item.copyWith(
        totalRevenue: (item.totalRevenue / 100).ceil(),
        medianPrice: (item.medianPrice / 100).ceil(),
      );
      _subjectsSummary.add(newSubject);
    }
  }

  // Methods

  @override
  Future<void> asyncInit() async {
    setLoading();
    final result = await subjectsSummaryService.fetchSubjectsSummary();

    if (result.isRight()) {
      setSubjectsSummary(
          result.fold((l) => throw UnimplementedError(), (r) => r));
    } else {
      setError("Сервер временно недоступен");
    }
    setLoaded(); // Завершение загрузки
  }

  void onSearchChanged(String value) {
    searchQuery = value;
    notifyListeners();
  }

  // Navigation
  void onNavigateBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void onNavigateToSubjectProducts(int subjectId, String subjectName) {
    Navigator.of(context).pushNamed(
      MainNavigationRouteNames.subjectProductsScreen,
      arguments: {'subjectId': subjectId, 'subjectName': subjectName},
    );
  }
}
