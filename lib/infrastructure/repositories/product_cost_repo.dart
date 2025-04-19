import 'package:hive/hive.dart';
import 'package:mc_dashboard/core/constants/hive_boxes.dart';
import 'package:mc_dashboard/domain/entities/product_cost_data.dart';
import 'package:mc_dashboard/domain/entities/product_cost_data_details.dart';
import 'package:mc_dashboard/domain/services/product_cost_service.dart';

class ProductCostRepository implements ProductCostServiceRepository {
  const ProductCostRepository();
  Future<Box<ProductCostData>> _openBox() async {
    return await Hive.openBox<ProductCostData>(HiveBoxesNames.productCosts);
  }

  Future<Box<ProductCostDataDetails>> _openDetailsBox() async {
    return await Hive.openBox<ProductCostDataDetails>(
        HiveBoxesNames.productCostDetails);
  }

  String _composeKey(ProductCostData data) => '${data.nmID}_${data.mpType}';

  String _composeDetailKey(ProductCostDataDetails detail) =>
      '${detail.nmID}_${detail.mpType}_${detail.costType}_${detail.name}';

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

  @override
  Future<List<ProductCostDataDetails>> getDetailsForProduct(
      int nmID, String mpType) async {
    try {
      final box = await _openDetailsBox();
      return box.values
          .where((detail) => detail.nmID == nmID && detail.mpType == mpType)
          .toList();
    } catch (e) {
      throw Exception('Ошибка получения деталей расходов: $e');
    }
  }

  @override
  Future<void> saveProductCostDetail(ProductCostDataDetails detail) async {
    try {
      final box = await _openDetailsBox();
      final key = _composeDetailKey(detail);
      await box.put(key, detail);
    } catch (e) {
      throw Exception('Ошибка сохранения детали расхода: $e');
    }
  }

  @override
  Future<void> deleteProductCostDetail(ProductCostDataDetails detail) async {
    try {
      final box = await _openDetailsBox();
      final key = _composeDetailKey(detail);
      await box.delete(key);
    } catch (e) {
      throw Exception('Ошибка удаления детали расхода: $e');
    }
  }
}
