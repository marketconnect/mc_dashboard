import 'package:dio/dio.dart';
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

  SubjectsSummaryService({required this.subjectsSummaryApiClient});
  @override
  Future<Either<AppErrorBase, List<SubjectSummaryItem>>> fetchSubjectsSummary(
      [int? subjectId]) async {
    try {
      // final result = await subjectsSummaryApiClient.getSubjectsSummaryAsDynamic();
      final rawJsonMapList = await subjectsSummaryApiClient
          .getSubjectsSummaryAsDynamic(subjectId: subjectId);
      final parsedList = await compute(_parseSubjectsList, rawJsonMapList);

      return Right(parsedList);
    } on DioException catch (e, stackTrace) {
      final message = e.response?.data['error'] ??
          "Unknown error occurred while fetching subjects summary";
      final error = AppErrorBase(
        message,
        name: "fetchSubjectsSummary",
        sendTo: true,
        source: "SubjectsSummaryService",
        args: [],
        stackTrace: stackTrace.toString(),
      );
      AppLogger.log(error);
      return Left(error);
    } catch (e, stackTrace) {
      final error = AppErrorBase(
        "Unexpected error: $e",
        name: "fetchSubjectsSummary",
        sendTo: true,
        source: "ApiHandler",
        args: [],
        stackTrace: stackTrace.toString(),
      );
      AppLogger.log(error);
      return Left(error);
    }
  }

  List<SubjectSummaryItem> _parseSubjectsList(List<dynamic> rawList) {
    return rawList.map((jsonItem) {
      return SubjectSummaryItem.fromJson(jsonItem.data as Map<String, dynamic>);
    }).toList();
  }
}
