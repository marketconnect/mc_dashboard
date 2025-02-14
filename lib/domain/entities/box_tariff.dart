import 'dart:convert';

class BoxTariff {
  final double boxDeliveryAndStorageExpr;
  final double boxDeliveryBase;
  final double boxDeliveryLiter;
  final double? boxStorageBase;
  final double? boxStorageLiter;
  final String warehouseName;

  BoxTariff({
    required this.boxDeliveryAndStorageExpr,
    required this.boxDeliveryBase,
    required this.boxDeliveryLiter,
    this.boxStorageBase,
    this.boxStorageLiter,
    required this.warehouseName,
  });

  factory BoxTariff.fromJson(Map<String, dynamic> json) {
    return BoxTariff(
      boxDeliveryAndStorageExpr:
          _parseDouble(json['boxDeliveryAndStorageExpr']),
      boxDeliveryBase: _parseDouble(json['boxDeliveryBase']),
      boxDeliveryLiter: _parseDouble(json['boxDeliveryLiter']),
      boxStorageBase: json['boxStorageBase'] != "-"
          ? _parseDouble(json['boxStorageBase'])
          : null,
      boxStorageLiter: json['boxStorageLiter'] != "-"
          ? _parseDouble(json['boxStorageLiter'])
          : null,
      warehouseName: _fixEncoding(json['warehouseName']),
    );
  }

  static double _parseDouble(String? value) {
    if (value == null || value.isEmpty) return 0.0;
    return double.parse(value.replaceAll(',', '.'));
  }

  static String _fixEncoding(String text) {
    try {
      return utf8.decode(text.runes.toList());
    } catch (e) {
      return text;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'boxDeliveryAndStorageExpr': boxDeliveryAndStorageExpr,
      'boxDeliveryBase': boxDeliveryBase,
      'boxDeliveryLiter': boxDeliveryLiter,
      'boxStorageBase': boxStorageBase,
      'boxStorageLiter': boxStorageLiter,
      'warehouseName': warehouseName,
    };
  }
}
