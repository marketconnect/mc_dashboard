import 'package:mc_dashboard/domain/entities/warehouse.dart';

class Stock {
  final int productId;
  final int warehouseId;
  final int sizeOptionId;
  final int quantity;
  final int basicPrice;
  final DateTime timestamp;

  Stock({
    required this.productId,
    required this.warehouseId,
    required this.sizeOptionId,
    required this.quantity,
    required this.basicPrice,
    required this.timestamp,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return Stock(
      productId: parseInt(json['product_id']),
      warehouseId: parseInt(json['warehouse_id']),
      sizeOptionId: parseInt(json['size_option_id']),
      quantity: parseInt(json['quantity']),
      basicPrice: parseInt(json['basic_price']),
      timestamp: json['timestamp'] != null && json['timestamp'] is String
          ? DateTime.tryParse(json['timestamp'] as String) ??
              DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'warehouse_id': warehouseId,
      'size_option_id': sizeOptionId,
      'quantity': quantity,
      'basic_price': basicPrice,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

(List<Map<String, dynamic>>, int) calculateWarehouseShares(
    List<Stock> stocks, List<Warehouse> warehouses) {
  DateTime latestDate = stocks
      .map((stock) => stock.timestamp)
      .reduce((a, b) => a.isAfter(b) ? a : b);

  final filteredStocks = stocks
      .where((stock) =>
          stock.timestamp.year == latestDate.year &&
          stock.timestamp.month == latestDate.month &&
          stock.timestamp.day == latestDate.day)
      .toList();

  final warehouseQuantities = <int, int>{};
  for (final stock in filteredStocks) {
    warehouseQuantities[stock.warehouseId] =
        (warehouseQuantities[stock.warehouseId] ?? 0) + stock.quantity;
  }

  final totalQuantity =
      warehouseQuantities.values.fold(0, (sum, qty) => sum + qty);

  final warehouseShares = warehouseQuantities.entries.map((entry) {
    final warehouseId = entry.key;
    final quantity = entry.value;

    final whNames = warehouses.where((element) => element.id == warehouseId);
    String whName = "";
    if (whNames.isNotEmpty) {
      whName = whNames.first.name;
    } else {
      whName = 'СкладwarehouseId';
    }

    return {
      "name": whName,
      "value": quantity,
    };
  }).toList();
  warehouseShares.sort((a, b) {
    final aValue = (a["value"] as num?) ?? 0;
    final bValue = (b["value"] as num?) ?? 0;

    return bValue.compareTo(aValue);
  });

  return (warehouseShares, totalQuantity);
}

Map<String, int> calculateDailyStockSums(List<Stock> stocks) {
  final dailySums = <String, int>{};

  for (final stock in stocks) {
    final dateKey = "${stock.timestamp.year.toString().padLeft(4, '0')}-"
        "${stock.timestamp.month.toString().padLeft(2, '0')}-"
        "${stock.timestamp.day.toString().padLeft(2, '0')}";

    dailySums[dateKey] = (dailySums[dateKey] ?? 0) + stock.quantity;
  }

  return dailySums;
}
