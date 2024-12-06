import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/api/subjects_summary.dart';
import 'package:mc_dashboard/core/utils/app_error.dart';
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
      print("fetchSubjectsSummary");
      final result = await subjectsSummaryApiClient.getSubjectsSummary();

      return Right(result);
    } on DioException catch (e, stackTrace) {
      print(e);
      final message = e.response?.data['error'] ?? "Unknown error occurred";
      final error = AppErrorBase(
        message,
        name: "fetchSubjectsSummary",
        sendToTg: true,
        source: "ApiHandler",
        args: [],
        stackTrace: stackTrace.toString(),
      );
      AppLogger.log(error);
      return Left(error);
    } catch (e, stackTrace) {
      final error = AppErrorBase(
        "Unexpected error: $e",
        name: "fetchSubjectsSummary",
        sendToTg: true,
        source: "ApiHandler",
        args: [],
        stackTrace: stackTrace.toString(),
      );
      AppLogger.log(error);
      return Left(error);
    }
  }
}
