class WbSellerStock {
  final String sku;
  final int amount;

  WbSellerStock({
    required this.sku,
    required this.amount,
  });

  factory WbSellerStock.fromJson(Map<String, dynamic> json) {
    // Debug print
    return WbSellerStock(
      sku: json['sku']?.toString() ?? '',
      amount: json['amount'] ?? 0,
    );
  }

  @override
  String toString() => 'WbWarehouseStock(sku: $sku, amount: $amount)';
}
