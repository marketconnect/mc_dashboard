import 'package:flutter/material.dart';

import 'package:mc_dashboard/presentation/empty_subjects_screen/empty_subjects_view_model.dart';
import 'package:provider/provider.dart';

class EmptySubjectProductsScreen extends StatefulWidget {
  const EmptySubjectProductsScreen({super.key});

  @override
  State<EmptySubjectProductsScreen> createState() =>
      _EmptySubjectProductsScreenState();
}

class _EmptySubjectProductsScreenState
    extends State<EmptySubjectProductsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final model = context.watch<EmptySubjectViewModel>();
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
                      )),
                ),
              ],
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Поиск по названию предмета',
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

            // Анимация появления списка
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: searchQuery.isEmpty
                    ? _buildPlaceholder(theme)
                    : _buildResultsList(theme),
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
        "Введите название предмета для поиска",
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildResultsList(ThemeData theme) {
    final model = context.watch<EmptySubjectViewModel>();
    final results = model.filteredSubjects;
    final onNavigateToSubjectProducts = model.onNavigateToSubjectProducts;
    if (results.isEmpty) {
      return Center(
        key: const ValueKey('no_results'),
        child: Text(
          "Нет подходящих предметов",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.builder(
      key: const ValueKey('results_list'),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: ListTile(
            title: Text(
              item.subjectName,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: item.subjectParentName != null
                ? Text(item.subjectParentName!,
                    style: theme.textTheme.bodyMedium)
                : null,
            onTap: () {
              onNavigateToSubjectProducts(item.subjectId, item.subjectName);
            },
            trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
          ),
        );
      },
    );
  }
}
