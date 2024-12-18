import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';
import 'package:mc_dashboard/domain/entities/subject_summary_item.dart';

abstract class EmptySubjectViewModelSubjectsSummaryService {
  Future<Either<AppErrorBase, List<SubjectSummaryItem>>> fetchSubjectsSummary();
}

class EmptySubjectViewModel extends ViewModelBase {
  EmptySubjectViewModel(
      {required super.context,
      required this.subjectsSummaryService,
      required this.onNavigateBack,
      required this.onNavigateToSubjectProducts}) {
    _asyncInit();
  }
  final EmptySubjectViewModelSubjectsSummaryService subjectsSummaryService;
  final void Function(int subjectId, String subjectName)
      onNavigateToSubjectProducts;
  final void Function() onNavigateBack;
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

  _asyncInit() async {
    setLoading();
    final result = await subjectsSummaryService.fetchSubjectsSummary();

    if (result.isRight()) {
      final fetchedSubjectsSummary =
          result.fold((l) => throw UnimplementedError(), (r) => r);

      setSubjectsSummary(fetchedSubjectsSummary);
    } else {
      setError("Сервер временно недоступен");
    }

    setLoaded();
  }

  void onSearchChanged(String value) {
    searchQuery = value;
    notifyListeners();
  }
}
