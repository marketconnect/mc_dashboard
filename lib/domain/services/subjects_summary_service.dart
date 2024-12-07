import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/api/subjects_summary.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/domain/entities/subject_summary_item.dart';
import 'package:mc_dashboard/presentation/choosing_niche_screen/choosing_niche_view_model.dart';

class SubjectsSummaryService
    implements ChoosingNicheViewModelSubjectsSummaryService {
  final SubjectsSummaryApiClient subjectsSummaryApiClient;

  SubjectsSummaryService({required this.subjectsSummaryApiClient});
  @override
  Future<Either<AppErrorBase, List<SubjectSummaryItem>>>
      fetchSubjectsSummary() async {
    try {
      final result = await subjectsSummaryApiClient.getSubjectsSummary();

      return Right(result);
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
}
