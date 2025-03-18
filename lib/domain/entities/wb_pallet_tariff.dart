class WbPalletTariff {
  final String warehouseName;
  final double palletDeliveryExpr;
  final double palletDeliveryValueBase;
  final double palletDeliveryValueLiter;
  final double palletStorageExpr;
  final double palletStorageValueExpr;

  WbPalletTariff({
    required this.warehouseName,
    required this.palletDeliveryExpr,
    required this.palletDeliveryValueBase,
    required this.palletDeliveryValueLiter,
    required this.palletStorageExpr,
    required this.palletStorageValueExpr,
  });

  factory WbPalletTariff.fromJson(Map<String, dynamic> json) {
    return WbPalletTariff(
      warehouseName: json['warehouseName'] ?? '',
      palletDeliveryExpr: _parseDouble(json['palletDeliveryExpr']),
      palletDeliveryValueBase: _parseDouble(json['palletDeliveryValueBase']),
      palletDeliveryValueLiter: _parseDouble(json['palletDeliveryValueLiter']),
      palletStorageExpr: _parseDouble(json['palletStorageExpr']),
      palletStorageValueExpr: _parseDouble(json['palletStorageValueExpr']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null || value == "-" || value.toString().trim().isEmpty) {
      return 0.0;
    }
    return double.tryParse(value.toString().replaceAll(',', '.')) ?? 0.0;
  }
}
