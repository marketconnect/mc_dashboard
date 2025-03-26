class WbSellerWarehouse {
  final int id;
  final String name;
  final int officeId;

  WbSellerWarehouse({
    required this.id,
    required this.name,
    required this.officeId,
  });

  factory WbSellerWarehouse.fromJson(Map<String, dynamic> json) {
    return WbSellerWarehouse(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      officeId: json['officeId'] ?? 0,
    );
  }
}
