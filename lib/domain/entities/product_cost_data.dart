import 'package:hive/hive.dart';

part 'product_cost_data.g.dart';

@HiveType(typeId: 1)
class ProductCostData extends HiveObject {
  @HiveField(0)
  final int nmID;

  @HiveField(1)
  double costPrice;

  @HiveField(2)
  double delivery;

  @HiveField(3)
  double packaging;

  @HiveField(4)
  double paidAcceptance;

  @HiveField(5)
  String warehouseName;

  @HiveField(6, defaultValue: 10.0)
  double returnRate;

  @HiveField(7, defaultValue: 7)
  int taxRate;

  @HiveField(8, defaultValue: 30)
  double desiredMargin1;

  @HiveField(9, defaultValue: 20)
  double desiredMargin2;

  @HiveField(10, defaultValue: 15)
  double desiredMargin3;

  @HiveField(11, defaultValue: 0)
  double calculatedPrice1;

  @HiveField(12, defaultValue: 0)
  double calculatedPrice2;

  @HiveField(13, defaultValue: 0)
  double calculatedPrice3;

  @HiveField(14, defaultValue: true)
  bool isBox;

  ProductCostData({
    required this.nmID,
    required this.costPrice,
    required this.delivery,
    required this.packaging,
    required this.paidAcceptance,
    this.isBox = true,
    String? warehouseName,
    this.returnRate = 10.0,
    this.taxRate = 7,
    this.desiredMargin1 = 30,
    this.desiredMargin2 = 20,
    this.desiredMargin3 = 15,
    this.calculatedPrice1 = 0,
    this.calculatedPrice2 = 0,
    this.calculatedPrice3 = 0,
  }) : warehouseName = warehouseName ?? "Маркетплейс";

  ProductCostData copyWith({
    int? nmID,
    double? costPrice,
    double? delivery,
    double? packaging,
    double? paidAcceptance,
    String? warehouseName,
    double? returnRate,
    int? taxRate,
    double? desiredMargin1,
    double? desiredMargin2,
    double? desiredMargin3,
    double? calculatedPrice1,
    double? calculatedPrice2,
    double? calculatedPrice3,
    bool? isBox,
  }) {
    return ProductCostData(
      nmID: nmID ?? this.nmID,
      costPrice: costPrice ?? this.costPrice,
      delivery: delivery ?? this.delivery,
      packaging: packaging ?? this.packaging,
      paidAcceptance: paidAcceptance ?? this.paidAcceptance,
      warehouseName: warehouseName ?? this.warehouseName,
      returnRate: returnRate ?? this.returnRate,
      taxRate: taxRate ?? this.taxRate,
      desiredMargin1: desiredMargin1 ?? this.desiredMargin1,
      desiredMargin2: desiredMargin2 ?? this.desiredMargin2,
      desiredMargin3: desiredMargin3 ?? this.desiredMargin3,
      calculatedPrice1: calculatedPrice1 ?? this.calculatedPrice1,
      calculatedPrice2: calculatedPrice2 ?? this.calculatedPrice2,
      calculatedPrice3: calculatedPrice3 ?? this.calculatedPrice3,
      isBox: isBox ?? this.isBox,
    );
  }
}
