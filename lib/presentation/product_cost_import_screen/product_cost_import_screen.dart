import 'package:flutter/material.dart';
import 'package:mc_dashboard/presentation/product_cost_import_screen/product_cost_import_view_model.dart';
import 'package:provider/provider.dart';

class ProductCostImportScreen extends StatelessWidget {
  const ProductCostImportScreen({super.key});

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
            ElevatedButton(
              onPressed: viewModel.exportCostDataToExcelWeb,
              child: const Text("Выгрузить данные"),
            ),
            const SizedBox(height: 20),
            if (viewModel.selectedFilePath == null)
              ElevatedButton(
                onPressed: viewModel.importData,
                child: const Text("Загрузить данные"),
              ),
            const SizedBox(height: 20),
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
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
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
          const Text("✅ 1️⃣ Первая колонка – Артикул WB"),
          const Text("✅ 2️⃣ Вторая – Себестоимость единицы товара"),
          const Text("✅ 3️⃣ Третья – Расходы на упаковку"),
          const Text("✅ 4️⃣ Четвёртая – Расходы на доставку"),
          const Text("✅ 5️⃣ Пятая – Платная приёмка"),
        ],
      ),
    );
  }
}
