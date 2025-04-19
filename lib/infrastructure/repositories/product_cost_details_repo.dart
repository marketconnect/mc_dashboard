import 'package:hive/hive.dart';
import 'package:mc_dashboard/core/constants/hive_boxes.dart';
import 'package:mc_dashboard/domain/entities/product_cost_data_details.dart';
import 'package:mc_dashboard/domain/repositories/product_cost_details_repository.dart';

class ProductCostDetailsRepo implements ProductCostDetailsRepository {
  const ProductCostDetailsRepo();

  Future<Box<ProductCostDataDetails>> _openBox() async {
    return await Hive.openBox<ProductCostDataDetails>(
        HiveBoxesNames.productCostDetails);
  }

  String _composeKey(ProductCostDataDetails data) =>
      '${data.nmID}_${data.costType}_${data.name}_${data.mpType}';

  @override
  Future<void> saveDetail(ProductCostDataDetails detail) async {
    try {
      final box = await _openBox();
      final key = _composeKey(detail);
      await box.put(key, detail);
    } catch (e) {
      throw Exception('Ошибка сохранения данных: $e');
    }
  }

  @override
  Future<List<ProductCostDataDetails>> getDetailsByCostType(
      int nmID, String costType, String mpType) async {
    try {
      final box = await _openBox();
      return box.values
          .where((detail) =>
              detail.nmID == nmID &&
              detail.costType == costType &&
              detail.mpType == mpType)
          .toList();
    } catch (e) {
      throw Exception('Ошибка получения данных: $e');
    }
  }

  @override
  Future<List<ProductCostDataDetails>> getAllDetailsByNmID(
      int nmID, String mpType) async {
    try {
      final box = await _openBox();
      return box.values
          .where((detail) => detail.nmID == nmID && detail.mpType == mpType)
          .toList();
    } catch (e) {
      throw Exception('Ошибка получения данных: $e');
    }
  }

  @override
  Future<void> deleteDetail(String detailKey) async {
    try {
      final box = await _openBox();
      await box.delete(detailKey);
    } catch (e) {
      throw Exception('Ошибка удаления данных: $e');
    }
  }

  @override
  Future<List<ProductCostDataDetails>> getAllDetails() async {
    try {
      final box = await _openBox();
      return box.values.toList();
    } catch (e) {
      throw Exception('Ошибка получения данных: $e');
    }
  }
}
