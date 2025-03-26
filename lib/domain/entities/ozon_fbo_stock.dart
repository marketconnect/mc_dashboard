class OzonFboStock {
  final int defectStockCount;
  final int expiringStockCount;
  final String name;
  final String offerId;
  final int sku;
  final int validStockCount;
  final int waitingDocsStockCount;
  final String warehouseName;

  OzonFboStock({
    required this.defectStockCount,
    required this.expiringStockCount,
    required this.name,
    required this.offerId,
    required this.sku,
    required this.validStockCount,
    required this.waitingDocsStockCount,
    required this.warehouseName,
  });

  factory OzonFboStock.fromJson(Map<String, dynamic> json) {
    return OzonFboStock(
      defectStockCount: json['defect_stock_count'] ?? 0,
      expiringStockCount: json['expiring_stock_count'] ?? 0,
      name: json['name'] ?? '',
      offerId: json['offer_id'] ?? '',
      sku: json['sku'] ?? 0,
      validStockCount: json['valid_stock_count'] ?? 0,
      waitingDocsStockCount: json['waitingdocs_stock_count'] ?? 0,
      warehouseName: json['warehouse_name'] ?? '',
    );
  }
}

class OzonFboStocksResponse {
  final List<OzonFboStock> items;

  OzonFboStocksResponse({
    required this.items,
  });

  factory OzonFboStocksResponse.fromJson(Map<String, dynamic> json) {
    return OzonFboStocksResponse(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OzonFboStock.fromJson(e))
              .toList() ??
          [],
    );
  }
}
