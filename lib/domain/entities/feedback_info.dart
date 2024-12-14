class FeedbackInfo {
  final Map<String, int> valuationDistributionPercent;
  final String valuation;
  final List<String> pros;
  final List<String> cons;

  FeedbackInfo({
    required this.valuationDistributionPercent,
    required this.valuation,
    required this.pros,
    required this.cons,
  });

  factory FeedbackInfo.fromJson(Map<String, dynamic> json) {
    final feedbacks = json['feedbacks'] as List<dynamic>? ?? [];
    final prosList = <String>[];
    final consList = <String>[];

    for (var feedback in feedbacks) {
      if (feedback['pros'] != null && feedback['pros'].isNotEmpty) {
        prosList.add(feedback['pros']);
      }
      if (feedback['cons'] != null && feedback['cons'].isNotEmpty) {
        consList.add(feedback['cons']);
      }
    }
    print(
        'prosList: ${prosList.length} consList: ${consList.length} valuation: ${json['valuation']} valuationDistributionPercent: ${json['valuationDistributionPercent']}');
    return FeedbackInfo(
      valuationDistributionPercent:
          Map<String, int>.from(json['valuationDistributionPercent']),
      valuation: json['valuation'],
      pros: prosList,
      cons: consList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'valuationDistributionPercent': valuationDistributionPercent,
      'valuation': valuation,
      'pros': pros,
      'cons': cons,
    };
  }
}
