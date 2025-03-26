import 'package:flutter/material.dart';
import 'package:mc_dashboard/presentation/product_cost_import_screen/product_cost_import_view_model.dart';
import 'package:provider/provider.dart';

class ProductCostImportScreen extends StatelessWidget {
  const ProductCostImportScreen({super.key});

  void _showBottomSheet(BuildContext context, String mpType) {
    final viewModel = context.read<ProductCostImportViewModel>();
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Данные ${mpType == 'wb' ? 'Wildberries' : 'Ozon'} успешно загружены',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Хотите применить эти данные к ${mpType == 'wb' ? 'Ozon' : 'Wildberries'}, если артикулы продавца совпадают?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (mpType == 'wb') {
                      viewModel.repeatForOzonProducts();
                    } else {
                      viewModel.repeatForWbProducts();
                    }
                  },
                  child: const Text('Да, применить'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                  ),
                  child: const Text('Нет, отмена'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProductCostImportViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Импорт")),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const UploadInstructions(),
            const SizedBox(height: 20),
            if (!viewModel.allDataLoaded) ...[
              // WB Section
              if (!viewModel.wbDataLoaded)
                SizedBox(
                  width: 300,
                  height: 200,
                  child: Card(
                    elevation: 4,
                    color: const Color.fromARGB(255, 206, 171, 251),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Данные WB",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await viewModel.importData('wb');
                              if (context.mounted &&
                                  viewModel.errorMessage == null &&
                                  !viewModel.allDataLoaded) {
                                _showBottomSheet(context, 'wb');
                              }
                            },
                            icon: const Icon(Icons.upload_file),
                            label: const Text("Загрузить данные WB"),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: () =>
                                viewModel.exportCostDataToExcelWeb("wb"),
                            icon: const Icon(Icons.download),
                            label: const Text("Выгрузить данные WB"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (!viewModel.wbDataLoaded && !viewModel.ozonDataLoaded)
                const SizedBox(height: 20),
              // Ozon Section
              if (!viewModel.ozonDataLoaded)
                SizedBox(
                  width: 300,
                  height: 200,
                  child: Card(
                    elevation: 4,
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Данные OZON",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await viewModel.importData('ozon');
                              if (context.mounted &&
                                  viewModel.errorMessage == null &&
                                  !viewModel.allDataLoaded) {
                                _showBottomSheet(context, 'ozon');
                              }
                            },
                            icon: const Icon(Icons.upload_file),
                            label: const Text("Загрузить данные OZON"),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: () =>
                                viewModel.exportCostDataToExcelWeb("ozon"),
                            icon: const Icon(Icons.download),
                            label: const Text("Выгрузить данные OZON"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
            if (viewModel.isLoading)
              const Center(child: CircularProgressIndicator()),
            if (viewModel.errorMessage != null)
              Text(
                viewModel.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            if (viewModel.updatedCount > 0)
              Text(
                "Обновлено записей: ${viewModel.updatedCount}",
                style: const TextStyle(color: Colors.green),
              ),
            if (viewModel.allDataLoaded)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Все данные успешно загружены",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class UploadInstructions extends StatelessWidget {
  const UploadInstructions({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withAlpha(51),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Загрузите Excel-файл со следующими данными:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text("✅ 1️⃣ Первая колонка – Артикул WB / Ozon Product ID"),
          const Text("✅ 2️⃣ Вторая – Себестоимость единицы товара"),
          const Text("✅ 3️⃣ Третья – Расходы на упаковку (опционально)"),
          const Text("✅ 4️⃣ Четвёртая – Расходы на доставку (опционально)"),
          const Text("✅ 5️⃣ Пятая – Платная приёмка (опционально)"),
          const Text("✅ 6️⃣ Артикул продавца (опционально)"),
        ],
      ),
    );
  }
}
