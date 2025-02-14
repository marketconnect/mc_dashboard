class WbProduct {
  final int id;
  final String name;
  final String brand;
  final int brandId;
  final int subjectId;
  final int supplierId;
  final double rating;
  final int feedbacks;
  final int volume;
  final int pics;
  final double
      price; // Изменил на double для корректного представления в рублях
  final List<int> promotions;

  WbProduct({
    required this.id,
    required this.name,
    required this.brand,
    required this.brandId,
    required this.subjectId,
    required this.supplierId,
    required this.rating,
    required this.feedbacks,
    required this.volume,
    required this.pics,
    required this.price,
    required this.promotions,
  });

  factory WbProduct.fromJson(Map<String, dynamic> json) {
    return WbProduct(
      id: json['id'] as int,
      name: json['name'] as String,
      brand: json['brand'] as String,
      brandId: json['brandId'] as int,
      subjectId: json['subjectId'] as int,
      supplierId: json['supplierId'] as int,
      rating: (json['rating'] as num).toDouble(),
      feedbacks: json['feedbacks'] as int,
      volume: json['volume'] as int,
      pics: json['pics'] as int,
      price: ((json['sizes'] as List<dynamic>)
              .map((size) => size['price']['total'] as int)
              .reduce((a, b) => a < b ? a : b)) /
          100, // Переводим в рубли
      promotions:
          (json['promotions'] as List<dynamic>).map((e) => e as int).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'brandId': brandId,
      'subjectId': subjectId,
      'supplierId': supplierId,
      'rating': rating,
      'feedbacks': feedbacks,
      'volume': volume,
      'pics': pics,
      'price': price, // Теперь цена в рублях
      'promotions': promotions,
    };
  }
}
