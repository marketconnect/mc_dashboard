class OzonPrice {
  final int acquiring;
  final OzonPriceCommissions commissions;
  final OzonPriceMarketingActions marketingActions;
  final String offerId;
  final OzonPriceInfo price;
  final OzonPriceIndexes priceIndexes;
  final int productId;
  final double volumeWeight;

  String get formattedPrice {
    if (price.price == 0) return 'Н/Д';
    return '${price.price.toStringAsFixed(2)} ${price.currencyCode}';
  }

  OzonPrice({
    required this.acquiring,
    required this.commissions,
    required this.marketingActions,
    required this.offerId,
    required this.price,
    required this.priceIndexes,
    required this.productId,
    required this.volumeWeight,
  });

  factory OzonPrice.fromJson(Map<String, dynamic> json) {
    return OzonPrice(
      acquiring: (json['acquiring'] ?? 0).toInt(),
      commissions: OzonPriceCommissions.fromJson(json['commissions'] ?? {}),
      marketingActions:
          OzonPriceMarketingActions.fromJson(json['marketing_actions'] ?? {}),
      offerId: json['offer_id'] ?? '',
      price: OzonPriceInfo.fromJson(json['price'] ?? {}),
      priceIndexes: OzonPriceIndexes.fromJson(json['price_indexes'] ?? {}),
      productId: (json['product_id'] ?? 0).toInt(),
      volumeWeight: (json['volume_weight'] ?? 0.0).toDouble(),
    );
  }
}

class OzonPriceCommissions {
  final double fboDelivToCustomerAmount;
  final double fboDirectFlowTransMaxAmount;
  final double fboDirectFlowTransMinAmount;
  final double fboReturnFlowAmount;
  final double salesPercentFbo;
  //
  final double fbsDelivToCustomerAmount;
  final double fbsDirectFlowTransMaxAmount;
  final double fbsDirectFlowTransMinAmount;
  final double fbsFirstMileMaxAmount;
  final double fbsFirstMileMinAmount;
  final double fbsReturnFlowAmount;
  final double salesPercentFbs;

  OzonPriceCommissions({
    required this.fboDelivToCustomerAmount,
    required this.fboDirectFlowTransMaxAmount,
    required this.fboDirectFlowTransMinAmount,
    required this.fboReturnFlowAmount,
    required this.fbsDelivToCustomerAmount,
    required this.fbsDirectFlowTransMaxAmount,
    required this.fbsDirectFlowTransMinAmount,
    required this.fbsFirstMileMaxAmount,
    required this.fbsFirstMileMinAmount,
    required this.fbsReturnFlowAmount,
    required this.salesPercentFbo,
    required this.salesPercentFbs,
  });

  factory OzonPriceCommissions.fromJson(Map<String, dynamic> json) {
    return OzonPriceCommissions(
      fboDelivToCustomerAmount:
          (json['fbo_deliv_to_customer_amount'] ?? 0.0).toDouble(),
      fboDirectFlowTransMaxAmount:
          (json['fbo_direct_flow_trans_max_amount'] ?? 0.0).toDouble(),
      fboDirectFlowTransMinAmount:
          (json['fbo_direct_flow_trans_min_amount'] ?? 0.0).toDouble(),
      fboReturnFlowAmount: (json['fbo_return_flow_amount'] ?? 0.0).toDouble(),
      fbsDelivToCustomerAmount:
          (json['fbs_deliv_to_customer_amount'] ?? 0.0).toDouble(),
      fbsDirectFlowTransMaxAmount:
          (json['fbs_direct_flow_trans_max_amount'] ?? 0.0).toDouble(),
      fbsDirectFlowTransMinAmount:
          (json['fbs_direct_flow_trans_min_amount'] ?? 0.0).toDouble(),
      fbsFirstMileMaxAmount:
          (json['fbs_first_mile_max_amount'] ?? 0.0).toDouble(),
      fbsFirstMileMinAmount:
          (json['fbs_first_mile_min_amount'] ?? 0.0).toDouble(),
      fbsReturnFlowAmount: (json['fbs_return_flow_amount'] ?? 0.0).toDouble(),
      salesPercentFbo: (json['sales_percent_fbo'] ?? 0.0).toDouble(),
      salesPercentFbs: (json['sales_percent_fbs'] ?? 0.0).toDouble(),
    );
  }
}

class OzonPriceMarketingActions {
  final List<OzonPriceMarketingAction> actions;
  final DateTime? currentPeriodFrom;
  final DateTime? currentPeriodTo;
  final bool ozonActionsExist;

  OzonPriceMarketingActions({
    required this.actions,
    this.currentPeriodFrom,
    this.currentPeriodTo,
    required this.ozonActionsExist,
  });

