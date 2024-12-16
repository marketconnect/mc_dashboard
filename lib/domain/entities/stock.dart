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

List<Map<String, dynamic>> calculateWarehouseShares(
    List<Stock> stocks, List<Warehouse> warehouses) {
  final warehouseQuantities = <int, int>{};

  // Суммируем количество товаров для каждого склада
  for (final stock in stocks) {
    warehouseQuantities[stock.warehouseId] =
        (warehouseQuantities[stock.warehouseId] ?? 0) + stock.quantity;
  }

  // Вычисляем общее количество товаров на всех складах
  final totalQuantity =
      warehouseQuantities.values.fold(0, (sum, qty) => sum + qty);

  // Преобразуем в нужный формат
  final warehouseShares = warehouseQuantities.entries.map((entry) {
    final warehouseId = entry.key;
    final quantity = entry.value;
    final whNames = warehouses.where((element) => element.id == warehouseId);
    String whName = "";
    if (whNames.isNotEmpty) {
      whName = whNames.first.name;
    }

    return {
      "name": whName,
      "value":
          totalQuantity > 0 ? (quantity / totalQuantity * 100).toDouble() : 0.0,
    };
  }).toList();

  return warehouseShares;
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
