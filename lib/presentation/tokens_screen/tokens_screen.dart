import 'package:flutter/material.dart';
import 'package:mc_dashboard/presentation/tokens_screen/tokens_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
        width: 600,
        padding: const EdgeInsets.all(16.0),
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
            _buildTokenCard(
              context: context,
              icon: SvgPicture.asset('assets/images/wb_logo.svg',
                  height: 24, width: 24),
              label: " Token",
              controller: _wbTokenController,
              token: model.wbToken,
              isVisible: _wbTokenVisible,
              toggleVisibility: () {
                setState(() {
                  _wbTokenVisible = !_wbTokenVisible;
                });
              },
              onSave: model.saveWbToken,
              onDelete: model.removeWbToken,
            ),
            _buildTokenCard(
              context: context,
              icon: SvgPicture.asset('assets/images/ozon_logo.svg',
                  height: 24, width: 24),
              label: " Token",
              controller: _ozonTokenController,
              token: model.ozonToken,
              isVisible: _ozonTokenVisible,
              toggleVisibility: () {
                setState(() {
                  _ozonTokenVisible = !_ozonTokenVisible;
                });
              },
              onSave: model.saveOzonToken,
              onDelete: model.removeOzonToken,
            ),
            _buildTokenCard(
              context: context,
              icon: SvgPicture.asset('assets/images/ozon_logo.svg',
                  height: 24, width: 24),
              label: " Client ID",
              controller: _ozonIdController,
              token: model.ozonId,
              isVisible: _ozonIdVisible,
              toggleVisibility: () {
                setState(() {
                  _ozonIdVisible = !_ozonIdVisible;
                });
              },
              onSave: model.saveOzonId,
              onDelete: model.removeOzonId,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenCard({
    required BuildContext context,
    required Widget icon,
    required String label,
    required TextEditingController controller,
    required String? token,
    required bool isVisible,
    required VoidCallback toggleVisibility,
    required Function(String) onSave,
    required VoidCallback onDelete,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // Use theme's surface color
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: theme.dividerColor), // Use theme's divider color
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(width: 32, height: 32, child: icon),
              const SizedBox(width: 8),
              Text(label,
                  style: theme.textTheme.titleMedium), // Use theme's text style
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: !isVisible,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    hintText: 'Введите токен',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(
                          color:
                              theme.dividerColor), // Use theme's divider color
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: theme.primaryColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: toggleVisibility,
                child: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: theme.hintColor, // Use theme's hint color
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => onSave(controller.text.trim()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface,
                  foregroundColor: theme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  textStyle: const TextStyle(fontSize: 14),
                  elevation: 0,
                  side: BorderSide(color: theme.primaryColor),
                ),
                child: const Text("Сохранить"),
              ),
              if (token == null)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.error,
                      color:
                          theme.colorScheme.error), // Use theme's error color
                ),
            ],
          ),
        ],
      ),
    );
  }
}
