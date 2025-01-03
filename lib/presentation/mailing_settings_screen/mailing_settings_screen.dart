import 'package:flutter/material.dart';
import 'package:mc_dashboard/presentation/mailing_settings_screen/mailing_settings_view_model.dart';
import 'package:provider/provider.dart';

class MailingSettingsScreen extends StatefulWidget {
  const MailingSettingsScreen({super.key});

  @override
  State<MailingSettingsScreen> createState() => _MailingSettingsScreenState();
}

class _MailingSettingsScreenState extends State<MailingSettingsScreen> {
  String frequencyValue = "daily";

  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Настройка рассылок",
          style:
              theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;

          if (isDesktop) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      child: Column(
                        children: [
                          _buildSectionAandB(context),
                          const SizedBox(height: 16),
                          _buildEmailsSection(context),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
              ],
            );
          } else {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  _buildSectionAandB(context),
                  const SizedBox(height: 16),
                  _buildEmailsSection(context),
                  const SizedBox(height: 16),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildSectionAandB(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceContainerHighest = theme.colorScheme.surfaceContainerHighest;
    final model = context.watch<MailingSettingsViewModel>();

    final positionsCheckbox = model.positionsCheckbox;
    final pricesCheckbox = model.pricesCheckbox;
    final changesCheckbox = model.changesCheckbox;
    final missedQueriesCheckbox = model.missedQueriesCheckbox;

    final setPositionsCheckbox = model.setPositionsCheckbox;
    final setPricesCheckbox = model.setPricesCheckbox;
    final setChangesCheckbox = model.setChangesCheckbox;
    final setMissedQueriesCheckbox = model.setMissedQueriesCheckbox;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Выбор данных для отслеживания",
            style: theme.textTheme.titleMedium!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            title: const Text("Позиции в поиске."),
            value: positionsCheckbox,
            onChanged: (val) => setPositionsCheckbox(val ?? false),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            title: const Text("Динамика цен."),
            value: pricesCheckbox,
            onChanged: (val) => setPricesCheckbox(val ?? false),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            title: const Text("Изменения характеристик."),
            value: changesCheckbox,
            onChanged: (val) => setChangesCheckbox(val ?? false),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            title: const Text("Упущенные запросы."),
            value: missedQueriesCheckbox,
            onChanged: (val) => setMissedQueriesCheckbox(val ?? false),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 16),
          Text(
            "Частота рассылок",
            style: theme.textTheme.titleMedium!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text("Ежедневно."),
                  value: "daily",
                  groupValue: frequencyValue,
                  onChanged: (val) =>
                      setState(() => frequencyValue = val ?? "daily"),
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text("Еженедельно."),
                  value: "weekly",
                  groupValue: frequencyValue,
                  onChanged: (val) =>
                      setState(() => frequencyValue = val ?? "daily"),
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text("При значительных изменениях."),
                  value: "significant",
                  groupValue: frequencyValue,
                  onChanged: (val) =>
                      setState(() => frequencyValue = val ?? "daily"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmailsSection(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceContainerHighest = theme.colorScheme.surfaceContainerHighest;
    final model = context.watch<MailingSettingsViewModel>();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Список email-адресов",
            style: theme.textTheme.titleMedium!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Введите email",
                    hintText: "name@example.com",
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  final email = _emailController.text.trim();
                  if (email.isNotEmpty) {
                    model.addEmail(email);
                    _emailController.clear();
                  }
                },
                child: const Text("Добавить"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...model.emails.map((email) {
            return ListTile(
              title: Text(email),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => model.removeEmail(email),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Настройки сохранены!")),
    );
  }
}
