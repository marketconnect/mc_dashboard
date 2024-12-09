import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mc_dashboard/presentation/subject_products_screen/subject_products_view_model.dart';

class SubjectProductsScreen extends StatelessWidget {
  const SubjectProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SubjectProductsViewModel>();

    final isFilterVisible = model.isFilterVisible;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Детализированные заказы"),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: model.toggleFilterVisibility,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          return Column(
            children: [
              if (isFilterVisible)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildFiltersWidget(context),
                ),
              Expanded(
                child: _buildTableWidget(context, isMobile),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFiltersWidget(BuildContext context) {
    final model = context.watch<SubjectProductsViewModel>();
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Фильтры",
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: "Мин. цена",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  controller: model.filterControllers["price"]!["min"],
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: "Макс. цена",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  controller: model.filterControllers["price"]!["max"],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: "Мин. заказы",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  controller: model.filterControllers["orders"]!["min"],
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: "Макс. заказы",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  controller: model.filterControllers["orders"]!["max"],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: model.clearFilterControllers,
                child: const Text("Сбросить"),
              ),
              ElevatedButton(
                onPressed: () {
                  model.applyFilters();
                },
                child: const Text("Применить"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableWidget(BuildContext context, bool isMobile) {
    final model = context.watch<SubjectProductsViewModel>();
    final data = model.detailedOrders;

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(child: Text("Категория: ${item.subjectId}")),
                Expanded(child: Text("Цена: ${item.price}")),
                Expanded(child: Text("Заказы: ${item.orders}")),
                Expanded(child: Text("FBS: ${item.isFbs}")),
                Expanded(child: Text("Корзина: ${item.basket}")),
                Expanded(child: Text("Бренд: ${item.brand}")),
                Expanded(child: Text("Поставщик: ${item.supplier}")),
              ],
            ),
          ),
        );
      },
    );
  }
}
