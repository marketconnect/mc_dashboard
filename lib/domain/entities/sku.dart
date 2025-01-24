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

  factory Sku.fromJson(Map<String, dynamic> json) {
    return Sku(
      id: json['id']?.toString() ?? '',
      marketplaceType: json['marketplace_type']?.toString() ?? '',
      sellerId: json['seller_id']?.toString() ?? '',
      sellerName: json['seller_name']?.toString() ?? '',
      brandId: json['brand_id']?.toString() ?? '',
      brandName: json['brand_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'marketplace_type': marketplaceType,
        'seller_id': sellerId,
        'seller_name': sellerName,
        'brand_id': brandId,
        'brand_name': brandName,
      };
}
