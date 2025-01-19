import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_table_view/material_table_view.dart';

import 'package:mc_dashboard/core/utils/colors.dart';
import 'package:mc_dashboard/core/utils/dates.dart';
import 'package:mc_dashboard/core/utils/strings_ext.dart';
import 'package:mc_dashboard/theme/color_schemes.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:pie_chart/pie_chart.dart' as pie_chart;
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:mc_dashboard/presentation/choosing_niche_screen/choosing_niche_view_model.dart';
import 'package:shimmer/shimmer.dart';

class ChoosingNicheScreen extends StatelessWidget {
  const ChoosingNicheScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final surfaceContainerHighest =
        Theme.of(context).colorScheme.surfaceContainerHighest;
    final model = context.watch<ChoosingNicheViewModel>();
    final theme = Theme.of(context);
    final isLoading = model.loading;
    final toggleExpandedContainer = model.toggleExpandedContainer;
    final expandedContainer = model.expandedContainer;
    final isFilterVisible = model.isFilterVisible;
    final selectedParentName = model.selectedParentName;
    final selectedSubjectName = model.selectedSubjectName;
    return Scaffold(
      body: OverlayLoaderWithAppIcon(
        isLoading: isLoading,
        overlayBackgroundColor: Colors.black,
        circularProgressColor: theme.colorScheme.onPrimary,
        appIconSize: 70,
        appIcon: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'M',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: GoogleFonts.alikeAngular().fontFamily,
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'ARKET',
                  style: TextStyle(
                    fontSize: 9,
                    fontFamily: GoogleFonts.waitingForTheSunrise().fontFamily,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Positioned(
              top: 35,
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  'CONNECT',
                  style: TextStyle(
                    fontSize: 9,
                    fontFamily: GoogleFonts.waitingForTheSunrise().fontFamily,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        // Image.asset(ImageConstant.imgFav),
        child: LayoutBuilder(
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
                    if (selectedSubjectName != null)
                      isLoading
                          ? Shimmer(
                              gradient:
                                  Theme.of(context).colorScheme.shimmerGradient,
                              child: Container(
                                height: constraints.maxHeight * 0.4,
                                width: double.infinity,
                                margin: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            )
                          : Container(
                              height: constraints.maxHeight * 0.4,
                              margin: const EdgeInsets.all(8.0),
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: const HistoryChartWidget(),
                            ),
                    isLoading
                        ? Shimmer(
                            gradient:
                                Theme.of(context).colorScheme.shimmerGradient,
                            child: Container(
                              height: constraints.maxHeight * 0.8,
                              margin: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          )
                        : Container(
                            height: constraints.maxHeight, // Height for graph
                            margin: const EdgeInsets.all(8.0),
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: PieChartWidget(
                                isMobileOrLaptop: isMobileOrLaptop,
                                maxWidth: maxWidth),
                          ),
                    if (isFilterVisible)
                      _buildFiltersWidget(context, isMobileOrLaptop),
                    isLoading
                        ? Shimmer(
                            gradient:
                                Theme.of(context).colorScheme.shimmerGradient,
                            child: Container(
                              height: constraints.maxHeight, //
                              width: double.infinity,
                              margin: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          )
                        : Container(
                            height: constraints.maxHeight, // Height for table
                            margin: const EdgeInsets.all(8.0),
                            padding: const EdgeInsets.all(2.0),
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
                            child: isLoading
                                ? Shimmer(
                                    gradient: Theme.of(context)
                                        .colorScheme
                                        .shimmerGradient,
                                    child: Container(
                                      margin: const EdgeInsets.all(16.0),
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  )
                                : Container(
                                    margin: const EdgeInsets.all(8.0),
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: PieChartWidget(
                                        isMobileOrLaptop: isMobileOrLaptop,
                                        maxWidth: maxWidth),
                                  ),
                          ),
                        Flexible(
                          flex: 1,
                          child: Stack(
                            children: [
                              isLoading
                                  ? Shimmer(
                                      gradient: Theme.of(context)
                                          .colorScheme
                                          .shimmerGradient,
                                      child: Container(
                                        height: constraints.maxHeight * 0.3,
                                        width: double.infinity,
                                        margin: const EdgeInsets.all(16.0),
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      margin: const EdgeInsets.all(8.0),
                                      padding: const EdgeInsets.all(16.0),
                                      decoration: BoxDecoration(
                                        color: surfaceContainerHighest,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: (selectedParentName == null)
                                          ? const Center(
                                              child: Text("Не выбрано"))
                                          : Container(
                                              height: constraints.maxHeight *
                                                  0.3, // Общая высота графика
                                              margin: const EdgeInsets.all(8.0),
                                              // padding: const EdgeInsets.all(16.0),
                                              decoration: BoxDecoration(
                                                color: surfaceContainerHighest,
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              child:
                                                  // const TotalOrdersHistoryChartWidget(),
                                                  const HistoryChartWidget(),
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
                  _buildFiltersWidget(context, isMobileOrLaptop),
                if (!expandedContainer)
                  Flexible(
                    flex: 2,
                    child: isLoading
                        ? Shimmer(
                            gradient:
                                Theme.of(context).colorScheme.shimmerGradient,
                            child: Container(
                              margin: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          )
                        : Container(
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
      ),
    );
  }

  Widget _buildFiltersWidget(BuildContext context, bool isMobileOrLaptop) {
    final model = context.watch<ChoosingNicheViewModel>();
    final theme = Theme.of(context);
    final textStyle = TextStyle(
      fontSize: isMobileOrLaptop
          ? theme.textTheme.bodyLarge!.fontSize
          : theme.textTheme.bodyMedium!.fontSize,
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
  const PieChartWidget(
      {super.key, required this.isMobileOrLaptop, required this.maxWidth});
  final bool isMobileOrLaptop;
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
          ? [_buildError(maxWidth, error)]
          : loading || model.currentDataMap.isEmpty
              ? const [Expanded(child: Center(child: Text('Загрузка...')))]
              : [
                  Expanded(
                    child: isMobileOrLaptop
                        ? Column(children: [
                            _buildChart(model, theme, colorList),
                            _buildList(
                              selectedParentName,
                              theme,
                              model,
                              colorList,
                              isMobileOrLaptop,
                              selectedMetric,
                            ),
                          ])
                        : Row(
                            children: [
                              _buildChart(model, theme, colorList),
                              _buildList(selectedParentName, theme, model,
                                  colorList, isMobileOrLaptop, selectedMetric),
                            ],
                          ),
                  ),
                ],
    );
  }

  Expanded _buildList(
      String selectedParentName,
      ThemeData theme,
      ChoosingNicheViewModel model,
      List<Color> colorList,
      bool isMobileOrLaptop,
      (String, String) selectedMetric) {
    return Expanded(
      flex: 1,
      child: Column(
        crossAxisAlignment: isMobileOrLaptop
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          // Заголовок
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Text(
              '$selectedParentName (ТОП-30)',
              style: TextStyle(
                fontSize: isMobileOrLaptop
                    ? theme.textTheme.bodyLarge!.fontSize
                    : theme.textTheme.bodyMedium!.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Список
          Expanded(
            child: ListView.builder(
              itemCount: model.currentDataMap.keys.length,
              itemBuilder: (context, index) {
                final key = model.currentDataMap.keys.elementAt(index);
                final value = model.currentDataMap[key]!;
                final color = colorList[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: MouseRegion(
                    cursor: model.selectedParentName == null
                        ? SystemMouseCursors.basic
                        : SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => model.scrollToSubjectName(key),
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            margin: const EdgeInsets.only(right: 8.0),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '$key: ${value.toStringAsFixed(0).formatWithThousands()} ${selectedMetric.$2}',
                              style: TextStyle(
                                  fontSize: isMobileOrLaptop
                                      ? theme.textTheme.bodyLarge!.fontSize
                                      : theme.textTheme.bodyMedium!.fontSize),
                              overflow: TextOverflow.ellipsis,
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
    );
  }

  Expanded _buildChart(
      ChoosingNicheViewModel model, ThemeData theme, List<Color> colorList) {
    return Expanded(
      flex: 1,
      child: Column(
        children: [
          if (model.selectedParentName != null)
            Padding(
              padding:
                  const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
              child: _buildMetricSelector(theme, model),
            ),
          Expanded(
            child: pie_chart.PieChart(
              dataMap: model.currentDataMap,
              animationDuration: const Duration(milliseconds: 800),
              chartValuesOptions: const pie_chart.ChartValuesOptions(
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
    );
  }

  Expanded _buildError(double maxWidth, String error) {
    return Expanded(
      child: Center(
        child: SizedBox(
          width: maxWidth * 0.5,
          child: Text(
            error.toString(),
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
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
                      constraints: const BoxConstraints(maxWidth: 400),
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
                                              fontSize: isMobile
                                                  ? theme.textTheme.bodyMedium!
                                                          .fontSize! *
                                                      1.2
                                                  : theme.textTheme.bodyMedium!
                                                      .fontSize,
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
                                item.subjectName,
                                columnIndex);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border(
                              bottom: BorderSide(
                                color: theme.colorScheme.onSurface
                                    .withAlpha((0.2 * 255).toInt()),
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
                                        fontSize: isMobileOrLaptop
                                            ? columns[6].width * 0.12
                                            : theme
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

class TotalOrdersHistoryChartWidget extends StatelessWidget {
  const TotalOrdersHistoryChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ChoosingNicheViewModel>();
    final selectedSubjectName = model.selectedSubjectName;
    // Если ничего не выбрано — показываем заглушку
    if (selectedSubjectName == null) {
      return const Center(child: Text("Не выбрано"));
    }

    // Находим нужный элемент в subjectsSummary
    final item = model.subjectsSummary.where(
      (element) => element.subjectName == selectedSubjectName,
    );

    if (item.isEmpty || item.first.historyData.isEmpty) {
      return const Center(child: Text("Нет исторических данных"));
    }

    // Преобразуем словарь historyData в список точек для графика
    // Ключи "24_52" и т. п. сортируем по возрастанию (чтобы по X шел год-неделя по порядку).

    final sortedHistory = item.first.decodedHistoryData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // Формируем точки для LineChart
    final spots = <FlSpot>[];
    for (int i = 0; i < sortedHistory.length; i++) {
      final totalOrders =
          sortedHistory[i].value["total_orders"]?.toDouble() ?? 0.0;
      spots.add(FlSpot(i.toDouble(), totalOrders));
    }

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                final index = touchedSpot.spotIndex;
                final key = sortedHistory[index].key;
                final value = touchedSpot.y;
                return LineTooltipItem(
                  '$key\n$value заказов',
                  const TextStyle(fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              // Если хотите подписывать ось X год/неделю:
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (index < 0 || index >= sortedHistory.length) {
                  return const SizedBox.shrink();
                }
                final key = sortedHistory[index].key; // "24_52" и т.д.
                return Text(key, style: const TextStyle(fontSize: 10));
              },
              interval: 5, // Разреживаем подписи, можно менять
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            color: Theme.of(context).colorScheme.primary,
            isCurved: true,
            barWidth: 3,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}

class HistoryChartWidget extends StatefulWidget {
  const HistoryChartWidget({super.key});

  @override
  State<HistoryChartWidget> createState() => _HistoryChartWidgetState();
}

class _HistoryChartWidgetState extends State<HistoryChartWidget> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<ChoosingNicheViewModel>();
    final selectedSubjectName = model.selectedSubjectName;
    final theme = Theme.of(context);

    String firstKey = "total_skus";
    String secondKey = "sku_with_orders";

    final selectedMetric = model.historyMetric;

    if (selectedSubjectName == null) {
      return const Center(child: Text("Не выбрано"));
    }

    final items = model.subjectsSummary
        .where((element) => element.subjectName == selectedSubjectName)
        .toList();

    if (items.isEmpty || items.first.historyData.isEmpty) {
      return const Center(child: Text("Нет исторических данных"));
    }

    final subjectItem = items.first;
    final sortedHistory = subjectItem.decodedHistoryData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // Находим максимальное значение для оси Y
    final double maxYValue = sortedHistory
        .map<double>((e) =>
            (e.value[firstKey]?.toDouble() ?? 0) +
            (e.value[secondKey]?.toDouble() ?? 0))
        .reduce((a, b) => a > b ? a : b);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            selectedSubjectName,
            style: TextStyle(fontSize: theme.textTheme.titleMedium!.fontSize),
          ),
          SizedBox(width: 10),
          _buildMetricSelector(theme, model),
          SizedBox(width: 16),
        ]),
        const SizedBox(height: 16),
        Expanded(
          child: LayoutBuilder(builder: (context, constraints) {
            final fullBarWidth = constraints.maxWidth / sortedHistory.length;
            final barsSpace = fullBarWidth * 0.1;

            final barsWidth = fullBarWidth - barsSpace;

            if (selectedMetric == "Заказы" ||
                selectedMetric == "Медианная цена") {
              // Choosen total orders metric ////////////////////////////////////////
              final sortedHistory = items.first.decodedHistoryData.entries
                  .toList()
                ..sort((a, b) => a.key.compareTo(b.key));

              // Формируем точки для LineChart
              final spots = <FlSpot>[];
              for (int i = 0; i < sortedHistory.length; i++) {
                final totalOrders =
                    sortedHistory[i].value["total_orders"]?.toDouble() ?? 0.0;
                spots.add(FlSpot(i.toDouble(), totalOrders));
              }
              return _HistoryLineChart();
            }

            if (selectedMetric == "Кол-во продавцов/брендов") {
              return _DoubleBarChart();
            }

            return BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceEvenly,
                maxY: maxYValue * 1.1,
                groupsSpace: barsSpace,
                barGroups: _generateStackedBarGroups(sortedHistory, barsWidth,
                    firstKey: firstKey, secondKey: secondKey),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final key =
                          weekStringPeriod(sortedHistory[group.x.toInt()].key);
                      final totalSkus = sortedHistory[group.x.toInt()]
                          .value[firstKey]
                          .toDouble();
                      final skuWithOrders = sortedHistory[group.x.toInt()]
                          .value[secondKey]
                          .toDouble();

                      return BarTooltipItem(
                        "$key\nТовары\nВсего: ${totalSkus.toInt()}\nС заказами: ${skuWithOrders.toInt()}",
                        TextStyle(fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 3,
                      getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        if (index % 3 != 0 ||
                            index < 0 ||
                            index >= sortedHistory.length) {
                          return const SizedBox.shrink();
                        }
                        return Transform.rotate(
                          angle: math.pi / 4,
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            weekStringToMondayDate(sortedHistory[index].key),
                            style: const TextStyle(fontSize: 8),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        return Transform.rotate(
                          angle: math.pi / 4,
                          child: Text(formatNumber(value),
                              style: const TextStyle(fontSize: 8)),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: true),
              ),
            );
          }),
        ),
      ],
    );
  }

  String formatNumber(double number) {
    if (number >= 1e9) {
      return "${(number / 1e9).floor()} млрд";
    } else if (number >= 1e6) {
      return "${(number / 1e6).floor()} млн";
    } else if (number >= 1e3) {
      return "${(number / 1e3).floor()} тыс";
    } else {
      return number.floor().toString();
    }
  }

  double getYIntervals(double maxYValue, int intervalsCount) {
    final s = nextHigherOrder(maxYValue.toInt());

    if (s == 0) {
      return 1;
    }

    final p = s / intervalsCount;

    return (p.toInt()).toDouble();
  }

  int nextHigherOrder(int number) {
    if (number <= 0) return 0; // Обработка неотрицательных чисел

    int magnitude = math.pow(10, number.toString().length - 1).toInt();
    return ((number ~/ magnitude) + 1) * magnitude;
  }

  /// Генерация стековых столбцов (Stacked Bar)
  List<BarChartGroupData> _generateStackedBarGroups(
    List<MapEntry<String, dynamic>> sortedHistory,
    double barsWidth, {
    required String firstKey,
    required String secondKey,
  }) {
    final theme = Theme.of(context);
    return List.generate(sortedHistory.length, (index) {
      final data = sortedHistory[index].value;
      final skusWithOrders = (data[secondKey]?.toDouble() ?? 0.0);
      final totalSkus = (data[firstKey]?.toDouble() ?? 0.0);

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: totalSkus,
            rodStackItems: [
              // Нижний сегмент — sku_with_orders
              BarChartRodStackItem(
                0,
                skusWithOrders,
                theme.colorScheme.onPrimary,
              ),
              // Верхний сегмент — оставшиеся total_skus
              BarChartRodStackItem(
                skusWithOrders,
                totalSkus,
                theme.colorScheme.tertiary,
              ),
            ],
            width: barsWidth,
            borderRadius: BorderRadius.zero,
          ),
        ],
      );
    });
  }

  Widget _buildMetricSelector(ThemeData theme, ChoosingNicheViewModel model) {
    final selectedMetric = model.historyMetric;
    final metrics = model.historyMetrics;
    final updateMetric = model.setHistoryMetric;

    return LayoutBuilder(builder: (context, constraints) {
      return SizedBox(
        width: 200,
        child: DropdownButton<String>(
          value: selectedMetric,
          isExpanded: true, // Растягивает кнопку до ширины контейнера
          items: metrics
              .map((m) => DropdownMenuItem(
                    value: m,
                    child: Text(
                      m,
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              updateMetric(value);
            }
          },
        ),
      );
    });
  }
}

class _HistoryLineChart extends StatelessWidget {
  const _HistoryLineChart();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ChoosingNicheViewModel>();
    final selectedSubjectName = model.selectedSubjectName;
    if (selectedSubjectName == null) {
      return const Center(child: Text("Не выбрано"));
    }
    String firstKey = "";
    switch (model.historyMetric) {
      case "Заказы":
        firstKey = "total_orders";
      case "Медианная цена":
        firstKey = "median_price";
      case "Количество товаров":
      default:
        firstKey = "total_skus";
    }

    // Ищем элементы, где subjectName совпадает с нужным
    final items = model.subjectsSummary
        .where((element) => element.subjectName == selectedSubjectName)
        .toList();

    if (items.isEmpty || items.first.historyData.isEmpty) {
      return const Center(child: Text("Нет исторических данных"));
    }
    final sortedHistory = items.first.decodedHistoryData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // Формируем точки для LineChart
    final spots = <FlSpot>[];
    for (int i = 0; i < sortedHistory.length; i++) {
      final totalOrders = firstKey == "median_price"
          ? sortedHistory[i].value[firstKey]?.toDouble() / 100 ?? 0.0
          : sortedHistory[i].value[firstKey]?.toDouble() ?? 0.0;
      spots.add(FlSpot(i.toDouble(), totalOrders));
    }
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                final index = touchedSpot.spotIndex;
                final key = weekStringPeriod(sortedHistory[index].key);
                final value = touchedSpot.y;
                return LineTooltipItem(
                  '$key\n$value ${model.historyMetric == "Заказы" ? 'заказов' : '₽'}',
                  const TextStyle(fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              // Если хотите подписывать ось X год/неделю:
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (index < 0 || index >= sortedHistory.length) {
                  return const SizedBox.shrink();
                }
                final key = weekStringToMondayDate(
                    sortedHistory[index].key); // "24_52" и т.д.
                return Text(key, style: const TextStyle(fontSize: 10));
              },
              interval: 5, // Разреживаем подписи, можно менять
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            color: model.historyMetric == "Заказы"
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.tertiary,
            isCurved: true,
            barWidth: 3,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}

class _DoubleBarChart extends StatelessWidget {
  const _DoubleBarChart();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ChoosingNicheViewModel>();
    final selectedSubjectName = model.selectedSubjectName;

    // Определяем, какие ключи будем показывать
    String firstKey = "total_suppliers";
    String secondKey = "total_brands";

    if (selectedSubjectName == null) {
      return const Center(child: Text("Не выбрано"));
    }

    // Получаем нужный предмет
    final items = model.subjectsSummary
        .where((element) => element.subjectName == selectedSubjectName)
        .toList();

    if (items.isEmpty || items.first.historyData.isEmpty) {
      return const Center(child: Text("Нет исторических данных"));
    }

    final subjectItem = items.first;

    // Сортируем historyData
    final sortedHistory = subjectItem.decodedHistoryData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // Считаем максимальное значение (для оси Y)
    final double maxYValue = sortedHistory
        .map<double>((e) =>
            (e.value[firstKey]?.toDouble() ?? 0) +
            (e.value[secondKey]?.toDouble() ?? 0))
        .reduce((a, b) => a > b ? a : b);

    // Ограничиваем по высоте, либо AspectRatio, либо LayoutBuilder
    return SizedBox(
      height: 300, // Пример фиксированной высоты
      child: LayoutBuilder(
        builder: (context, constraints) {
          final groupsCount = sortedHistory.length;
          final totalSpaces =
              groupsCount * 2; // Каждой группе дадим ~20px на отступ
          final workableWidth = constraints.maxWidth - totalSpaces;
          // У нас 2 столбца на группу
          final barWidth = (workableWidth / (groupsCount * 2)).clamp(2, 50);

          return BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceEvenly,
              maxY: maxYValue * 1.1,
              groupsSpace: 0, // Отступ между группами
              barGroups: _generateGroupedBarGroups(
                sortedHistory,
                barWidth.toDouble(),
                firstKey: firstKey,
                secondKey: secondKey,
              ),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final key = weekStringPeriod(
                      sortedHistory[group.x.toInt()].key,
                    );

                    final totalValue = sortedHistory[group.x.toInt()]
                            .value[rodIndex == 0 ? firstKey : secondKey]
                            ?.toDouble() ??
                        0.0;

                    final label = rodIndex == 0 ? "Продавцов" : "Брендов";

                    return BarTooltipItem(
                      "$key\n$label: $totalValue",
                      const TextStyle(fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 3,
                    getTitlesWidget: (value, _) {
                      final index = value.toInt();
                      if (index % 3 != 0 ||
                          index < 0 ||
                          index >= sortedHistory.length) {
                        return const SizedBox.shrink();
                      }
                      return Transform.rotate(
                        angle: math.pi / 4,
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          weekStringToMondayDate(sortedHistory[index].key),
                          style: const TextStyle(fontSize: 8),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      return Transform.rotate(
                        angle: math.pi / 4,
                        child: Text(
                          value.toStringAsFixed(0),
                          style: const TextStyle(fontSize: 8),
                        ),
                      );
                    },
                  ),
                ),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: true),
            ),
          );
        },
      ),
    );
  }

  /// Генерация группы из двух столбцов side-by-side (не stack).
  List<BarChartGroupData> _generateGroupedBarGroups(
    List<MapEntry<String, dynamic>> sortedHistory,
    double barWidth, {
    required String firstKey,
    required String secondKey,
  }) {
    return List.generate(sortedHistory.length, (index) {
      final data = sortedHistory[index].value;
      final firstVal = (data[firstKey]?.toDouble() ?? 0.0);
      final secondVal = (data[secondKey]?.toDouble() ?? 0.0);

      return BarChartGroupData(
        x: index,
        barsSpace: 0,
        // groupVertically: true,
        barRods: [
          // Первый столбик
          BarChartRodData(
            toY: firstVal,
            width: barWidth,
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(2),
          ),
          // Второй столбик
          BarChartRodData(
            toY: secondVal,
            width: barWidth,
            color: Colors.greenAccent,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      );
    });
  }
}
