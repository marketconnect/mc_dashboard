import 'package:mc_dashboard/domain/entities/product_cost_data.dart';
import 'package:mc_dashboard/presentation/ozon_product_card_screen/ozon_product_card_view_model.dart';
import 'package:mc_dashboard/presentation/ozon_product_cards_screen/ozon_product_cards_view_model.dart';
import 'package:mc_dashboard/presentation/product_card_screen/product_card_view_model.dart';
import 'package:mc_dashboard/presentation/product_cards_screen/product_cards_view_model.dart';
import 'package:mc_dashboard/presentation/product_cost_import_screen/product_cost_import_view_model.dart';

abstract class ProductCostServiceRepository {
  Future<void> saveCostData(ProductCostData costData);
  Future<ProductCostData?> getCostData(int nmID, String mpType);
  Future<void> deleteCostData(int nmID, String mpType);
  Future<List<ProductCostData>> getAllCostData();
}

class ProductCostService
    implements
        ProductCardsWbProductCostService,
        OzonProductCardsProductCardsProductCostService,
        OzonProductCardProductCostService,
        ProductCardWbProductCostService,
        ProductCostImportProductCostService {
  final ProductCostServiceRepository storage;

  ProductCostService({required this.storage});

  @override
  Future<void> saveProductCost(ProductCostData costData) async {
    await storage.saveCostData(costData);
  }

  @override
  Future<ProductCostData?> getWbProductCost(int nmID) async {
    return await storage.getCostData(nmID, "wb");
  }

  @override
  Future<ProductCostData?> getOzonProductCost(int nmID) async {
    return await storage.getCostData(nmID, "ozon");
  }

  Future<void> deleteProductCost(int nmID, String mpType) async {
    await storage.deleteCostData(nmID, mpType);
  }

  @override
  Future<List<ProductCostData>> getAllCostWbData() async {
    final allCostdata = await storage.getAllCostData();
    return allCostdata.where((d) => d.mpType == "wb").toList();
  }

  @override
  Future<List<ProductCostData>> getAllCostOzonData() async {
    final allCostdata = await storage.getAllCostData();
    return allCostdata.where((d) => d.mpType == "ozon").toList();
  }
}
