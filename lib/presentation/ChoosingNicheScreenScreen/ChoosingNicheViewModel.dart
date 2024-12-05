import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/core/utils/app_error.dart';
import 'package:mc_dashboard/domain/entities/subjects_summary.dart';

abstract class ChoosingNicheViewModelSubjectsSummaryService {
  Future<Either<AppErrorBase, List<SubjectSummaryItem>>> fetchSubjectsSummary();
}

class ChoosingNicheViewModel extends ChangeNotifier {
  final ChoosingNicheViewModelSubjectsSummaryService subjectsSummaryService;

  ChoosingNicheViewModel({required this.subjectsSummaryService}) {
    _asyncInit();
  }

  List<SubjectSummaryItem> subjectsSummary = [];

  _asyncInit() async {
    final result = await subjectsSummaryService.fetchSubjectsSummary();
    if (result.isRight()) {
      print("ok");
      subjectsSummary =
          result.fold((l) => throw UnimplementedError(), (r) => r);
    }
    notifyListeners();
  }
}
