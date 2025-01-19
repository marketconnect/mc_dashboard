import 'package:mc_dashboard/.env.dart';

import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'subjects_summary.g.dart';

// TODO Add token
@RestApi(baseUrl: ApiSettings.baseUrl)
abstract class SubjectsSummaryApiClient {
  factory SubjectsSummaryApiClient(Dio dio, {String baseUrl}) =
      _SubjectsSummaryApiClient;

  @GET("/subjects-summary")
  Future<List<RawJsonMap>> getSubjectsSummaryAsDynamic({
    @Query("subject_id") int? subjectId,
    @Query("subject_name") String? subjectName,
    @Query("subject_parent_name") String? subjectParentName,
  });
}

/// Обёртка над Map<String, dynamic>
class RawJsonMap {
  final Map<String, dynamic> data;

  RawJsonMap(this.data);

  factory RawJsonMap.fromJson(Map<String, dynamic> json) {
    return RawJsonMap(Map<String, dynamic>.from(json));
  }
}
