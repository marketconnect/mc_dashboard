class DetailedOrderItem {
  final int productId;
  final int subjectId;
  final int price;
  final int orders;
  final int isFbs;
  final int basket;
  final int brandId;
  final String brand;
  final int supplierId;
  final String supplier;

  DetailedOrderItem({
    required this.productId,
    required this.subjectId,
    required this.price,
    required this.orders,
    required this.isFbs,
    required this.basket,
    required this.brandId,
    required this.brand,
    required this.supplierId,
    required this.supplier,
  });

  factory DetailedOrderItem.fromJson(Map<String, dynamic> json) {
    return DetailedOrderItem(
      productId: json['product_id'] as int,
      subjectId: json['subject_id'] as int,
      price: json['price'] as int,
      orders: json['orders'] as int,
      isFbs: json['is_fbs'] as int,
      basket: json['basket'] as int,
      brandId: json['brand_id'] as int,
      brand: json['brand'] as String,
      supplierId: json['supplier_id'] as int,
      supplier: json['supplier'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'subject_id': subjectId,
      'price': price,
      'orders': orders,
      'is_fbs': isFbs,
      'basket': basket,
      'brand_id': brandId,
      'brand': brand,
      'supplier_id': supplierId,
      'supplier': supplier,
    };
  }

  DetailedOrderItem copyWith({
    int? productId,
    int? subjectId,
    int? price,
    int? orders,
    int? isFbs,
    int? basket,
    int? brandId,
    String? brand,
    int? supplierId,
    String? supplier,
  }) {
    return DetailedOrderItem(
      productId: productId ?? this.productId,
      subjectId: subjectId ?? this.subjectId,
      price: price ?? this.price,
      orders: orders ?? this.orders,
      isFbs: isFbs ?? this.isFbs,
      basket: basket ?? this.basket,
      brandId: brandId ?? this.brandId,
      brand: brand ?? this.brand,
      supplierId: supplierId ?? this.supplierId,
      supplier: supplier ?? this.supplier,
    );
  }
}

class DetailedOrdersResponse {
  final List<DetailedOrderItem> detailedOrders;

  DetailedOrdersResponse({required this.detailedOrders});

  factory DetailedOrdersResponse.fromJson(Map<String, dynamic> json) {
    return DetailedOrdersResponse(
      detailedOrders: (json['detailed_orders30d'] as List)
          .map((item) => DetailedOrderItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detailed_orders30d':
          detailedOrders.map((item) => item.toJson()).toList(),
    };
  }
}
