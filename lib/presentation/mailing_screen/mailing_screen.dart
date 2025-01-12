import 'package:flutter/material.dart';
import 'package:mc_dashboard/presentation/mailing_screen/mailing_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mc_dashboard/domain/entities/saved_product.dart';
import 'package:mc_dashboard/presentation/mailing_screen/saved_products_view_model.dart';
import 'package:mc_dashboard/presentation/mailing_screen/saved_key_phrases_view_model.dart';

class MailingScreen extends StatelessWidget {
  const MailingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          title: Text(
            'Выбранные',
            style: theme.textTheme.titleLarge!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurface,
            tabs: const [
              Tab(text: 'Настройки'),
              Tab(text: 'Товары'),
              Tab(text: 'Ключевые фразы'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _MailingSettingsTab(),
            _SavedProductsTab(),
            _SavedKeyPhrasesTab(),
          ],
        ),
      ),
    );
  }
}

class _MailingSettingsTab extends StatelessWidget {
  const _MailingSettingsTab();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<MailingSettingsViewModel>();
    final theme = Theme.of(context);
    final surfaceContainerHighest = theme.colorScheme.surfaceContainerHighest;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 700,
          minWidth: 300,
        ),
        child: Container(
          margin: const EdgeInsets.all(8.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSubscriptionNotice(context),
                const SizedBox(height: 16),
                if (_shouldShowDisabledMailNotice(model)) ...[
                  DisabledNoticeWidget(
                      text: "Рассылка отключена. Вы не ввели email-адрес."),
                ],
                if (!_anyOptionSelected(model)) ...[
                  DisabledNoticeWidget(
                      text: "Рассылка отключена. Вы не выбрали ни одну опцию."),
                ],
                if (_shouldShowDisabledPeriodNotice(model)) ...[
                  DisabledNoticeWidget(
                      text: "Рассылка отключена. Вы не выбрали периодичность."),
                ],
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Периодичность",
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildCheckboxOption(
                  context,
                  label: "Ежедневно",
                  value: model.daily,
                  onChanged: (value) => model.toggleDaily(value ?? false),
                ),
                _buildCheckboxOption(
                  context,
                  label: "Еженедельно",
                  value: model.weekly,
                  onChanged: (value) => model.toggleWeekly(value ?? false),
                ),
                const SizedBox(height: 36),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Опции",
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildCheckboxOption(
                  context,
                  label: "Анализ позиций",
                  value: model.productPosition,
                  onChanged: (value) =>
                      model.toggleProductPosition(value ?? false),
                ),
                _buildCheckboxOption(
                  context,
                  label: "Уведомления о ценах",
                  value: model.productPrice,
                  onChanged: (value) =>
                      model.togglePriceChanges(value ?? false),
                ),
                _buildCheckboxOption(
                  context,
                  label: "Тренды",
                  value: model.newSearchQueries,
                  onChanged: (value) =>
                      model.toggleNewSearchQueries(value ?? false),
                ),
                _buildCheckboxOption(
                  context,
                  label: "Акции",
                  value: model.productPromotions,
                  onChanged: (value) =>
                      model.toggleProductPromotions(value ?? false),
                ),
                _buildCheckboxOption(
                  context,
                  label: "Изменения карточек",
                  value: model.productCardChanges,
                  onChanged: (value) =>
                      model.toggleProductCardChanges(value ?? false),
                ),
                _buildCheckboxOption(
                  context,
                  label: "Изменение ассортимента",
                  value: model.assortmentChanges,
                  onChanged: (value) =>
                      model.toggleAssortmentChanges(value ?? false),
                ),
                const SizedBox(height: 36),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Список email-адресов",
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const _EmailsEditor(),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      model.onSave();
                    },
                    child: const Text("Сохранить"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxOption(BuildContext context,
      {required String label,
      required bool value,
      required ValueChanged<bool?> onChanged}) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Checkbox(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          checkColor: theme.colorScheme.onSecondary,
          activeColor: theme.colorScheme.secondary,
          side: BorderSide(
            color: theme.colorScheme.onSurface
                .withOpacity(0.5), // Цвет границы, когда неактивен
            width: 2, // Толщина границы
          ),
          value: value,
          onChanged: (newValue) {
            final model = context.read<MailingSettingsViewModel>();
            if (!model.isSubscribed) {
              _showSubscribeAlert(context, model);
              return;
            }
            onChanged(newValue);
          },
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  bool _shouldShowDisabledPeriodNotice(MailingSettingsViewModel model) {
    return !model.daily && !model.weekly;
  }

  bool _shouldShowDisabledMailNotice(MailingSettingsViewModel model) {
    return model.emails.isEmpty;
  }

  bool _anyOptionSelected(MailingSettingsViewModel model) {
    return model.productPosition ||
        model.productPromotions ||
        model.newSearchQueries ||
        model.assortmentChanges ||
        model.productPrice ||
        model.productCardChanges;
  }

  void _showSubscribeAlert(
      BuildContext context, MailingSettingsViewModel model) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          'Чтобы добавлять товары и получать по ним рассылку, вы должны быть подписчиком.'),
      action: SnackBarAction(
        label: 'Оформить подписку',
        onPressed: () {
          model.onNavigateToSubscriptionScreen();
        },
      ),
      duration: Duration(seconds: 10),
    ));
  }

  Widget _buildSubscriptionNotice(BuildContext context) {
    final model = context.watch<MailingSettingsViewModel>();
    final theme = Theme.of(context);

    if (model.isSubscribed) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.1),
        border: Border.all(color: theme.colorScheme.errorContainer),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: theme.colorScheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Рассылки доступны только подписчикам.\n\n"
              "Оформите подписку, чтобы получать отчёты с данными о позициях товаров, ценах и действиях конкурентов.",
              style: TextStyle(
                color: theme.colorScheme.error,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              model.onNavigateToSubscriptionScreen();
            },
            child: const Text("Подписаться"),
          ),
        ],
      ),
    );
  }
}

