class SupplierItem {
  final int id;
  final String name;

  SupplierItem({
    required this.id,
    required this.name,
  });

  factory SupplierItem.fromJson(Map<String, dynamic> json) {
    return SupplierItem(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class SuppliersResponse {
  final List<SupplierItem> suppliers;

  SuppliersResponse({required this.suppliers});

  factory SuppliersResponse.fromJson(dynamic json) {
    // Поскольку сервер возвращает массив, проверяем тип json
    if (json is List) {
      return SuppliersResponse(
        suppliers: json
            .map((item) => SupplierItem.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } else {
      throw Exception('Invalid response format: Expected a list');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'suppliers': suppliers.map((item) => item.toJson()).toList(),
    };
  }
}
