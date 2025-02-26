import 'package:http/http.dart' as http;
import 'package:mc_dashboard/domain/entities/card_info.dart';
import 'package:mc_dashboard/domain/services/card_info_service.dart';
import 'dart:convert';

class CardInfoApiClient implements CardInfoServiceApiClient {
  const CardInfoApiClient();

  @override
  Future<CardInfo> fetchCardInfo(String cardUrl) async {
    try {
      final response = await http.get(Uri.parse(cardUrl));

      if (response.statusCode == 200) {
        return CardInfo.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception('Failed to load card info');
      }
    } catch (e) {
      return CardInfo(
          imtName: "",
          imtId: 0,
          photoCount: 0,
          subjId: 0,
          subjName: "",
          description: "",
          characteristicFull: "",
          brand: "",
          supplierId: 0,
          characteristicValues: "",
          packageLength: "",
          packageHeight: "",
          packageWidth: "");
    }
  }
}
