class WbProductSize {
  final int chrtID;
  final String techSize;
  final List<String> skus;

  WbProductSize({
    required this.chrtID,
    required this.techSize,
    required this.skus,
  });

  factory WbProductSize.fromJson(Map<String, dynamic> json) {
    return WbProductSize(
      chrtID: json['chrtID'] as int? ?? 0,
      techSize: json['techSize'] as String? ?? '',
      skus:
          (json['skus'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
              [],
    );
  }
}
