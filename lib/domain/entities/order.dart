import 'package:mc_dashboard/domain/entities/warehouse.dart';

class OrderWb {
  final int productId;
  final int sizeOptionId;
  final int warehouseId;
  final int price;
  final int orders;
  final DateTime timestamp;

  OrderWb({
    required this.productId,
    required this.sizeOptionId,
    required this.warehouseId,
    required this.price,
    required this.orders,
    required this.timestamp,
  });

  factory OrderWb.fromJson(Map<String, dynamic> json) {
    return OrderWb(
      productId: json['product_id'] as int,
      sizeOptionId: json['size_option_id'] as int,
      warehouseId: json['warehouse_id'] as int,
      price: json['price'] as int,
      orders: json['orders'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'size_option_id': sizeOptionId,
      'warehouse_id': warehouseId,
      'price': price,
      'orders': orders,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

List<Map<String, dynamic>> aggregateOrdersByDay(List<OrderWb> orders) {
  final Map<DateTime, int> aggregatedOrders = {};

  for (var order in orders) {
    final date = DateTime(
        order.timestamp.year, order.timestamp.month, order.timestamp.day);
    aggregatedOrders[date] = (aggregatedOrders[date] ?? 0) + order.orders;
  }

  // List<int> values = aggregatedOrders.values.toList();
  // if (values.isNotEmpty) {
  //   values.sort();
  //   final q1 = values[(values.length * 0.25).toInt()];
  //   final q3 = values[(values.length * 0.75).toInt()];
  //   final iqr = q3 - q1;
  //   // final lowerBound = q1 - (1.5 * iqr);
  //   final upperBound = q3 + (1.5 * iqr);

  //   aggregatedOrders
  //       .removeWhere((_, totalOrders) => totalOrders > (upperBound * 5));
  // }

  return aggregatedOrders.entries.map((entry) {
    return {
      'date': entry.key,
      'totalOrders': entry.value,
    };
  }).toList();
}

List<Map<String, dynamic>> aggregatePricesByDay(List<OrderWb> orders) {
  final Map<DateTime, List<int>> pricesByDate = {};

  for (var order in orders) {
    final date = DateTime(
        order.timestamp.year, order.timestamp.month, order.timestamp.day);
    if (order.price > 0) {
      pricesByDate.putIfAbsent(date, () => []).add(order.price);
    }
  }

  return pricesByDate.entries.map((entry) {
    final prices = entry.value;
    final price = prices.isNotEmpty
        ? prices.reduce((value, element) =>
            prices.where((p) => p == value).length >
                    prices.where((p) => p == element).length
                ? value
                : element)
        : 0; // Если все записи для дня с ценой 0, возвращаем 0

    return {
      'date': entry.key,
      'price': price,
    };
  }).toList();
}

int getTotalOrders(List<OrderWb> orders) {
  return orders.fold(0, (total, order) => total + order.orders);
}

Map<String, double> getTotalOrdersByWarehouse(
    List<OrderWb> orders, List<Warehouse> warehouses) {
  Map<int, int> warehouseOrders = {};

  for (var order in orders) {
    if (order.orders == 0) {
      continue;
    }
    warehouseOrders.update(
      order.warehouseId,
      (currentSum) => currentSum + order.orders,
      ifAbsent: () => order.orders,
    );
  }

  return warehouseOrders.map((key, value) {
    String whName = '';
    final warehousesNames = warehouses.where((e) => e.id == key);
    if (warehousesNames.isNotEmpty) {
      whName = warehousesNames.first.name;
    }
    return MapEntry(whName, value.toDouble());
  });
}

// Map<String, double> transformMap(Map<int, int> inputMap) {
//   return inputMap.map((key, value) {
//     return MapEntry(key.toString(), value.toDouble());
//   });
// }
