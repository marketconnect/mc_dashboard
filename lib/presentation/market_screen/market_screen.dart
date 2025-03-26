import 'package:flutter/material.dart';
import 'package:mc_dashboard/presentation/market_screen/market_view_model.dart';
import 'package:mc_dashboard/routes/main_navigation_route_names.dart';
import 'package:provider/provider.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MarketViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Общий дашборд")),
      body: Column(
        children: [
          // Блок с общей информацией о продажах
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  "Общая часть",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (!viewModel.isAllTokensSet)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .errorContainer
                          .withAlpha(51),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "⚠️ Не все токены добавлены! Перейдите в настройки токенов для работы со всеми функциями.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildNavigationCard(
                  context,
                  title: "Добавить карточки товаров",
                  icon: Icons.add_shopping_cart,
                  route: MainNavigationRouteNames.addCards,
                ),
                _buildNavigationCard(
                  context,
                  title: "Карточки товаров",
                  icon: Icons.shopping_cart,
                  route: MainNavigationRouteNames.productCardsContainer,
                ),
                _buildNavigationCard(
                  context,
                  title: "Импорт стоимости товаров",
                  icon: Icons.upload,
                  route: MainNavigationRouteNames.productCostImportScreen,
                ),
                _buildNavigationCard(
                  context,
                  title: "Кампании",
                  icon: Icons.business,
                  route: MainNavigationRouteNames.wbStatsKeywordsScreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationCard(BuildContext context,
      {required String title, required IconData icon, required String route}) {
    return Card(
      color: Theme.of(context).colorScheme.onSecondary,
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading:
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.of(context).pushNamed(route);
        },
      ),
    );
  }
}
