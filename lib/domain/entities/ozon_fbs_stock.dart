class OzonFbsStock {
  final int present;
  final int reserved;
  final String shipmentType;
  final int sku;
  final String type;

  OzonFbsStock({
    required this.present,
    required this.reserved,
    required this.shipmentType,
    required this.sku,
    required this.type,
  });

  factory OzonFbsStock.fromJson(Map<String, dynamic> json) {
    return OzonFbsStock(
      present: json['present'] ?? 0,
      reserved: json['reserved'] ?? 0,
      shipmentType: json['shipment_type'] ?? '',
      sku: json['sku'] ?? 0,
      type: json['type'] ?? '',
    );
  }
}

class OzonFbsStockItem {
  final String offerId;
  final int productId;
  final List<OzonFbsStock> stocks;

  OzonFbsStockItem({
    required this.offerId,
    required this.productId,
    required this.stocks,
  });

  factory OzonFbsStockItem.fromJson(Map<String, dynamic> json) {
    return OzonFbsStockItem(
      offerId: json['offer_id'] ?? '',
      productId: json['product_id'] ?? 0,
      stocks: (json['stocks'] as List<dynamic>?)
              ?.map((e) => OzonFbsStock.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class OzonFbsStocksResponse {
  final String? cursor;
  final List<OzonFbsStockItem> items;
  final int total;

  OzonFbsStocksResponse({
    this.cursor,
    required this.items,
    required this.total,
  });

  factory OzonFbsStocksResponse.fromJson(Map<String, dynamic> json) {
    return OzonFbsStocksResponse(
      cursor: json['cursor'],
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OzonFbsStockItem.fromJson(e))
              .toList() ??
          [],
      total: json['total'] ?? 0,
    );
  }
}
