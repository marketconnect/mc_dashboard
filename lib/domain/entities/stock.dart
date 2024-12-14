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
    return Stock(
      productId: json['product_id'] as int? ?? 0,
      warehouseId: json['warehouse_id'] as int? ?? 0,
      sizeOptionId: json['size_option_id'] as int? ?? 0,
      quantity: json['quantity'] as int? ?? 0,
      basicPrice: json['basic_price'] as int? ?? 0,
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

List<Map<String, dynamic>> calculateWarehouseShares(List<Stock> stocks) {
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

    return {
      "name": "Склад $warehouseId", // Пример: добавляем "Склад" перед ID
      "value":
          totalQuantity > 0 ? (quantity / totalQuantity * 100).toDouble() : 0.0,
    };
  }).toList();

  return warehouseShares;
}
