import 'package:dio/dio.dart';

import 'package:mc_dashboard/domain/entities/card_info.dart';
import 'package:mc_dashboard/domain/entities/feedback_info.dart';

String? getBasketNum(int productId) {
  if (productId >= 2088 && productId <= 14399999) {
    return '01';
  } else if (productId >= 14400000 && productId <= 28799999) {
    return '02';
  } else if (productId >= 28800000 && productId <= 43199999) {
    return '03';
  } else if (productId >= 43200000 && productId <= 71999999) {
    return '04';
  } else if (productId >= 72000000 && productId <= 100799999) {
    return '05';
  } else if (productId >= 100800000 && productId <= 106199999) {
    return '06';
  } else if (productId >= 106200000 && productId <= 111599999) {
    return '07';
  } else if (productId >= 111600000 && productId <= 116999999) {
    return '08';
  } else if (productId >= 117000000 && productId <= 131399999) {
    return '09';
  } else if (productId >= 131400000 && productId <= 160199999) {
    return '10';
  } else if (productId >= 160200000 && productId <= 165599999) {
    return '11';
  } else if (productId >= 165600000 && productId <= 191999999) {
    return '12';
  } else if (productId >= 192000000 && productId <= 204599999) {
    return '13';
  } else if (productId >= 204600000 && productId <= 218999999) {
    return '14';
  } else if (productId >= 219000000 && productId <= 240599999) {
    return '15';
  } else if (productId >= 240600000 && productId <= 262199999) {
    return '16';
  } else if (productId >= 262200000 && productId <= 283799999) {
    return '17';
  } else {
    return null;
  }
}

String calculateImageUrl(String? basket, int productId) {
  if (basket == null) {
    return "";
  }
  String vol = "vol${productId ~/ 100000}";
  String part = "part${productId ~/ 1000}";
  return "https://basket-${basket.padLeft(2, '0')}.wbbasket.ru/$vol/$part/$productId/images/c246x328/1.webp";
}

String calculateCardUrl(String? imageUrl) {
  if (imageUrl == null) {
    return "";
  }
  return imageUrl.replaceFirst("/images/c246x328/1.webp", "/info/ru/card.json");
}

Future<CardInfo> fetchCardInfo(String cardUrl) async {
  try {
    final response = await Dio().get(cardUrl);
    return CardInfo.fromJson(response.data);
  } catch (e) {
    return CardInfo(imtName: "", imtId: 0, photoCount: 0, subjName: "");
  }
}

Future<FeedbackInfo> fetchFeedbacks(int imtId) async {
  final url = 'https://feedbacks2.wb.ru/feedbacks/v2/$imtId';

  try {
    final response = await Dio().get(url);
    if (response.data['valuationDistributionPercent'] == null) {
      final url = 'https://feedbacks1.wb.ru/feedbacks/v2/$imtId';
      final response = await Dio().get(url);
      return FeedbackInfo.fromJson(response.data);
    }
    return FeedbackInfo.fromJson(response.data);
  } catch (e) {
    return FeedbackInfo(
      valuationDistributionPercent: {
        '1': 0,
        '2': 0,
        '3': 0,
        '4': 0,
        '5': 0,
      },
      valuation: '0',
      pros: [],
      cons: [],
    );
  }
}
