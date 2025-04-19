import 'package:mc_dashboard/domain/entities/product_cost_data_details.dart';
import 'package:mc_dashboard/domain/repositories/product_cost_details_repository.dart';
import 'package:mc_dashboard/domain/services/product_cost_details_service.dart';

class ProductCostDetailsServiceImpl implements ProductCostDetailsService {
  final ProductCostDetailsRepository repository;

  ProductCostDetailsServiceImpl(this.repository);

  @override
  Future<void> saveDetail(ProductCostDataDetails detail) async {
    await repository.saveDetail(detail);
  }

  @override
  Future<List<ProductCostDataDetails>> getDetailsByCostType(
      int nmID, String costType, String mpType) async {
    return await repository.getDetailsByCostType(nmID, costType, mpType);
  }

  @override
  Future<List<ProductCostDataDetails>> getAllDetailsByNmID(
      int nmID, String mpType) async {
    return await repository.getAllDetailsByNmID(nmID, mpType);
  }

  @override
  Future<void> deleteDetail(ProductCostDataDetails detail) async {
    final key =
        '${detail.nmID}_${detail.costType}_${detail.name}_${detail.mpType}';
    await repository.deleteDetail(key);
  }

  @override
  Future<List<ProductCostDataDetails>> getAllDetails() async {
    return await repository.getAllDetails();
  }
}
