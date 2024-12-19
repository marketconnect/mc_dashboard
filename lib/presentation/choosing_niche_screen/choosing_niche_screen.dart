import 'package:flutter/material.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:mc_dashboard/core/utils/colors.dart';
import 'package:mc_dashboard/core/utils/strings_ext.dart';
import 'package:pie_chart/pie_chart.dart' as pie_chart;
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:mc_dashboard/presentation/choosing_niche_screen/choosing_niche_view_model.dart';

class ChoosingNicheScreen extends StatelessWidget {
  const ChoosingNicheScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final surfaceContainerHighest =
        Theme.of(context).colorScheme.surfaceContainerHighest;
    final model = context.watch<ChoosingNicheViewModel>();
    final toggleExpandedContainer = model.toggleExpandedContainer;
    final expandedContainer = model.expandedContainer;
    final isFilterVisible = model.isFilterVisible;
    final selectedParentName = model.selectedParentName;
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final maxHeight = constraints.maxHeight;
          final isMobileOrLaptop = maxWidth < 900 || maxHeight < 690;

          if (isMobileOrLaptop) {
            // Mobile and Laptop ///////////////////////////////////////////////
            return SingleChildScrollView(
              controller: ScrollController(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: constraints.maxHeight * 0.3, // Height for graph
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: PieChartWidget(maxWidth: maxWidth),
                  ),
                  Container(
                    height: constraints.maxHeight * 0.3, // Height for bar
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const BarChartWidget(isMedianPrice: true),
                  ),
                  Container(
                    height: constraints.maxHeight * 0.3, // Height for bar
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const BarChartWidget(isMedianPrice: false),
                  ),
                  if (isFilterVisible) _buildFiltersWidget(context),
                  Container(
                    height: constraints.maxHeight * 0.6, // Height for table
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const TableWidget(),
                  ),
                ],
              ),
            );
          }

          // Desktop //////////////////////////////////////////////////////////
          return Column(
            children: [
              if (!isFilterVisible)
                Flexible(
                  flex: 1,
                  child: Row(
                    children: [
                      if (!expandedContainer)
                        Flexible(
                          flex: 1,
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
                      Flexible(
                        flex: 1,
                        child: Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.all(8.0),
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: (selectedParentName == null)
                                  ? const Center(child: Text("Не выбрано"))
                                  : Column(
                                      children: [
                                        Flexible(
                                            flex: 1,
                                            child: const BarChartWidget(
                                                isMedianPrice: true)),
                                        Flexible(
                                            flex: 1,
                                            child: const BarChartWidget(
                                                isMedianPrice: false)),
                                      ],
                                    ),
                            ),
                            if (selectedParentName != null)
                              Positioned(
                                top: 16,
                                right: 16,
                                child: IconButton(
                                  onPressed: () => toggleExpandedContainer(),
                                  icon: expandedContainer
                                      ? const Icon(Icons.close)
                                      : const Icon(Icons.fullscreen),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (isFilterVisible && !expandedContainer)
                _buildFiltersWidget(context),
              if (!expandedContainer)
                Flexible(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const TableWidget(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFiltersWidget(BuildContext context) {
    final model = context.watch<ChoosingNicheViewModel>();
    final theme = Theme.of(context);
    final textStyle = TextStyle(
      fontSize: theme.textTheme.bodyMedium!.fontSize,
      color: theme.colorScheme.onSurface,
    );
    final labelStyle = TextStyle(
      fontSize: theme.textTheme.bodyMedium!.fontSize,
    );

    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Фильтры",
                style: TextStyle(
                  fontSize: theme.textTheme.titleLarge!.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                  onPressed: () => model.toggleFilterVisibility(),
                  icon: Icon(Icons.close))
            ],
          ),
          const SizedBox(height: 16.0),

          ...model.filters.map((filter) {
            final controllers = model.filterControllers[filter]!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(filter, style: labelStyle),
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controllers["min"],
                          keyboardType: TextInputType.number,
                          style: textStyle,
                          decoration: const InputDecoration(
                            labelText: "Мин",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 8.0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: TextField(
                          controller: controllers["max"],
                          keyboardType: TextInputType.number,
                          style: textStyle,
                          decoration: const InputDecoration(
                            labelText: "Макс",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 8.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16.0),
          // Кнопки действий
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  model.clearFilterControllers();
                },
                child: const Text("Сбросить"),
              ),
              ElevatedButton(
                onPressed: () {
                  _applyFilters(model);
                },
                child: const Text("Применить"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _applyFilters(ChoosingNicheViewModel model) {
    final ctrls = model.filterControllers;

    model.filterData(
      minTotalRevenue: _parseInt(ctrls["Выручка (₽)"]!["min"]!.text),
      maxTotalRevenue: _parseInt(ctrls["Выручка (₽)"]!["max"]!.text),
      minTotalOrders: _parseInt(ctrls["Кол-во заказов"]!["min"]!.text),
      maxTotalOrders: _parseInt(ctrls["Кол-во заказов"]!["max"]!.text),
      minTotalSkus: _parseInt(ctrls["Товары"]!["min"]!.text),
      maxTotalSkus: _parseInt(ctrls["Товары"]!["max"]!.text),
      minMedianPrice: _parseInt(ctrls["Медианная цена (₽)"]!["min"]!.text),
      maxMedianPrice: _parseInt(ctrls["Медианная цена (₽)"]!["max"]!.text),
      minSkusWithOrders:
          _parseInt(ctrls["Процент тов. с заказами"]!["min"]!.text),
      maxSkusWithOrders:
          _parseInt(ctrls["Процент тов. с заказами"]!["max"]!.text),
    );
  }

  int? _parseInt(String value) => int.tryParse(value.isEmpty ? '' : value);
}

// Filter widget ///////////////////////////////////////////////////////////////

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
    final selectedMetric = model.metric;
    final theme = Theme.of(context);
    final colorList = generateColorList(model.currentDataMap.keys.length);
    // final header = model.diagramHeader;
    return Row(
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
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              if (model.selectedParentName != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 8.0, left: 8.0, right: 8.0),
                                  child: _buildMetricSelector(theme, model),
                                ),
                              Expanded(
                                child: pie_chart.PieChart(
                                  dataMap: model.currentDataMap,
                                  animationDuration:
                                      const Duration(milliseconds: 800),
                                  chartValuesOptions:
                                      const pie_chart.ChartValuesOptions(
                                    showChartValuesInPercentage: true,
                                  ),
                                  colorList: colorList,
                                  legendOptions: const pie_chart.LegendOptions(
                                    showLegends: false,
                                  ),
                                ),
                              ),
                            ],
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
                                  '$selectedParentName (ТОП-30)',
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
                                                  '$key: ${value.toStringAsFixed(0).formatWithThousands()} ${selectedMetric.$2}',
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

  Widget _buildMetricSelector(ThemeData theme, ChoosingNicheViewModel model) {
    final selectedMetric = model.metric;
    final metrics = model.metrics;
    final updateMetric = model.updateModelMetric;
    return LayoutBuilder(builder: (context, constraints) {
      return DropdownButton<String>(
        menuWidth: constraints.maxWidth * 0.4,
        value: selectedMetric.$1,
        items: metrics
            .map((m) => DropdownMenuItem(
                value: m,
                child: SizedBox(
                    width: constraints.maxWidth * 0.3,
                    child: Text(m,
                        style:
                            TextStyle(fontSize: constraints.maxWidth * 0.03)))))
            .toList(),
        onChanged: (value) {
          if (value != null) {
            updateMetric(value);
          }
        },
      );
    });
  }
} // PieChartWidget widget /////////////////////////////////////////////////////

class TableWidget extends StatefulWidget {
  const TableWidget({
    super.key,
  });

  @override
  State<TableWidget> createState() => _TableWidgetState();
}

class _TableWidgetState extends State<TableWidget> {
  late TableViewController tableViewController;

  // since the TableWidget destroys and re-creates when a screen dimension changes,
  // we need to re-initialize the TableViewController
  @override
  void initState() {
    super.initState();
    tableViewController = TableViewController();
    final model = context.read<ChoosingNicheViewModel>();
    model.setTableViewController(tableViewController);

    // Scroll to a clicked subject in the expanded CharBarWidget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final subjectName = model.scrollToSubjectNameValue;
      if (subjectName != null) {
        model.scrollToSubjectName(subjectName);
        model.resetScrollToSubjectNameValue(); // Очистка значения
      }
    });
  }

  void scrollToSubjectName() {
    final model = context.read<ChoosingNicheViewModel>();
    final subjectName = model.scrollToSubjectNameValue;
    if (subjectName == null) return;
    model.scrollToSubjectName(subjectName);
  }

  @override
  void dispose() {
    tableViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ChoosingNicheViewModel>();
    final subjectsSummary = model.subjectsSummary;
    final sortData = model.sortData;
    final sortColumnIndex = model.sortColumnIndex;
    final isAscending = model.isAscending;
    final theme = Theme.of(context);
    final toggleFilterVisibility = model.toggleFilterVisibility;
    final onNavigateToSubjectProducts = model.onNavigateToSubjectProducts;
    return LayoutBuilder(builder: (context, constraints) {
      final maxWidth = constraints.maxWidth;
      final maxHeight = constraints.maxHeight;
      final isMobile = maxWidth < 600 && maxHeight < 690;
      final isMobileOrLaptop = maxWidth < 900 && maxHeight < 690;
      final mobileMinColumnWidths = [100.0, 80.0, 80.0, 80.0, 80.0, 80.0, 80.0];

      final columnProportions = [
        0.2,
        0.12,
        0.12,
        0.12,
        0.12,
        0.12,
        0.12,
      ];

      final columnWidths = isMobile
          ? mobileMinColumnWidths
          : columnProportions.map((p) => p * maxWidth).toList();

      final columns = <TableColumn>[
        TableColumn(width: columnWidths[0]),
        TableColumn(width: columnWidths[1]),
        TableColumn(width: columnWidths[2]),
        TableColumn(width: columnWidths[3]),
        TableColumn(width: columnWidths[4]),
        TableColumn(width: columnWidths[5]),
        TableColumn(width: columnWidths[6]),
      ];

      return Stack(children: [
        Positioned.fill(
            child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 16.0),
                    Text(
                      model.tableHeaderText,
                      style: theme.textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    toggleFilterVisibility();
                  },
                  child: Text(
                    "Фильтры",
                    style: TextStyle(
                      fontSize: theme.textTheme.bodyMedium!.fontSize,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            if (model.isSearchVisible)
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxWidth: 400), // Ограничение ширины
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Поиск по предметам',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              model.toggleSearchVisibility();
                            },
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          model.setSearchQuery(value);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            Expanded(
              child: Container(
                // margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TableView.builder(
                  controller: tableViewController,
                  columns: columns,
                  rowHeight: model.tableRowHeight,
                  rowCount: subjectsSummary.length,
                  headerBuilder: (context, contentBuilder) {
                    // Header builder //////////////////////////////////////////
                    scrollToSubjectName();
                    return contentBuilder(context, (context, columnIndex) {
                      final headers = [
                        "Предметы",
                        "Выручка (₽)",
                        "Товары",
                        "Кол-во заказов",
                        "Медианная цена (₽)",
                        "Товары с заказами",
                        "Детали",
                      ];
                      final alignment = columnIndex == 0
                          ? Alignment.centerLeft
                          : Alignment.center;

                      return GestureDetector(
                        onTap: () {
                          if (columnIndex == 6) {
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
                                child: columnIndex == 0
                                    ? Row(
                                        children: [
                                          Text(
                                            headers[columnIndex],
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: theme.textTheme
                                                  .bodyMedium!.fontSize,
                                              color:
                                                  theme.colorScheme.onSurface,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            softWrap: true,
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              model.isSearchVisible
                                                  ? null
                                                  : Icons.search,
                                              color:
                                                  theme.colorScheme.onSurface,
                                              size: theme.textTheme.bodyMedium!
                                                  .fontSize,
                                            ),
                                            onPressed: () {
                                              model.toggleSearchVisibility();
                                            },
                                          ),
                                        ],
                                      )
                                    : Text(
                                        headers[columnIndex],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: theme
                                              .textTheme.bodyMedium!.fontSize,
                                          color: theme.colorScheme.onSurface,
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
                                    size: theme.textTheme.bodyMedium!.fontSize,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    });
                  },
                  rowBuilder: (context, rowIndex, contentBuilder) {
                    // Row builder /////////////////////////////////////////////
                    final item = subjectsSummary[rowIndex];
                    return contentBuilder(context, (context, columnIndex) {
                      TextAlign textAlign =
                          columnIndex == 0 ? TextAlign.left : TextAlign.center;
                      String text;
                      switch (columnIndex) {
                        case 0:
                          text =
                              '${item.subjectParentName ?? ''}/${item.subjectName}';
                          break;
                        case 1:
                          text = item.totalRevenue
                              .toString()
                              .formatWithThousands();
                          break;
                        case 2:
                          text =
                              item.totalSkus.toString().formatWithThousands();

                          break;
                        case 3:
                          text =
                              item.totalOrders.toString().formatWithThousands();

                          break;
                        case 4:
                          text =
                              item.medianPrice.toString().formatWithThousands();
                          break;
                        case 5:
                          text =
                              '${item.skusWithOrders.toString().formatWithThousands()} шт. (${(item.skusWithOrders / item.totalSkus * 100.0).toStringAsFixed(0)}%)';

                          break;
                        default:
                          text = '';
                      }
                      return MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            if (columnIndex == 6) {
                              onNavigateToSubjectProducts(
                                  item.subjectId, item.subjectName);
                              return;
                            }
                            model.updateTopSubjectValue(
                                item.subjectParentName ?? 'Unknown',
                                columnIndex);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border(
                              bottom: BorderSide(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.2),
                                width: 1.0,
                              ),
                            )),
                            alignment: columnIndex == 0
                                ? Alignment.centerLeft
                                : Alignment.center,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: columnIndex != 6
                                ? Text(
                                    text,
                                    textAlign: textAlign,
                                    style: TextStyle(
                                        fontSize: theme
                                            .textTheme.bodyMedium!.fontSize,
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.visible,
                                    softWrap: true,
                                  )
                                : Container(
                                    alignment: Alignment.center,
                                    width: isMobileOrLaptop
                                        ? columns[6].width * 0.7
                                        : columns[6].width * 0.35,
                                    height: isMobileOrLaptop
                                        ? columns[6].width * 0.3
                                        : columns[6].width * 0.15,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4.0),
                                      border: Border.all(
                                        color: theme.colorScheme.primary,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Text(
                                      'Перейти',
                                      style: TextStyle(
                                          // fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.primary,
                                          fontSize: isMobileOrLaptop
                                              ? columns[6].width * 0.12
                                              : columns[6].width * 0.06),
                                    ),
                                  ),
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),
            ),
          ],
        ))
      ]);
    });
  }
}

// TODO add mouse hover cursor
class BarChartWidget extends StatelessWidget {
  const BarChartWidget({super.key, required this.isMedianPrice});

  final bool isMedianPrice;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ChoosingNicheViewModel>();
    final scrollToSubjectName = model.scrollToSubjectName;
    final selectedParentName = model.selectedParentName;
    final theme = Theme.of(context);

    final filtered = model.subjectsSummary
        .where((item) => item.subjectParentName == model.selectedParentName)
        .toList();
    if (filtered.isEmpty) {
      return const Center(child: Text("Нет данных"));
    }

    final values = filtered.map((e) {
      if (isMedianPrice) {
        return e.medianPrice.toDouble();
      }
      final skusWithOrdersPercent = e.totalSkus > 0
          ? ((e.skusWithOrders / e.totalSkus) * 100).round()
          : 0.0;
      return skusWithOrdersPercent.toDouble();
    }).toList();
    if (values.isEmpty) {
      return const Center(child: Text("Нет данных"));
    }

    final barSpots = <BarChartGroupData>[];
    for (int i = 0; i < values.length; i++) {
      barSpots.add(
        BarChartGroupData(
          x: i,
          barsSpace: 2,
          barRods: [
            BarChartRodData(
              toY: values[i],
              color: isMedianPrice
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
              width: 10,
            )
          ],
        ),
      );
    }

    return Column(
      children: [
        if (isMedianPrice)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "$selectedParentName",
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        if (isMedianPrice)
          Text(
            "Медианная цена (₽)",
            style: const TextStyle(
              fontSize: 12.0,
            ),
          ),
        const SizedBox(height: 50.0),
        Expanded(
          child: BarChart(
            BarChartData(
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              barGroups: barSpots,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final value = rod.toY;
                  final index = groupIndex;
                  String subjectName = "";
                  if (index < filtered.length) {
                    subjectName = filtered[index].subjectName;
                  }
                  return BarTooltipItem(
                    isMedianPrice
                        ? "$subjectName\n$value ₽"
                        : "$subjectName\n$value%",
                    const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }),
                touchCallback:
                    (FlTouchEvent event, BarTouchResponse? response) {
                  if (event is FlTapUpEvent &&
                      response != null &&
                      response.spot != null) {
                    final index = response.spot!.touchedBarGroupIndex;
                    if (index < filtered.length) {
                      final subjectName = filtered[index].subjectName;
                      scrollToSubjectName(subjectName);
                    }
                  }
                },
              ),
            ),
          ),
        ),
        if (!isMedianPrice)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Процент товаров с заказами",
              style: const TextStyle(
                fontSize: 12.0,
              ),
            ),
          ),
      ],
    );
  }
}
