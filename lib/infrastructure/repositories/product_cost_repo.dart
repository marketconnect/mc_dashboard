import 'package:hive/hive.dart';
import 'package:mc_dashboard/core/constants/hive_boxes.dart';
import 'package:mc_dashboard/domain/entities/product_cost_data.dart';
import 'package:mc_dashboard/domain/services/product_cost_service.dart';

class ProductCostRepository implements ProductCostServiceRepository {
  const ProductCostRepository();
  Future<Box<ProductCostData>> _openBox() async {
    return await Hive.openBox<ProductCostData>(HiveBoxesNames.productCosts);
  }

  String _composeKey(ProductCostData data) => '${data.nmID}_${data.mpType}';

  @override
  Future<void> saveCostData(ProductCostData costData) async {
    try {
      final box = await _openBox();
      final key = _composeKey(costData);
      await box.put(key, costData);
    } catch (e) {
      throw Exception('Ошибка сохранения данных: $e');
    }
  }

  @override
  Future<ProductCostData?> getCostData(int nmID, String mpType) async {
    try {
      final box = await _openBox();
      return box.get('${nmID}_$mpType');
    } catch (e) {
      throw Exception('Ошибка получения данных: $e');
    }
  }

  @override
  Future<void> deleteCostData(int nmID, String mpType) async {
    try {
      final box = await _openBox();
      await box.delete('${nmID}_$mpType');
    } catch (e) {
      throw Exception('Ошибка удаления данных: $e');
    }
  }

  @override
  Future<List<ProductCostData>> getAllCostData() async {
    try {
      final box = await _openBox();
      return box.values.toList();
    } catch (e) {
      throw Exception('Ошибка получения данных: $e');
    }
  }
}
