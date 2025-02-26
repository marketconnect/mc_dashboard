class WbBoxTariff {
  final String warehouseName;
  final String warehouseID;
  final double boxDeliveryAndStorageExpr;
  final double boxDeliveryBase;
  final double boxDeliveryLiter;
  final double boxStorageBase;
  final double boxStorageLiter;

  WbBoxTariff({
    required this.warehouseName,
    required this.warehouseID,
    required this.boxDeliveryAndStorageExpr,
    required this.boxDeliveryBase,
    required this.boxDeliveryLiter,
    required this.boxStorageBase,
    required this.boxStorageLiter,
  });

  factory WbBoxTariff.fromJson(Map<String, dynamic> json) {
    return WbBoxTariff(
      warehouseName: json['warehouseName'] ?? '',
      warehouseID: json['warehouseID'] ?? '',
      boxDeliveryAndStorageExpr:
          _parseDouble(json['boxDeliveryAndStorageExpr']),
      boxDeliveryBase: _parseDouble(json['boxDeliveryBase']),
      boxDeliveryLiter: _parseDouble(json['boxDeliveryLiter']),
      boxStorageBase: _parseDouble(json['boxStorageBase']),
      boxStorageLiter: _parseDouble(json['boxStorageLiter']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null || value == "-" || value.toString().trim().isEmpty) {
      return 0.0;
    }
    return double.tryParse(value.toString().replaceAll(',', '.')) ?? 0.0;
  }
}