class DisabledNoticeWidget extends StatelessWidget {
  const DisabledNoticeWidget({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.1),
        border: Border.all(color: theme.colorScheme.errorContainer),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: theme.colorScheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmailsEditor extends StatefulWidget {
  const _EmailsEditor({Key? key}) : super(key: key);

  @override
  State<_EmailsEditor> createState() => _EmailsEditorState();
}

class _EmailsEditorState extends State<_EmailsEditor> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<MailingSettingsViewModel>();
    final emails = model.emails;
    final errorMessage = model.errorMessage;

    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Добавить email",
                  hintText: "example@domain.com",
                  errorText: errorMessage,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                if (!model.isSubscribed) {
                  _showSubscribeAlert(context, model);
                  return;
                }
                final email = _emailController.text.trim();
                if (email.isNotEmpty) {
                  model.addEmail(email);
                  if (model.errorMessage == null) {
                    _emailController.clear();
                  }
                }
              },
              child: const Text("Добавить"),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...emails.map(
          (email) => ListTile(
            title: Text(email),
            trailing: IconButton(
              icon: CircleAvatar(
                backgroundColor: theme.colorScheme.secondary,
                child: Icon(
                  Icons.delete,
                  size: MediaQuery.of(context).size.width * 0.01,
                  color: theme.colorScheme.onSecondary,
                ),
              ),
              onPressed: () {
                if (!model.isSubscribed) {
                  _showSubscribeAlert(context, model);
                  return;
                }
                model.removeEmail(email);
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showSubscribeAlert(
      BuildContext context, MailingSettingsViewModel model) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          'Чтобы добавлять товары и получать по ним рассылку, вы должны быть подписчиком.'),
      action: SnackBarAction(
        label: 'Оформить подписку',
        onPressed: () {
          model.onNavigateToSubscriptionScreen();
        },
      ),
      duration: Duration(seconds: 10),
    ));
  }
}

