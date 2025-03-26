class WbStock {
  final String lastChangeDate;
  final String warehouseName;
  final String supplierArticle;
  final int nmId;
  final String barcode;
  final int quantity;
  final int inWayToClient;
  final int inWayFromClient;
  final int quantityFull;
  final String category;
  final String subject;
  final String brand;
  final String techSize;
  final double price;
  final int discount;
  final bool isSupply;
  final bool isRealization;
  final String scCode;

  WbStock({
    required this.lastChangeDate,
    required this.warehouseName,
    required this.supplierArticle,
    required this.nmId,
    required this.barcode,
    required this.quantity,
    required this.inWayToClient,
    required this.inWayFromClient,
    required this.quantityFull,
    required this.category,
    required this.subject,
    required this.brand,
    required this.techSize,
    required this.price,
    required this.discount,
    required this.isSupply,
    required this.isRealization,
    required this.scCode,
  });

  factory WbStock.fromJson(Map<String, dynamic> json) {
    return WbStock(
      lastChangeDate: json['lastChangeDate'] ?? '',
      warehouseName: json['warehouseName'] ?? '',
      supplierArticle: json['supplierArticle'] ?? '',
      nmId: json['nmId'] ?? 0,
      barcode: json['barcode'] ?? '',
      quantity: json['quantity'] ?? 0,
      inWayToClient: json['inWayToClient'] ?? 0,
      inWayFromClient: json['inWayFromClient'] ?? 0,
      quantityFull: json['quantityFull'] ?? 0,
      category: json['category'] ?? '',
      subject: json['subject'] ?? '',
      brand: json['brand'] ?? '',
      techSize: json['techSize'] ?? '',
      price: (json['Price'] ?? 0).toDouble(),
      discount: json['Discount'] ?? 0,
      isSupply: json['isSupply'] ?? false,
      isRealization: json['isRealization'] ?? false,
      scCode: json['SCCode'] ?? '',
    );
  }
}
