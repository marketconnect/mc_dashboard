import 'dart:typed_data';

import 'package:mc_dashboard/domain/entities/charc.dart';
import 'package:mc_dashboard/domain/entities/product_card.dart';
import 'package:mc_dashboard/presentation/product_card_screen/product_card_view_model.dart';
import 'package:mc_dashboard/presentation/product_cards_screen/product_cards_view_model.dart';
import 'package:mc_dashboard/presentation/product_cost_import_screen/product_cost_import_view_model.dart';
import 'package:mc_dashboard/presentation/product_detail_screen/product_detail_view_model.dart';

abstract class WbContentApiServiceWbTokenRepo {
  Future<String?> getWbToken();
}

abstract class WbContentApiServiceApiClient {
  Future<List<Charc>> fetchCharcs(
      {required String token, required int subjectId});
  Future<Map<String, dynamic>> uploadProductCards({
    required String token,
    required List<Map<String, dynamic>> productData,
  });
  Future<Map<String, dynamic>> uploadMediaFile({
    required String token,
    required String nmId,
    required int photoNumber,
    required Uint8List mediaFile,
  });
  Future<List<ProductCard>> fetchProductCards({
    required String token,
    required int nmID,
    int limit = 100,
  });

  Future<List<ProductCard>> fetchAllProductCards({required String token});
}

class WbApiContentService
    implements
        ProductDetailWbContentApi,
        ProductCardsWbContentApi,
        ProductCostImportProductCardsService,
        ProductCardWbContentApiService {
  final WbContentApiServiceApiClient apiClient;
  final WbContentApiServiceWbTokenRepo wbTokenRepo;

  WbApiContentService({required this.apiClient, required this.wbTokenRepo});

  @override
  Future<List<Charc>> fetchCharcs(int subjectId) async {
    final token = await wbTokenRepo.getWbToken();
    if (token == null) {
      throw Exception("Для получения данных нужно добавить токен Wildberries");
    }
    return await apiClient.fetchCharcs(
      token: token,
      subjectId: subjectId,
    );
  }

  @override
  Future<Map<String, dynamic>> uploadProductCards(
      List<Map<String, dynamic>> productData) async {
    final token = await wbTokenRepo.getWbToken();
    if (token == null) {
      throw Exception("Для получения данных нужно добавить токен Wildberries");
    }
    return await apiClient.uploadProductCards(
      token: token,
      productData: productData,
    );
  }

  @override
  Future<Map<String, dynamic>> uploadMediaFile({
    required String nmId,
    required int photoNumber,
    required Uint8List mediaFile,
  }) async {
    final token = await wbTokenRepo.getWbToken();
    if (token == null) {
      throw Exception("Для получения данных нужно добавить токен Wildberries");
    }
    return await apiClient.uploadMediaFile(
      token: token,
      nmId: nmId,
      photoNumber: photoNumber,
      mediaFile: mediaFile,
    );
  }

  @override
  Future<ProductCard> fetchProductCard({
    required int imtID,
    required int nmID,
  }) async {
    final token = await wbTokenRepo.getWbToken();
    if (token == null) {
      throw Exception("Для получения данных нужно добавить токен Wildberries");
    }
    final cards = await apiClient.fetchProductCards(
      token: token,
      nmID: imtID,
    );
    return cards.where((card) => card.nmID == nmID).first;
  }

  @override
  Future<List<ProductCard>> fetchAllProductCards() async {
    final token = await wbTokenRepo.getWbToken();

    if (token == null) {
      throw Exception("Для получения данных нужно добавить токен Wildberries");
    }
    return await apiClient.fetchAllProductCards(token: token);
  }
}
