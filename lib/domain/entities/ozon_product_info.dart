class OzonProductInfo {
  final int productId;
  final String offerId;
  final List<String> images;
  final List<String> primaryImage;

  String get image => primaryImage.isEmpty ? images.first : primaryImage.first;

  OzonProductInfo({
    required this.productId,
    required this.offerId,
    required this.images,
    required this.primaryImage,
  });

  factory OzonProductInfo.fromJson(Map<String, dynamic> json) {
    return OzonProductInfo(
      productId: json['product_id'] ?? 0,
      offerId: json['offer_id'] ?? '',
      images: (json['images'] as List<dynamic>?)
              ?.map((image) => image.toString())
              .toList() ??
          [],
      primaryImage: (json['primary_image'] as List<dynamic>?)
              ?.map((image) => image.toString())
              .toList() ??
          [],
    );
  }
}

class OzonProductPicture {
  final bool is360;
  final bool isColor;
  final bool isPrimary;
  final int productId;
  final String state;
  final String url;

  OzonProductPicture({
    required this.is360,
    required this.isColor,
    required this.isPrimary,
    required this.productId,
    required this.state,
    required this.url,
  });

  factory OzonProductPicture.fromJson(Map<String, dynamic> json) {
    return OzonProductPicture(
      is360: json['is_360'] ?? false,
      isColor: json['is_color'] ?? false,
      isPrimary: json['is_primary'] ?? false,
      productId: json['product_id'] ?? 0,
      state: json['state'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

class OzonProductInfoResponse {
  final List<OzonProductInfo> items;

  OzonProductInfoResponse({
    required this.items,
  });

  factory OzonProductInfoResponse.fromJson(Map<String, dynamic> json) {
    return OzonProductInfoResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => OzonProductInfo.fromJson(e))
          .toList(),
    );
  }
}
