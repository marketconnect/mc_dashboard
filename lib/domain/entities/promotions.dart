class Promotion {
  final int id;
  final String name;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String type;

  Promotion({
    required this.id,
    required this.name,
    required this.startDateTime,
    required this.endDateTime,
    required this.type,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'] as int,
      name: json['name'] as String,
      startDateTime: DateTime.parse(json['startDateTime']),
      endDateTime: DateTime.parse(json['endDateTime']),
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startDateTime': startDateTime.toIso8601String(),
      'endDateTime': endDateTime.toIso8601String(),
      'type': type,
    };
  }
}

class PromotionDetails {
  final int id;
  final String name;
  final String description;
  final List<String> advantages;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final int inPromoActionLeftovers;
  final int inPromoActionTotal;
  final int notInPromoActionLeftovers;
  final int notInPromoActionTotal;
  final int participationPercentage;
  final String type;
  final int exceptionProductsCount;

  PromotionDetails({
    required this.id,
    required this.name,
    required this.description,
    required this.advantages,
    required this.startDateTime,
    required this.endDateTime,
    required this.inPromoActionLeftovers,
    required this.inPromoActionTotal,
    required this.notInPromoActionLeftovers,
    required this.notInPromoActionTotal,
    required this.participationPercentage,
    required this.type,
    required this.exceptionProductsCount,
  });

  factory PromotionDetails.fromJson(Map<String, dynamic> json) {
    return PromotionDetails(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      advantages: List<String>.from(json['advantages']),
      startDateTime: DateTime.parse(json['startDateTime']),
      endDateTime: DateTime.parse(json['endDateTime']),
      inPromoActionLeftovers: json['inPromoActionLeftovers'] as int,
      inPromoActionTotal: json['inPromoActionTotal'] as int,
      notInPromoActionLeftovers: json['notInPromoActionLeftovers'] as int,
      notInPromoActionTotal: json['notInPromoActionTotal'] as int,
      participationPercentage: json['participationPercentage'] as int,
      type: json['type'] as String,
      exceptionProductsCount: json['exceptionProductsCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'advantages': advantages,
      'startDateTime': startDateTime.toIso8601String(),
      'endDateTime': endDateTime.toIso8601String(),
      'inPromoActionLeftovers': inPromoActionLeftovers,
      'inPromoActionTotal': inPromoActionTotal,
      'notInPromoActionLeftovers': notInPromoActionLeftovers,
      'notInPromoActionTotal': notInPromoActionTotal,
      'participationPercentage': participationPercentage,
      'type': type,
      'exceptionProductsCount': exceptionProductsCount,
    };
  }
}

class PromotionNomenclature {
  final int id;
  final bool inAction;
  final double price;
  final String currencyCode;
  final double planPrice;
  final int discount;
  final int planDiscount;

  PromotionNomenclature({
    required this.id,
    required this.inAction,
    required this.price,
    required this.currencyCode,
    required this.planPrice,
    required this.discount,
    required this.planDiscount,
  });

  factory PromotionNomenclature.fromJson(Map<String, dynamic> json) {
    return PromotionNomenclature(
      id: json['id'] as int,
      inAction: json['inAction'] as bool,
      price: (json['price'] as num).toDouble(),
      currencyCode: json['currencyCode'] as String,
      planPrice: (json['planPrice'] as num).toDouble(),
      discount: json['discount'] as int,
      planDiscount: json['planDiscount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inAction': inAction,
      'price': price,
      'currencyCode': currencyCode,
      'planPrice': planPrice,
      'discount': discount,
      'planDiscount': planDiscount,
    };
  }
}
