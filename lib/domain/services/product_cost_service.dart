import 'package:mc_dashboard/domain/entities/product_cost_data.dart';
import 'package:mc_dashboard/presentation/product_card_screen/product_card_view_model.dart';
import 'package:mc_dashboard/presentation/product_cards_screen/product_cards_view_model.dart';
import 'package:mc_dashboard/presentation/product_cost_import_screen/product_cost_import_view_model.dart';

abstract class ProductCostServiceRepository {
  Future<void> saveCostData(ProductCostData costData);
  Future<ProductCostData?> getCostData(int nmID);
  Future<void> deleteCostData(int nmID);
  Future<List<ProductCostData>> getAllCostData();
}

class ProductCostService
    implements
        ProductCardsWbProductCostService,
        ProductCardWbProductCostService,
        ProductCostImportProductCostService {
  final ProductCostServiceRepository storage;

  ProductCostService({required this.storage});

  @override
  Future<void> saveProductCost(ProductCostData costData) async {
    await storage.saveCostData(costData);
  }

  @override
  Future<ProductCostData?> getProductCost(int nmID) async {
    return await storage.getCostData(nmID);
  }

  Future<void> deleteProductCost(int nmID) async {
    await storage.deleteCostData(nmID);
  }

  @override
  Future<List<ProductCostData>> getAllCostData() async {
    return await storage.getAllCostData();
  }
}