class _SavedProductsTab extends StatelessWidget {
  const _SavedProductsTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceContainerHighest = theme.colorScheme.surfaceContainerHighest;
    final model = context.watch<MailingSettingsViewModel>();
    final isSubscribed = model.isSubscribed;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Column(
            children: [
              const _Header(),
              Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                height: constraints.maxHeight * 0.9,
                child: _SavedTableWidget(
                  isSubscribed: isSubscribed,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Выбранные товары",
            style: TextStyle(
              fontSize: theme.textTheme.titleLarge!.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _SavedTableWidget extends StatefulWidget {
  const _SavedTableWidget({required this.isSubscribed});
  final bool isSubscribed;

  @override
  State<_SavedTableWidget> createState() => _SavedTableWidgetState();
}

class _SavedTableWidgetState extends State<_SavedTableWidget> {
  final tableViewController = TableViewController();

  @override
  void dispose() {
    tableViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SavedProductsViewModel>();
    final onNavigateToSubscriptionScreen =
        context.read<MailingSettingsViewModel>().onNavigateToSubscriptionScreen;
    final theme = Theme.of(context);
    final savedList = model.savedProducts;
    if (savedList.isEmpty) {
      return Center(
        child: Text(
          "Список сохраненных товаров пуст",
          style: theme.textTheme.titleMedium,
        ),
      );
    }
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final maxHeight = constraints.maxHeight;
              final isMobile = (maxWidth < 600) && (maxHeight < 690);

              final mobileMinColumnWidths = [
                50.0,
                200.0,
                150.0,
                150.0,
              ];

              final columnProportions = [
                0.08,
                0.35,
                0.28,
                0.29,
              ];

              final columnWidths = isMobile
                  ? mobileMinColumnWidths
                  : columnProportions.map((p) => p * maxWidth).toList();

              final columns = <TableColumn>[
                TableColumn(width: columnWidths[0]),
                TableColumn(width: columnWidths[1]),
                TableColumn(width: columnWidths[2]),
                TableColumn(width: columnWidths[3]),
              ];

              return Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      padding:
                          const EdgeInsets.fromLTRB(16.0, 50.0, 16.0, 16.0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: TableView.builder(
                        controller: tableViewController,
                        columns: columns,
                        rowHeight: model.tableRowHeight,
                        rowCount: savedList.length,
                        headerBuilder: (context, contentBuilder) {
                          return contentBuilder(context,
                              (context, columnIndex) {
                            switch (columnIndex) {
                              case 0:
                                return const SizedBox();
                              case 1:
                                return _buildHeaderCell(context, "Товар");
                              case 2:
                                return _buildHeaderCell(context, "Продавец");
                              case 3:
                                return _buildHeaderCell(context, "Бренд");
                              default:
                                return const SizedBox();
                            }
                          });
                        },
                        rowBuilder: (context, rowIndex, contentBuilder) {
                          final item = savedList[rowIndex];
                          return KeyedSubtree(
                            key: ValueKey<int>(item.productId),
                            child: _SavedTableRow(
                              model: model,
                              item: item,
                              contentBuilder: contentBuilder,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    left: 26,
                    top: 26,
                    child: Text(
                      "Всего сохранённых товаров: ${savedList.length}",
                      style: TextStyle(
                        fontSize: theme.textTheme.bodyMedium!.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (model.selectedRows.isNotEmpty)
                    Positioned(
                      bottom: 24,
                      right: 24,
                      child: SpeedDial(
                        icon: Icons.more_vert,
                        activeIcon: Icons.close,
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: theme.colorScheme.onSecondary,
                        onClose: () {
                          setState(() {
                            model.selectedRows.clear();
                          });
                        },
                        children: [
                          SpeedDialChild(
                            backgroundColor: theme.colorScheme.secondary,
                            child: Icon(Icons.delete,
                                color: theme.colorScheme.onSecondary),
                            label: "Убрать из сохранённых",
                            onTap: () {
                              if (!widget.isSubscribed) {
                                // if the user is not subscribed
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                      'Чтобы добавлять товары и получать по ним рассылку, вы должны быть подписчиком.'),
                                  action: SnackBarAction(
                                    label: 'Оформить подписку',
                                    onPressed: () {
                                      onNavigateToSubscriptionScreen();
                                    },
                                  ),
                                  duration: Duration(seconds: 10),
                                ));
                              } else {
                                // if the user is subscribed
                                model.removeProductsFromSaved(
                                    model.selectedRows, widget.isSubscribed);
                                setState(() {
                                  model.selectedRows.clear();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Container(
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: theme.textTheme.bodyMedium!.fontSize,
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SavedTableRow extends StatelessWidget {
  final SavedProductsViewModel model;
  final SavedProduct item;
  final Widget Function(
    BuildContext,
    Widget Function(BuildContext, int columnIndex),
  ) contentBuilder;

  const _SavedTableRow({
    Key? key,
    required this.model,
    required this.item,
    required this.contentBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return contentBuilder(context, (context, columnIndex) {
      switch (columnIndex) {
        case 0:
          return _CheckboxCell(productId: item.productId);

        case 1:
          return _ProductCell(item: item);

        case 2:
          return _TextCell(text: item.sellerName);

        case 3:
          return _TextCell(text: item.brandName);

        default:
          return const SizedBox();
      }
    });
  }
}

class _CheckboxCell extends StatelessWidget {
  final int productId;
  const _CheckboxCell({Key? key, required this.productId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Selector<SavedProductsViewModel, bool>(
      selector: (_, vm) => vm.selectedRows.contains(productId),
      builder: (context, isSelected, child) {
        return Container(
          alignment: Alignment.center,
          child: Checkbox(
            checkColor: theme.colorScheme.secondary,
            activeColor: Colors.transparent,
            value: isSelected,
            onChanged: (bool? value) {
              context.read<SavedProductsViewModel>().selectRow(productId);
            },
          ),
        );
      },
    );
  }
}

class _TextCell extends StatelessWidget {
  final String text;
  const _TextCell({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text(text),
    );
  }
}

class _ProductCell extends StatelessWidget {
  final SavedProduct item;
  const _ProductCell({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.imageUrl;
    final productName = item.name;
    final wildberriesUrl =
        "https://wildberries.ru/catalog/${item.productId}/detail.aspx?targetUrl=EX";

    if (imageUrl.isEmpty) {
      return Row(
        children: [
          Image.asset('images/no_image.jpg', width: 50),
          const SizedBox(width: 8),
          productName.isEmpty
              ? const Text("Описание отсутствует")
              : Text(productName),
        ],
      );
    }

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (imageUrl.isNotEmpty) {
              showDialog(
                context: context,
                builder: (_) => Dialog(
                  child: InteractiveViewer(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Image.network(imageUrl),
                      ),
                    ),
                  ),
                ),
              );
            }
          },
          child:
              Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => launchUrl(Uri.parse(wildberriesUrl)),
              child: Text(
                productName.isEmpty ? "Без названия" : productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  decoration: TextDecoration.underline,
                  color: Color(0xFF5166e3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SavedKeyPhrasesTab extends StatelessWidget {
  const _SavedKeyPhrasesTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceContainerHighest = theme.colorScheme.surfaceContainerHighest;
    final model = context.watch<MailingSettingsViewModel>();
    final isSubscribed = model.isSubscribed;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Column(
            children: [
              _KeyPhrasesHeader(),
              Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                height: constraints.maxHeight * 0.9,
                child: _KeyPhrasesTableWidget(
                  isSubscribed: isSubscribed,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _KeyPhrasesHeader extends StatelessWidget {
  const _KeyPhrasesHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      alignment: Alignment.centerLeft,
      child: Text(
        "Ключевые фразы",
        style: TextStyle(
          fontSize: theme.textTheme.titleLarge?.fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _KeyPhrasesTableWidget extends StatefulWidget {
  const _KeyPhrasesTableWidget({required this.isSubscribed});
  final bool isSubscribed;

  @override
  State<_KeyPhrasesTableWidget> createState() => _KeyPhrasesTableWidgetState();
}

class _KeyPhrasesTableWidgetState extends State<_KeyPhrasesTableWidget> {
  final tableViewController = TableViewController();
  final Set<int> selectedIndices = {};

  @override
  void dispose() {
    tableViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SavedKeyPhrasesViewModel>();
    final onNavigateToSubscriptionScreen =
        context.read<MailingSettingsViewModel>().onNavigateToSubscriptionScreen;
    final theme = Theme.of(context);
    final phrases = model.keyPhrases;

    if (phrases.isEmpty) {
      return Center(
        child: Text(
          "Список ключевых фраз пуст",
          style: theme.textTheme.titleMedium,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isMobile = maxWidth < 600;

        final columnWidths =
            isMobile ? [50.0, maxWidth - 66] : [maxWidth * 0.1, maxWidth * 0.9];

        final columns = [
          TableColumn(width: columnWidths[0]),
          TableColumn(width: columnWidths[1]),
        ];

        return Stack(
          children: [
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.fromLTRB(16.0, 50.0, 16.0, 16.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TableView.builder(
                  controller: tableViewController,
                  columns: columns,
                  rowHeight: model.tableRowHeight,
                  rowCount: phrases.length,
                  headerBuilder: (context, contentBuilder) {
                    return contentBuilder(context, (ctx, colIndex) {
                      if (colIndex == 0) {
                        return Checkbox(
                          value: selectedIndices.length == phrases.length,
                          checkColor: theme.colorScheme.secondary,
                          activeColor: Colors.transparent,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedIndices.addAll(
                                  List.generate(phrases.length, (i) => i),
                                );
                              } else {
                                selectedIndices.clear();
                              }
                            });
                          },
                        );
                      }
                      return Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          "Поисковые запросы",
                          style: TextStyle(
                            fontSize: theme.textTheme.bodyMedium?.fontSize,
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    });
                  },
                  rowBuilder: (context, rowIndex, contentBuilder) {
                    final item = phrases[rowIndex];
                    return contentBuilder(context, (ctx, colIndex) {
                      if (colIndex == 0) {
                        return _KeyPhrasesCheckboxCell(
                          index: rowIndex,
                          selectedIndices: selectedIndices,
                          onToggle: (selected) {
                            setState(() {
                              if (selected) {
                                selectedIndices.add(rowIndex);
                              } else {
                                selectedIndices.remove(rowIndex);
                              }
                            });
                          },
                        );
                      }
                      return Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(item.phraseText),
                      );
                    });
                  },
                ),
              ),
            ),
            Positioned(
              left: 26,
              top: 26,
              child: Text(
                "Всего фраз: ${phrases.length}",
                style: TextStyle(
                  fontSize: theme.textTheme.bodyMedium?.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (selectedIndices.isNotEmpty)
              Positioned(
                bottom: 24,
                right: 24,
                child: SpeedDial(
                  icon: Icons.more_vert,
                  activeIcon: Icons.close,
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: theme.colorScheme.onSecondary,
                  onClose: () {
                    setState(() {
                      selectedIndices.clear();
                    });
                  },
                  children: [
                    SpeedDialChild(
                      backgroundColor: theme.colorScheme.secondary,
                      child: Icon(Icons.delete,
                          color: theme.colorScheme.onSecondary),
                      label: "Удалить выбранное",
                      onTap: () async {
                        if (!widget.isSubscribed) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                'Чтобы добавлять товары и получать по ним рассылку, вы должны быть подписчиком.'),
                            action: SnackBarAction(
                              label: 'Оформить подписку',
                              onPressed: () {
                                onNavigateToSubscriptionScreen();
                              },
                            ),
                            duration: Duration(seconds: 10),
                          ));
                          return;
                        } else {
                          final selectedPhrases = selectedIndices
                              .map((index) => phrases[index].phraseText)
                              .toList();

                          await model.deleteKeyPhrases(
                              selectedPhrases, widget.isSubscribed);
                        }
                      },
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _KeyPhrasesCheckboxCell extends StatelessWidget {
  final int index;
  final Set<int> selectedIndices;
  final ValueChanged<bool> onToggle;

  const _KeyPhrasesCheckboxCell({
    Key? key,
    required this.index,
    required this.selectedIndices,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      alignment: Alignment.center,
      child: Checkbox(
        checkColor: theme.colorScheme.secondary,
        activeColor: Colors.transparent,
        value: selectedIndices.contains(index),
        onChanged: (bool? value) {
          onToggle(value ?? false);
        },
      ),
    );
  }
}
