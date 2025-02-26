import 'package:flutter/material.dart';
import 'package:mc_dashboard/presentation/tokens_screen/tokens_view_model.dart';
import 'package:provider/provider.dart';

class TokensScreen extends StatefulWidget {
  const TokensScreen({super.key});

  @override
  State<TokensScreen> createState() => _TokensScreenState();
}

class _TokensScreenState extends State<TokensScreen> {
  final TextEditingController _wbTokenController = TextEditingController();
  final TextEditingController _ozonTokenController = TextEditingController();
  final TextEditingController _ozonIdController = TextEditingController();

  bool _wbTokenVisible = false;
  bool _ozonTokenVisible = false;
  bool _ozonIdVisible = false;

  @override
  void dispose() {
    _wbTokenController.dispose();
    _ozonTokenController.dispose();
    _ozonIdController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final model = context.watch<TokensViewModel>();

    _wbTokenController.text = model.wbToken ?? "";
    _ozonTokenController.text = model.ozonToken ?? "";
    _ozonIdController.text = model.ozonId ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TokensViewModel>(
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(title: const Text("Настройки токенов")),
          body: model.isLoading
              ? const Center(child: CircularProgressIndicator())
              : model.errorMessage != null
                  ? Center(
                      child: Text(
                        model.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : _buildTokensForm(model),
        );
      },
    );
  }

  Widget _buildTokensForm(TokensViewModel model) {
    return Center(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (model.allTokensSet)
              const Text(
                "✅ Все токены добавлены! Приложение готово к работе.",
                style: TextStyle(color: Colors.green, fontSize: 16),
                textAlign: TextAlign.center,
              )
            else
              const Text(
                "⚠️ Не все токены добавлены! Пожалуйста, введите все необходимые данные.",
                style: TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 16),
            _buildTokenField(
              "Токен WB",
              _wbTokenController,
              model.wbToken,
              _wbTokenVisible,
              () {
                setState(() {
                  _wbTokenVisible = !_wbTokenVisible;
                });
              },
              model.saveWbToken,
              model.removeWbToken,
            ),
            _buildTokenField(
              "Токен Ozon",
              _ozonTokenController,
              model.ozonToken,
              _ozonTokenVisible,
              () {
                setState(() {
                  _ozonTokenVisible = !_ozonTokenVisible;
                });
              },
              model.saveOzonToken,
              model.removeOzonToken,
            ),
            _buildTokenField(
              "Ozon Client ID",
              _ozonIdController,
              model.ozonId,
              _ozonIdVisible,
              () {
                setState(() {
                  _ozonIdVisible = !_ozonIdVisible;
                });
              },
              model.saveOzonId,
              model.removeOzonId,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenField(
    String label,
    TextEditingController controller,
    String? token,
    bool isVisible,
    VoidCallback toggleVisibility,
    Function(String) onSave,
    VoidCallback onDelete,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: !isVisible, // только маска
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            isVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed:
                              toggleVisibility, // только переключаем флаг
                        ),
                        if (token != null)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              onDelete();
                              setState(() {
                                controller.clear();
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                token != null ? Icons.check_circle : Icons.error,
                color: token != null ? Colors.green : Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () => onSave(controller.text.trim()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.onSecondary,
              ),
              child: const Text("Сохранить"),
            ),
          ),
        ],
      ),
    );
  }
}
