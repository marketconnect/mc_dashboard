class ProductItem {
  final int id;
  final int brandId;
  final int subjectId;
  final int supplierId;

  ProductItem({
    required this.id,
    required this.brandId,
    required this.subjectId,
    required this.supplierId,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      id: json['id'] as int,
      brandId: json['brand_id'] as int,
      subjectId: json['subject_id'] as int,
      supplierId: json['supplier_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand_id': brandId,
      'subject_id': subjectId,
      'supplier_id': supplierId,
    };
  }
}
