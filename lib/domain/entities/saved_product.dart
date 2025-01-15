import 'package:hive/hive.dart';

part 'saved_product.g.dart';

@HiveType(typeId: 0)
class SavedProduct {
  @HiveField(0)
  final String productId;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String imageUrl;

  @HiveField(3)
  final int sellerId;

  @HiveField(4)
  final String sellerName;

  @HiveField(5)
  final int brandId;

  @HiveField(6)
  final String brandName;

  @HiveField(7)
  final String marketplaceType;

  SavedProduct({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.sellerId,
    required this.sellerName,
    required this.brandId,
    required this.brandName,
    required this.marketplaceType,
  });
}
