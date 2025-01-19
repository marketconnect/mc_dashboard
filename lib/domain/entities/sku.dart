class Sku {
  final String id;
  final String marketplaceType;
  final String sellerId;
  final String sellerName;
  final String brandId;
  final String brandName;

  Sku({
    required this.id,
    required this.marketplaceType,
    required this.sellerId,
    required this.sellerName,
    required this.brandId,
    required this.brandName,
  });

  factory Sku.fromJson(Map<String, dynamic> json) => Sku(
        id: json['id'] as String,
        marketplaceType: json['marketplace_type'] as String,
        sellerId: json['seller_id'] as String,
        sellerName: json['seller_name'] as String,
        brandId: json['brand_id'] as String,
        brandName: json['brand_name'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'marketplace_type': marketplaceType,
        'seller_id': sellerId,
        'seller_name': sellerName,
        'brand_id': brandId,
        'brand_name': brandName,
      };
}
