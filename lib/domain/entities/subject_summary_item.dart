import 'dart:convert';

class SubjectSummaryItem {
  final int subjectId;
  final String subjectName;
  final String? subjectParentName;
  final int totalRevenue;
  final int totalOrders;
  final int totalSkus;
  final int medianPrice;
  final int skusWithOrders;
  final String historyData;
  Map<String, dynamic> get decodedHistoryData => jsonDecode(historyData);
  SubjectSummaryItem({
    required this.subjectId,
    required this.subjectName,
    this.subjectParentName,
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalSkus,
    required this.medianPrice,
    required this.skusWithOrders,
    required this.historyData,
  });

  factory SubjectSummaryItem.fromJson(Map<String, dynamic> json) {
    return SubjectSummaryItem(
      subjectId: json['subject_id'],
      subjectName: json['subject_name'],
      subjectParentName: json['subject_parent_name'],
      totalRevenue: json['total_revenue'],
      totalOrders: json['total_orders'],
      totalSkus: json['total_skus'],
      medianPrice: json['median_price'],
      skusWithOrders: json['skus_with_orders'],
      historyData: json['history_data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject_id': subjectId,
      'subject_name': subjectName,
      'subject_parent_name': subjectParentName,
      'total_revenue': totalRevenue,
      'total_orders': totalOrders,
      'total_skus': totalSkus,
      'median_price': medianPrice,
      'skus_with_orders': skusWithOrders,
      'history_data': historyData,
    };
  }

  copyWith({
    int? subjectId,
    String? subjectName,
    String? subjectParentName,
    int? totalRevenue,
    int? totalOrders,
    int? totalSkus,
    int? medianPrice,
    int? skusWithOrders,
    String? historyData,
  }) {
    return SubjectSummaryItem(
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      subjectParentName: subjectParentName ?? this.subjectParentName,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSkus: totalSkus ?? this.totalSkus,
      medianPrice: medianPrice ?? this.medianPrice,
      skusWithOrders: skusWithOrders ?? this.skusWithOrders,
      historyData: historyData ?? this.historyData,
    );
  }
}
