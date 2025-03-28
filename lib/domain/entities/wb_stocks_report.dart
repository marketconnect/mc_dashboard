class WbStocksReport {
  final List<WbStocksGroup> groups;

  WbStocksReport({required this.groups});

  factory WbStocksReport.fromJson(Map<String, dynamic> json) {
    final groupsJson = json['groups'] as List<dynamic>;
    return WbStocksReport(
      groups: groupsJson.map((group) => WbStocksGroup.fromJson(group)).toList(),
    );
  }
}

class WbStocksGroup {
  final int subjectID;
  final String subjectName;
  final String brandName;
  final int tagID;
  final String tagName;
  final WbStocksMetrics metrics;
  final List<WbStocksItem> items;

  WbStocksGroup({
    required this.subjectID,
    required this.subjectName,
    required this.brandName,
    required this.tagID,
    required this.tagName,
    required this.metrics,
    required this.items,
  });

  factory WbStocksGroup.fromJson(Map<String, dynamic> json) {
    return WbStocksGroup(
      subjectID: json['subjectID'] as int,
      subjectName: json['subjectName'] as String,
      brandName: json['brandName'] as String,
      tagID: json['tagID'] as int,
      tagName: json['tagName'] as String,
      metrics:
          WbStocksMetrics.fromJson(json['metrics'] as Map<String, dynamic>),
      items: (json['items'] as List<dynamic>)
          .map((item) => WbStocksItem.fromJson(item))
          .toList(),
    );
  }
}

class WbStocksMetrics {
  final double ordersCount;
  final double ordersSum;
  final double avgOrders;
  final List<WbStocksMonthlyValue> avgOrdersByMonth;
  final double buyoutCount;
  final double buyoutSum;
  final double buyoutPercent;
  final double stockCount;
  final double stockSum;
  final WbStocksTimeValue saleRate;
  final WbStocksTimeValue avgStockTurnover;
  final double toClientCount;
  final double fromClientCount;
  final WbStocksTimeValue officeMissingTime;
  final double lostOrdersCount;
  final double lostOrdersSum;
  final double lostBuyoutsCount;
  final double lostBuyoutsSum;

  WbStocksMetrics({
    required this.ordersCount,
    required this.ordersSum,
    required this.avgOrders,
    required this.avgOrdersByMonth,
    required this.buyoutCount,
    required this.buyoutSum,
    required this.buyoutPercent,
    required this.stockCount,
    required this.stockSum,
    required this.saleRate,
    required this.avgStockTurnover,
    required this.toClientCount,
    required this.fromClientCount,
    required this.officeMissingTime,
    required this.lostOrdersCount,
    required this.lostOrdersSum,
    required this.lostBuyoutsCount,
    required this.lostBuyoutsSum,
  });

  factory WbStocksMetrics.fromJson(Map<String, dynamic> json) {
    return WbStocksMetrics(
      ordersCount: (json['ordersCount'] as num).toDouble(),
      ordersSum: (json['ordersSum'] as num).toDouble(),
      avgOrders: (json['avgOrders'] as num).toDouble(),
      avgOrdersByMonth: (json['avgOrdersByMonth'] as List<dynamic>)
          .map((month) => WbStocksMonthlyValue.fromJson(month))
          .toList(),
      buyoutCount: (json['buyoutCount'] as num).toDouble(),
      buyoutSum: (json['buyoutSum'] as num).toDouble(),
      buyoutPercent: (json['buyoutPercent'] as num).toDouble(),
      stockCount: (json['stockCount'] as num).toDouble(),
      stockSum: (json['stockSum'] as num).toDouble(),
      saleRate: WbStocksTimeValue.fromJson(json['saleRate']),
      avgStockTurnover: WbStocksTimeValue.fromJson(json['avgStockTurnover']),
      toClientCount: (json['toClientCount'] as num).toDouble(),
      fromClientCount: (json['fromClientCount'] as num).toDouble(),
      officeMissingTime: WbStocksTimeValue.fromJson(json['officeMissingTime']),
      lostOrdersCount: (json['lostOrdersCount'] as num).toDouble(),
      lostOrdersSum: (json['lostOrdersSum'] as num).toDouble(),
      lostBuyoutsCount: (json['lostBuyoutsCount'] as num).toDouble(),
      lostBuyoutsSum: (json['lostBuyoutsSum'] as num).toDouble(),
    );
  }
}

class WbStocksMonthlyValue {
  final DateTime start;
  final DateTime end;
  final double value;

  WbStocksMonthlyValue({
    required this.start,
    required this.end,
    required this.value,
  });

  factory WbStocksMonthlyValue.fromJson(Map<String, dynamic> json) {
    return WbStocksMonthlyValue(
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      value: (json['value'] as num).toDouble(),
    );
  }
}

class WbStocksTimeValue {
  final int days;
  final int hours;

  WbStocksTimeValue({
    required this.days,
    required this.hours,
  });

  factory WbStocksTimeValue.fromJson(Map<String, dynamic> json) {
    return WbStocksTimeValue(
      days: json['days'] as int,
      hours: json['hours'] as int,
    );
  }
}

class WbStocksItem {
  final int nmID;
  final bool isDeleted;
  final String subjectName;
  final String name;
  final String vendorCode;
  final String brandName;
  final String mainPhoto;
  final bool hasSizes;
  final WbStocksMetrics metrics;
  final WbStocksPriceRange? currentPrice;
  final String availability;

  WbStocksItem({
    required this.nmID,
    required this.isDeleted,
    required this.subjectName,
    required this.name,
    required this.vendorCode,
    required this.brandName,
    required this.mainPhoto,
    required this.hasSizes,
    required this.metrics,
    this.currentPrice,
    required this.availability,
  });

  factory WbStocksItem.fromJson(Map<String, dynamic> json) {
    return WbStocksItem(
      nmID: json['nmID'] as int,
      isDeleted: json['isDeleted'] as bool,
      subjectName: json['subjectName']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      vendorCode: json['vendorCode']?.toString() ?? '',
      brandName: json['brandName']?.toString() ?? '',
      mainPhoto: json['mainPhoto']?.toString() ?? '',
      hasSizes: json['hasSizes'] as bool,
      metrics:
          WbStocksMetrics.fromJson(json['metrics'] as Map<String, dynamic>),
      currentPrice: json['currentPrice'] != null
          ? WbStocksPriceRange.fromJson(json['currentPrice'])
          : null,
      availability: json['availability']?.toString() ?? 'balanced',
    );
  }
}

class WbStocksPriceRange {
  final double minPrice;
  final double maxPrice;

  WbStocksPriceRange({
    required this.minPrice,
    required this.maxPrice,
  });

  factory WbStocksPriceRange.fromJson(Map<String, dynamic> json) {
    return WbStocksPriceRange(
      minPrice: (json['minPrice'] as num).toDouble(),
      maxPrice: (json['maxPrice'] as num).toDouble(),
    );
  }
}
