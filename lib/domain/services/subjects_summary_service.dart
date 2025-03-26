import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/infrastructure/api/subjects_summary.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/domain/entities/subject_summary_item.dart';
import 'package:mc_dashboard/presentation/choosing_niche_screen/choosing_niche_view_model.dart';
import 'package:mc_dashboard/presentation/empty_subjects_screen/empty_subjects_view_model.dart';
import 'package:mc_dashboard/presentation/subject_products_screen/subject_products_view_model.dart';

class SubjectsSummaryService
    implements
        SubjectProductsSubjectSummaryService,
        ChoosingNicheViewModelSubjectsSummaryService,
        EmptySubjectViewModelSubjectsSummaryService {
  final SubjectsSummaryApiClient subjectsSummaryApiClient;

  static final SubjectsSummaryService instance = SubjectsSummaryService._();

  // Why singleton? This is a workaround . Because we need to fetch subjects summary only once
  // despite it is used in multiple screens simultaneously when app is loading
  // (choose niche, subject products, empty subjects)
  SubjectsSummaryService._()
      : subjectsSummaryApiClient = SubjectsSummaryApiClient();

  Completer<Either<AppErrorBase, List<SubjectSummaryItem>>>?
      _fetchSubjectsCompleter;

  @override
  Future<Either<AppErrorBase, List<SubjectSummaryItem>>> fetchSubjectsSummary(
      [int? subjectId]) async {
    try {
      if (_fetchSubjectsCompleter != null &&
          !_fetchSubjectsCompleter!.isCompleted) {
        return _fetchSubjectsCompleter!.future;
      }
      _fetchSubjectsCompleter =
          Completer<Either<AppErrorBase, List<SubjectSummaryItem>>>();

      final rawJsonMapList = await subjectsSummaryApiClient
          .getSubjectsSummaryAsDynamic(subjectId: subjectId);
      final parsedList = await compute(_parseSubjectsList, rawJsonMapList);

      //
      _fetchSubjectsCompleter!.complete(right(parsedList));
      return Right(parsedList);
    } catch (e) {
      return const Right([]);
    }
  }

  List<SubjectSummaryItem> _parseSubjectsList(List<dynamic> rawList) {
    return rawList.map((jsonItem) {
      return SubjectSummaryItem.fromJson(jsonItem.data as Map<String, dynamic>);
    }).toList();
  }
}
