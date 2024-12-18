import 'package:mc_dashboard/.env.dart';
import 'package:mc_dashboard/domain/entities/subject_summary_item.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'subjects_summary.g.dart';

@RestApi(baseUrl: ApiSettings.baseUrl)
abstract class SubjectsSummaryApiClient {
  factory SubjectsSummaryApiClient(Dio dio, {String baseUrl}) =
      _SubjectsSummaryApiClient;

  @GET("/subjects-summary")
  Future<List<SubjectSummaryItem>> getSubjectsSummary({
    @Query("subject_id") int? subjectId,
    @Query("subject_name") String? subjectName,
    @Query("subject_parent_name") String? subjectParentName,
  });
}
