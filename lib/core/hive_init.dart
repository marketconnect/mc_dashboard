import 'package:hive_flutter/adapters.dart';
import 'package:mc_dashboard/domain/entities/product_cost_data.dart';
import 'package:mc_dashboard/domain/entities/product_cost_data_details.dart';

class HiveInit {
  static Future<void> init() async {
    await Hive.initFlutter();
    // Регистрируем адаптеры для типов данных
    Hive.registerAdapter(ProductCostDataAdapter());
    Hive.registerAdapter(ProductCostDataDetailsAdapter());
  }
}
