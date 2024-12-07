import 'package:flutter/material.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:mc_dashboard/core/utils/colors.dart';
import 'package:mc_dashboard/core/utils/strings_ext.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';
import 'package:mc_dashboard/presentation/choosing_niche_screen/choosing_niche_view_model.dart';

class ChoosingNicheScreen extends StatelessWidget {
  const ChoosingNicheScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final surfaceContainerHighest =
        Theme.of(context).colorScheme.surfaceContainerHighest;

    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isMobile = maxWidth < 600;

        return Column(
          children: [
            Flexible(
              flex: 1,
              child: isMobile
                  ? Column(
                      children: [
                        Flexible(
                          flex: 1,
                          child: Container(
                              margin: const EdgeInsets.all(8.0),
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: const FilterWidget()),
                        ),
                        Flexible(
                          flex: 3,
                          child: Container(
                            margin: const EdgeInsets.all(8.0),
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: PieChartWidget(maxWidth: maxWidth),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: Container(
                            margin: const EdgeInsets.all(8.0),
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: const FilterWidget(),
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          child: Container(
                            margin: const EdgeInsets.all(8.0),
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: PieChartWidget(maxWidth: maxWidth),
                          ),
                        ),
                      ],
                    ),
            ),
            Flexible(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TableWidget(),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class FilterWidget extends StatefulWidget {
  const FilterWidget({Key? key}) : super(key: key);

  @override
  State<FilterWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  final TextEditingController _minRevenueController = TextEditingController();
  final TextEditingController _maxRevenueController = TextEditingController();
  final TextEditingController _minOrdersController = TextEditingController();
  final TextEditingController _maxOrdersController = TextEditingController();
  final TextEditingController _minSkusController = TextEditingController();
  final TextEditingController _maxSkusController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final TextEditingController _minSkusWithOrdersController =
      TextEditingController();
  final TextEditingController _maxSkusWithOrdersController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final model = context.watch<ChoosingNicheViewModel>();
    final onFilter = model.filterData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Фильтры",
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        _buildExpandableFilter(
            "Выручка (₽)", _minRevenueController, _maxRevenueController),
        _buildExpandableFilter(
            "Кол-во заказов", _minOrdersController, _maxOrdersController),
        _buildExpandableFilter(
            "Товары", _minSkusController, _maxSkusController),
        _buildExpandableFilter(
            "Медианная цена (₽)", _minPriceController, _maxPriceController),
        _buildExpandableFilter("Товары с заказами",
            _minSkusWithOrdersController, _maxSkusWithOrdersController),
        const SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: () {
            onFilter(
              minTotalRevenue: _parseInt(_minRevenueController.text),
              maxTotalRevenue: _parseInt(_maxRevenueController.text),
              minTotalOrders: _parseInt(_minOrdersController.text),
              maxTotalOrders: _parseInt(_maxOrdersController.text),
              minTotalSkus: _parseInt(_minSkusController.text),
              maxTotalSkus: _parseInt(_maxSkusController.text),
              minMedianPrice: _parseInt(_minPriceController.text),
              maxMedianPrice: _parseInt(_maxPriceController.text),
              minSkusWithOrders: _parseInt(_minSkusWithOrdersController.text),
              maxSkusWithOrders: _parseInt(_maxSkusWithOrdersController.text),
            );
          },
          child: const Text("Применить"),
        ),
      ],
    );
  }

  Widget _buildExpandableFilter(
    String label,
    TextEditingController minController,
    TextEditingController maxController,
  ) {
    return ExpansionTile(
      title: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: TextField(
                  controller: minController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 12), // Уменьшение шрифта
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 8.0), // Уменьшение отступов
                    labelText: "$label (мин)",
                    labelStyle:
                        const TextStyle(fontSize: 12), // Уменьшение шрифта
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: maxController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 12), // Уменьшение шрифта
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 8.0), // Уменьшение отступов
                    labelText: "$label (макс)",
                    labelStyle:
                        const TextStyle(fontSize: 12), // Уменьшение шрифта
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  int? _parseInt(String value) {
    return int.tryParse(value.isEmpty ? '' : value);
  }
}

class PieChartWidget extends StatelessWidget {
  const PieChartWidget({super.key, required this.maxWidth});
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ChoosingNicheViewModel>();
    final loading = model.loading;
    final error = model.error;
    final selectedParentName =
        model.selectedParentName ?? 'Родительские категории';

