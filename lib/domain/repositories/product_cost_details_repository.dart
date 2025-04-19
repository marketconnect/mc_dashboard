import 'package:mc_dashboard/domain/entities/product_cost_data_details.dart';

abstract class ProductCostDetailsRepository {
  Future<void> saveDetail(ProductCostDataDetails detail);
  Future<List<ProductCostDataDetails>> getDetailsByCostType(
      int nmID, String costType, String mpType);
  Future<List<ProductCostDataDetails>> getAllDetailsByNmID(
      int nmID, String mpType);
  Future<void> deleteDetail(String detailKey);
  Future<List<ProductCostDataDetails>> getAllDetails();
}
