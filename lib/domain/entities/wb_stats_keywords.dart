class WbStatsKeywords {
  final int clicks;
  final double ctr;
  final String keyword;
  final double sum;
  final int views;

  WbStatsKeywords({
    required this.clicks,
    required this.ctr,
    required this.keyword,
    required this.sum,
    required this.views,
  });

  factory WbStatsKeywords.fromJson(Map<String, dynamic> json) {
    return WbStatsKeywords(
      clicks: json['clicks'] as int,
      ctr: (json['ctr'] as num).toDouble(),
      keyword: json['keyword'] as String,
      sum: (json['sum'] as num).toDouble(),
      views: json['views'] as int,
    );
  }
}
