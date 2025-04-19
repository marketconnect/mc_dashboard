import 'package:flutter/material.dart';
import 'package:mc_dashboard/presentation/market_screen/market_view_model.dart';
import 'package:mc_dashboard/routes/main_navigation_route_names.dart';
import 'package:provider/provider.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MarketViewModel>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Общий дашборд",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isWideScreen ? 24.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Блок с общей информацией о продажах
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isWideScreen ? 24.0 : 20.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                      Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Общая информация",
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                    ),
                    const SizedBox(height: 16),
                    if (!viewModel.isAllTokensSet)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .errorContainer
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .error
                                .withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Не все токены добавлены! Перейдите в настройки токенов для работы со всеми функциями.",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "Доступные действия",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = isWideScreen
                      ? (constraints.maxWidth > 1200 ? 4 : 3)
                      : (constraints.maxWidth > 600 ? 2 : 1);

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: isWideScreen ? 1.5 : 1.2,
                    children: [
                      // _buildNavigationCard(
                      //   context,
                      //   title: "Добавить карточки товаров",
                      //   icon: Icons.add_shopping_cart,
                      //   route: MainNavigationRouteNames.addCards,
                      //   description:
                      //       "Создание и редактирование карточек товаров",
                      // ),
                      _buildNavigationCard(
                        context,
                        title: "Карточки товаров",
                        icon: Icons.shopping_cart,
                        route: MainNavigationRouteNames.productCardsContainer,
                        description: "Управление существующими карточками",
                      ),
                      _buildNavigationCard(
                        context,
                        title: "Импорт стоимости товаров",
                        icon: Icons.upload,
                        route: MainNavigationRouteNames.productCostImportScreen,
                        description: "Загрузка и обновление цен товаров",
                      ),
                      // _buildNavigationCard(
                      //   context,
                      //   title: "Кампании",
                      //   icon: Icons.business,
                      //   route: MainNavigationRouteNames.wbStatsKeywordsScreen,
                      //   description: "Управление рекламными кампаниями",
                      // ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String route,
    required String description,
  }) {
    return Card(
      color: Theme.of(context).colorScheme.onSecondary,
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(
          icon,
          size: 32,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.of(context).pushNamed(route);
        },
      ),
    );
  }
}