    final theme = Theme.of(context);
    final colorList = generateColorList(model.currentDataMap.keys.length);
    final header = model.diagramHeader;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: error != null
          ? [
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: maxWidth * 0.5,
                    child: Text(
                      error.toString(),
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              )
            ]
          : loading || model.currentDataMap.isEmpty
              ? const [Expanded(child: Center(child: Text('Загрузка...')))]
              : [
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 8.0, left: 8.0, right: 8.0),
                    child: Text(
                      header,
                      style: TextStyle(
                        fontSize: theme.textTheme.titleLarge!.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: PieChart(
                            dataMap: model.currentDataMap,
                            animationDuration:
                                const Duration(milliseconds: 800),
                            chartValuesOptions: const ChartValuesOptions(
                              showChartValuesInPercentage: true,
                            ),
                            colorList: colorList,
                            legendOptions: const LegendOptions(
                              showLegends: false,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Заголовок
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                child: Text(
                                  '$selectedParentName (ТОП-10)',
                                  style: TextStyle(
                                    fontSize:
                                        theme.textTheme.bodyMedium!.fontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // Список
                              Expanded(
                                child: ListView.builder(
                                  itemCount: model.currentDataMap.keys.length,
                                  itemBuilder: (context, index) {
                                    final key = model.currentDataMap.keys
                                        .elementAt(index);
                                    final value = model.currentDataMap[key]!;
                                    final color = colorList[index];

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: MouseRegion(
                                        cursor: model.selectedParentName == null
                                            ? SystemMouseCursors.basic
                                            : SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: () =>
                                              model.scrollToSubjectName(key),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 16,
                                                height: 16,
                                                margin: const EdgeInsets.only(
                                                    right: 8.0),
                                                decoration: BoxDecoration(
                                                  color: color,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  '$key: ${value.toStringAsFixed(0).formatWithThousands()} ₽',
                                                  style: TextStyle(
                                                      fontSize: theme
                                                          .textTheme
                                                          .bodyMedium!
                                                          .fontSize),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
    );
  }
}

class TableWidget extends StatelessWidget {
  const TableWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ChoosingNicheViewModel>();
    final subjectsSummary = model.subjectsSummary;
    final sortData = model.sortData;
    final sortColumnIndex = model.sortColumnIndex;
    final isAscending = model.isAscending;
    final theme = Theme.of(context);
    final tableViewController = model.tableViewController;
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final isMobile = totalWidth < 600;

        final mobileMinColumnWidths = [
          100.0,
          80.0,
          80.0,
          80.0,
          80.0,
          80.0,
        ];

        final columnProportions = [
          0.2,
          0.15,
          0.15,
          0.15,
          0.15,
          0.15,
        ];

        final columnWidths = isMobile
            ? mobileMinColumnWidths
            : columnProportions.map((p) => p * totalWidth).toList();

        final columns = <TableColumn>[
          TableColumn(width: columnWidths[0]),
          TableColumn(width: columnWidths[1]),
          TableColumn(width: columnWidths[2]),
          TableColumn(width: columnWidths[3]),
          TableColumn(width: columnWidths[4]),
          TableColumn(width: columnWidths[5]),
        ];

        return TableView.builder(
          controller: tableViewController,
          columns: columns,
          rowHeight: 48,
          rowCount: subjectsSummary.length,
          headerBuilder: (context, contentBuilder) {
            return contentBuilder(context, (context, columnIndex) {
              final headers = [
                "Предметы",
                "Выручка (₽)",
                "Товары",
                "Кол-во заказов",
                "Медианная цена (₽)",
                "Товары с заказами"
              ];
              final alignment =
                  columnIndex == 0 ? Alignment.centerLeft : Alignment.center;

              return GestureDetector(
                onTap: () {
                  if (columnIndex == 4) {
                    return;
                  }
                  sortData(columnIndex);
                },
                child: Container(
                  alignment: alignment,
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: columnIndex == 0
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          headers[columnIndex],
                          textAlign: columnIndex == 0
                              ? TextAlign.left
                              : TextAlign.center,
                          style: TextStyle(
                            fontSize: theme.textTheme.titleLarge!.fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          softWrap: true,
                        ),
                      ),
                      if (columnIndex == sortColumnIndex)
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Icon(
                            isAscending
                                ? Icons.arrow_drop_down
                                : Icons.arrow_drop_up,
                            color: theme.colorScheme.onSurface,
                            size: theme.textTheme.titleLarge!.fontSize,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            });
          },
          rowBuilder: (context, rowIndex, contentBuilder) {
            final item = subjectsSummary[rowIndex];
            return contentBuilder(context, (context, columnIndex) {
              TextAlign textAlign =
                  columnIndex == 0 ? TextAlign.left : TextAlign.center;
              String text;
              switch (columnIndex) {
                case 0:
                  text = '${item.subjectParentName ?? ''}/${item.subjectName}';
                  break;
                case 1:
                  text = item.totalRevenue.toString().formatWithThousands();
                  break;
                case 2:
                  text = item.totalSkus.toString().formatWithThousands();

                  break;
                case 3:
                  text = item.totalOrders.toString().formatWithThousands();

                  break;
                case 4:
                  text = item.medianPrice.toString().formatWithThousands();
                  break;
                case 5:
                  text =
                      '${item.skusWithOrders.toString().formatWithThousands()} шт. (${(item.skusWithOrders / item.totalSkus * 100.0).toStringAsFixed(0)}%)';

                  break;
                default:
                  text = '';
              }
              return MouseRegion(
                cursor: columnIndex == 0 || columnIndex == 4
                    ? SystemMouseCursors.basic
                    : SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    if (columnIndex == 4) {
                      return;
                    }
                    model.updateTopSubjectRevenue(
                        item.subjectParentName ?? 'Unknown', columnIndex);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border(
                      bottom: BorderSide(
                        color: theme.colorScheme.onSurface.withOpacity(0.2),
                        width: 1.0,
                      ),
                    )),
                    alignment: columnIndex == 0
                        ? Alignment.centerLeft
                        : Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      text,
                      textAlign: textAlign,
                      style: TextStyle(fontSize: isMobile ? 12 : 14),
                      overflow: TextOverflow.visible,
                      softWrap: true,
                    ),
                  ),
                ),
              );
            });
          },
        );
      },
    );
  }
}