  factory OzonPriceMarketingActions.fromJson(Map<String, dynamic> json) {
    return OzonPriceMarketingActions(
      actions: (json['actions'] as List<dynamic>?)
              ?.map((e) => OzonPriceMarketingAction.fromJson(e))
              .toList() ??
          [],
      currentPeriodFrom: json['current_period_from'] != null
          ? DateTime.parse(json['current_period_from'])
          : null,
      currentPeriodTo: json['current_period_to'] != null
          ? DateTime.parse(json['current_period_to'])
          : null,
      ozonActionsExist: json['ozon_actions_exist'] ?? false,
    );
  }
}

class OzonPriceMarketingAction {
  final DateTime dateFrom;
  final DateTime dateTo;
  final String title;
  final String value;

  OzonPriceMarketingAction({
    required this.dateFrom,
    required this.dateTo,
    required this.title,
    required this.value,
  });

  factory OzonPriceMarketingAction.fromJson(Map<String, dynamic> json) {
    return OzonPriceMarketingAction(
      dateFrom: DateTime.parse(json['date_from']),
      dateTo: DateTime.parse(json['date_to']),
      title: json['title'] ?? '',
      value: json['value']?.toString() ?? '0',
    );
  }
}

class OzonPriceInfo {
  final bool autoActionEnabled;
  final String currencyCode;
  final double marketingPrice;
  final double marketingSellerPrice;
  final double minPrice;
  final double oldPrice;
  final double price;
  final double retailPrice;
  final double vat;

  OzonPriceInfo({
    required this.autoActionEnabled,
    required this.currencyCode,
    required this.marketingPrice,
    required this.marketingSellerPrice,
    required this.minPrice,
    required this.oldPrice,
    required this.price,
    required this.retailPrice,
    required this.vat,
  });

  factory OzonPriceInfo.fromJson(Map<String, dynamic> json) {
    return OzonPriceInfo(
      autoActionEnabled: json['auto_action_enabled'] ?? false,
      currencyCode: json['currency_code'] ?? 'RUB',
      marketingPrice: (json['marketing_price'] ?? 0.0).toDouble(),
      marketingSellerPrice: (json['marketing_seller_price'] ?? 0.0).toDouble(),
      minPrice: (json['min_price'] ?? 0.0).toDouble(),
      oldPrice: (json['old_price'] ?? 0.0).toDouble(),
      price: (json['price'] ?? 0.0).toDouble(),
      retailPrice: (json['retail_price'] ?? 0.0).toDouble(),
      vat: (json['vat'] ?? 0.0).toDouble(),
    );
  }
}

class OzonPriceIndexes {
  final String colorIndex;
  final OzonPriceIndexData externalIndexData;
  final OzonPriceIndexData ozonIndexData;
  final OzonPriceIndexData selfMarketplacesIndexData;

  OzonPriceIndexes({
    required this.colorIndex,
    required this.externalIndexData,
    required this.ozonIndexData,
    required this.selfMarketplacesIndexData,
  });

  factory OzonPriceIndexes.fromJson(Map<String, dynamic> json) {
    return OzonPriceIndexes(
      colorIndex: json['color_index'] ?? 'WITHOUT_INDEX',
      externalIndexData:
          OzonPriceIndexData.fromJson(json['external_index_data'] ?? {}),
      ozonIndexData: OzonPriceIndexData.fromJson(json['ozon_index_data'] ?? {}),
      selfMarketplacesIndexData: OzonPriceIndexData.fromJson(
          json['self_marketplaces_index_data'] ?? {}),
    );
  }
}

class OzonPriceIndexData {
  final double minPrice;
  final String minPriceCurrency;
  final double priceIndexValue;

  OzonPriceIndexData({
    required this.minPrice,
    required this.minPriceCurrency,
    required this.priceIndexValue,
  });

  factory OzonPriceIndexData.fromJson(Map<String, dynamic> json) {
    return OzonPriceIndexData(
      minPrice: (json['min_price'] ?? 0.0).toDouble(),
      minPriceCurrency: json['min_price_currency'] ?? 'RUB',
      priceIndexValue: (json['price_index_value'] ?? 0.0).toDouble(),
    );
  }
}

class OzonPricesResponse {
  final String? cursor;
  final List<OzonPrice> items;
  final int total;

  OzonPricesResponse({
    this.cursor,
    required this.items,
    required this.total,
  });

  factory OzonPricesResponse.fromJson(Map<String, dynamic> json) {
    return OzonPricesResponse(
      cursor: json['cursor'],
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OzonPrice.fromJson(e))
              .toList() ??
          [],
      total: json['total'] ?? 0,
    );
  }
}
