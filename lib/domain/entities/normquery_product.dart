import 'dart:math';

class NormqueryProduct {
  final int normqueryId;
  final String normquery;
  final int total;
  final int freq;
  final int pagePos;
  final int pageNumber;
  final int productId;

  NormqueryProduct({
    required this.normqueryId,
    required this.normquery,
    required this.total,
    required this.freq,
    required this.pagePos,
    required this.pageNumber,
    required this.productId,
  });

  factory NormqueryProduct.fromJson(Map<String, dynamic> json) {
    return NormqueryProduct(
      normqueryId: json['normquery_id'] as int,
      normquery: json['normquery'] as String,
      total: json['total'] as int,
      freq: json['freq'] as int,
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
      'freq': freq,
      'page_pos': pagePos,
      'page_number': pageNumber,
      'product_id': productId,
    };
  }
}

List<NormqueryProduct> generateRandomNormqueryProducts(int count) {
  final random = Random();
  final List<NormqueryProduct> products = [];

  for (int i = 0; i < count; i++) {
    final normqueryId = random.nextInt(10000);
    final productId = random.nextInt(1000);
    final pageNumber = random.nextInt(100) + 1;
    final pagePos = random.nextInt(10) + 1;
    final freq = random.nextInt(1000) + 1;
    final total = random.nextInt(10000) + 1;

    final someRandomKeywords = [
      "женская обувь",
      "летние платья",
      "мужские кроссовки",
      "аксессуары для авто",
      "косметика и парфюмерия",
      "спортивный инвентарь",
      "детские игрушки",
    ];
    products.add(NormqueryProduct(
      normqueryId: normqueryId,
      normquery:
          '${someRandomKeywords[random.nextInt(someRandomKeywords.length)]} $normqueryId',
      total: total,
      freq: freq,
      pagePos: pagePos,
      pageNumber: pageNumber,
      productId: productId,
    ));
  }

  return products;
}
