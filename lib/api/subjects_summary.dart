import 'package:mc_dashboard/domain/entities/subjects_summary.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'subjects_summary.g.dart';

@RestApi(baseUrl: "http://localhost:2009")
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
