class NormqueryProduct {
  final int normqueryId;
  final String normquery;
  final int total;
  final int pagePos;
  final int pageNumber;
  final int productId;

  NormqueryProduct({
    required this.normqueryId,
    required this.normquery,
    required this.total,
    required this.pagePos,
    required this.pageNumber,
    required this.productId,
  });

  factory NormqueryProduct.fromJson(Map<String, dynamic> json) {
    return NormqueryProduct(
      normqueryId: json['normquery_id'] as int,
      normquery: json['normquery'] as String,
      total: json['total'] as int,
      pagePos: json['page_pos'] as int,
      pageNumber: json['page_number'] as int,
      productId: json['product_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'normquery_id': normqueryId,
      'normquery': normquery,
      'total': total,
      'page_pos': pagePos,
      'page_number': pageNumber,
      'product_id': productId,
    };
  }
}
