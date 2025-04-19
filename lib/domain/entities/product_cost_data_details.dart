import 'package:hive/hive.dart';

part 'product_cost_data_details.g.dart';

@HiveType(typeId: 2)
class ProductCostDataDetails extends HiveObject {
  @HiveField(0)
  final int nmID;

  @HiveField(1)
  final String
      costType; // 'costPrice', 'delivery', 'packaging', 'paidAcceptance'

  @HiveField(2)
  final String name;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  String? description;

  @HiveField(5, defaultValue: 'wb')
  String mpType;

  ProductCostDataDetails({
    required this.nmID,
    required this.costType,
    required this.name,
    required this.amount,
    this.description,
    this.mpType = 'wb',
  });

  ProductCostDataDetails copyWith({
    int? nmID,
    String? costType,
    String? name,
    double? amount,
    String? description,
    String? mpType,
  }) {
    return ProductCostDataDetails(
      nmID: nmID ?? this.nmID,
      costType: costType ?? this.costType,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      mpType: mpType ?? this.mpType,
    );
  }

  @override
  String toString() {
    return 'ProductCostDataDetails(nmID: $nmID, costType: $costType, name: $name, amount: $amount, description: $description, mpType: $mpType)';
  }
}
