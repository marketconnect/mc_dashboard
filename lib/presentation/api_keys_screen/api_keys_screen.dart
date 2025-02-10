import 'package:flutter/material.dart';
import 'package:mc_dashboard/presentation/api_keys_screen/api_keys_view_model.dart';
import 'package:provider/provider.dart';

class ApiKeyScreen extends StatefulWidget {
  const ApiKeyScreen({super.key});

  @override
  State<ApiKeyScreen> createState() => _ApiKeyScreenState();
}

class _ApiKeyScreenState extends State<ApiKeyScreen> {
  // final TextEditingController _keyNameController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ApiKeyViewModel>().asyncInit();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final model = context.watch<ApiKeyViewModel>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: const Text("API Keys")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16.0),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: model.apiKeys.isEmpty
                    ? _buildPlaceholder(theme)
                    : _buildApiKeysList(model, theme),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddApiKeyDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Center(
      key: const ValueKey('placeholder'),
      child: Text(
        "Нет сохраненных API ключей",
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildApiKeysList(ApiKeyViewModel model, ThemeData theme) {
    final apiKeys = model.filteredApiKeys;
    return ListView.builder(
      key: const ValueKey('api_keys_list'),
      itemCount: apiKeys.length,
      itemBuilder: (context, index) {
        final entry = apiKeys[index];
        return ListTile(
          title: Text(entry.key, style: theme.textTheme.bodyLarge),
          subtitle: Text("Токен: ${entry.value.substring(0, 4)}****"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditApiKeyDialog(entry.key, entry.value),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => model.deleteApiKey(entry.key),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddApiKeyDialog() {
    // _keyNameController.clear();
    _tokenController.clear();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Добавить API ключ"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TextField(
            //     controller: _keyNameController,
            //     decoration: const InputDecoration(labelText: "Название ключа")),
            TextField(
                controller: _tokenController,
                decoration: const InputDecoration(labelText: "Токен")),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Отмена")),
          TextButton(
            onPressed: () {
              context.read<ApiKeyViewModel>().addApiKey(_tokenController.text);
              Navigator.pop(context);
            },
            child: const Text("Сохранить"),
          ),
        ],
      ),
    );
  }

  void _showEditApiKeyDialog(String oldKeyName, String oldToken) {
    // _keyNameController.text = oldKeyName;
    _tokenController.text = oldToken;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Редактировать API ключ"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TextField(
            //     controller: _keyNameController,
            //     decoration: const InputDecoration(labelText: "Название ключа")),
            TextField(
                controller: _tokenController,
                decoration: const InputDecoration(labelText: "Токен")),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Отмена")),
          TextButton(
            onPressed: () {
              context.read<ApiKeyViewModel>().deleteApiKey(oldKeyName);
              context.read<ApiKeyViewModel>().addApiKey(_tokenController.text);
              Navigator.pop(context);
            },
            child: const Text("Обновить"),
          ),
        ],
      ),
    );
  }
}
