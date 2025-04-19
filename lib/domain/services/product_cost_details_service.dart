import 'package:mc_dashboard/domain/entities/product_cost_data_details.dart';
import 'package:mc_dashboard/presentation/product_card_screen/product_card_view_model.dart';

abstract class ProductCostDetailsService
    implements ProductCardCostDetailsService {
  Future<void> saveDetail(ProductCostDataDetails detail);
  Future<List<ProductCostDataDetails>> getDetailsByCostType(
      int nmID, String costType, String mpType);
  Future<List<ProductCostDataDetails>> getAllDetailsByNmID(
      int nmID, String mpType);
  Future<void> deleteDetail(ProductCostDataDetails detail);
  Future<List<ProductCostDataDetails>> getAllDetails();
}
