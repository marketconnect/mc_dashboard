class Good {
  final int nmID;
  final String vendorCode;
  final String currencyIsoCode;
  final double discount;
  final double clubDiscount;
  final bool editableSizePrice;
  final List<GoodSize> sizes;

  Good({
    required this.nmID,
    required this.vendorCode,
    required this.currencyIsoCode,
    required this.discount,
    required this.clubDiscount,
    required this.editableSizePrice,
    required this.sizes,
  });

  factory Good.fromJson(Map<String, dynamic> json) {
    return Good(
      nmID: json['nmID'] as int,
      vendorCode: json['vendorCode'] as String,
      currencyIsoCode: json['currencyIsoCode4217'] as String,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      clubDiscount: (json['clubDiscount'] as num?)?.toDouble() ?? 0.0,
      editableSizePrice: json['editableSizePrice'] as bool? ?? false,
      sizes: (json['sizes'] as List<dynamic>?)
              ?.map((sizeJson) => GoodSize.fromJson(sizeJson))
              .toList() ??
          [],
    );
  }
}

class GoodSize {
  final int sizeID;
  final String techSizeName;
  final double price;
  final double discountedPrice;
  final double clubDiscountedPrice;

  GoodSize({
    required this.sizeID,
    required this.techSizeName,
    required this.price,
    required this.discountedPrice,
    required this.clubDiscountedPrice,
  });

  factory GoodSize.fromJson(Map<String, dynamic> json) {
    return GoodSize(
      sizeID: json['sizeID'] as int,
      techSizeName: json['techSizeName'] as String,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountedPrice: (json['discountedPrice'] as num?)?.toDouble() ?? 0.0,
      clubDiscountedPrice:
          (json['clubDiscountedPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
