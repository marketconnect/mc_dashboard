class OzonProduct {
  final bool archived;
  final bool hasFboStocks;
  final bool hasFbsStocks;
  final bool isDiscounted;
  final String offerId;
  final int productId;
  final List<String> images;

  String get imageUrl => images.isNotEmpty ? images.first : "";

  OzonProduct({
    required this.archived,
    required this.hasFboStocks,
    required this.hasFbsStocks,
    required this.isDiscounted,
    required this.offerId,
    required this.productId,
    required this.images,
  });

  factory OzonProduct.fromJson(Map<String, dynamic> json) {
    return OzonProduct(
      archived: json['archived'] ?? false,
      hasFboStocks: json['has_fbo_stocks'] ?? false,
      hasFbsStocks: json['has_fbs_stocks'] ?? false,
      isDiscounted: json['is_discounted'] ?? false,
      offerId: json['offer_id'] ?? '',
      productId: json['product_id'] ?? 0,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class OzonProductsResponse {
  final List<OzonProduct> items;
  final String? lastId;
  final int total;

  OzonProductsResponse({
    required this.items,
    this.lastId,
    required this.total,
  });

  factory OzonProductsResponse.fromJson(Map<String, dynamic> json) {
    final result =
        json['result'] as Map<String, dynamic>; // Access the result object
    return OzonProductsResponse(
      items: (result['items'] as List<dynamic>)
          .map((e) => OzonProduct.fromJson(e))
          .toList(),
      lastId: result['last_id'], // Access last_id from the result object
      total: result['total'] ?? 0, // Access total from the result object
    );
  }
}
