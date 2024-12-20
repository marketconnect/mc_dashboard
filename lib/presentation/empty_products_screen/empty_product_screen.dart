import 'package:flutter/material.dart';
import 'package:mc_dashboard/presentation/empty_products_screen/empty_product_view_model.dart';

import 'package:provider/provider.dart';

class EmptyProductScreen extends StatefulWidget {
  const EmptyProductScreen({super.key});

  @override
  State<EmptyProductScreen> createState() => _EmptyProductScreenState();
}

class _EmptyProductScreenState extends State<EmptyProductScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final model = context.watch<EmptyProductViewModel>();
    final onNavigateBack = model.onNavigateBack;
    final searchQuery = model.searchQuery;
    final onSearchChanged = model.onSearchChanged;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: IconButton(
                    onPressed: () => onNavigateBack(),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Поиск по SKU',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            onSearchChanged('');
                          },
                        )
                      : null,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  onSearchChanged(value);
                },
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: searchQuery.isEmpty
                    ? _buildPlaceholder(theme)
                    : _buildResultList(theme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Center(
      key: const ValueKey('placeholder'),
      child: Text(
        "Введите SKU для поиска",
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildResultList(ThemeData theme) {
    final model = context.watch<EmptyProductViewModel>();
    final name = model.searchedProductName;
    final sku = model.sku;
    final onNavigateToProductScreen = model.onNavigateToProductScreen;

    if (name == null || sku == null) {
      return Center(
        key: const ValueKey('no_results'),
        child: Text(
          "Товар не найден",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.builder(
      key: const ValueKey('result_list'),
      itemCount: 1,
      itemBuilder: (context, index) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: ListTile(
            title: Text(
              name,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text('SKU: $sku'),
            onTap: () {
              onNavigateToProductScreen(sku, 0);
            },
            trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
          ),
        );
      },
    );
  }
}
