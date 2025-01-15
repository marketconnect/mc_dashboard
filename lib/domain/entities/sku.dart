class Sku {
  final String id;
  final String marketplaceType;

  Sku({
    required this.id,
    required this.marketplaceType,
  });

  factory Sku.fromJson(Map<String, dynamic> json) => Sku(
        id: json['id'] as String,
        marketplaceType: json['marketplace_type'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'marketplace_type': marketplaceType,
      };
}
