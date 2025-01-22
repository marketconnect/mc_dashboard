import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:material_table_view/material_table_view.dart';

import 'package:mc_dashboard/core/utils/basket_num.dart';
import 'package:mc_dashboard/core/utils/strings_ext.dart';
import 'package:mc_dashboard/presentation/widgets/check_box.dart';
import 'package:mc_dashboard/theme/color_schemes.dart';
import 'package:provider/provider.dart';
import 'package:mc_dashboard/presentation/subject_products_screen/subject_products_view_model.dart';

import 'package:pie_chart/pie_chart.dart' as pie_chart;
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class SubjectProductsScreen extends StatefulWidget {
  const SubjectProductsScreen({super.key});

  @override
  State<SubjectProductsScreen> createState() => _SubjectProductsScreenState();
}

class _SubjectProductsScreenState extends State<SubjectProductsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showBackFAB = false;
  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      setState(() {
        _showBackFAB = _scrollController.offset > 300;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SubjectProductsViewModel>();
    final onNavigateBack = model.onNavigateBack;
    final isFilterVisible = model.isFilterVisible;
    final theme = Theme.of(context);
    final surfaceContainerHighest = theme.colorScheme.surfaceContainerHighest;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final maxHeight = constraints.maxHeight;
          final isMobileOrLaptop = maxWidth < 900 || maxHeight < 690;

          final clearSellerBrandFilter = model.clearSellerBrandFilter;
          final isFilteredBySeller = model.filteredSeller != null;
          final isFilteredByBrand = model.filteredBrand != null;
          if (isMobileOrLaptop) {
            // Mobile and Laptop ///////////////////////////////////////////////
            return Stack(
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!model.loading) _Header(),
                      model.loading
                          ? Shimmer(
                              gradient:
                                  Theme.of(context).colorScheme.shimmerGradient,
                              child: Container(
                                height: constraints.maxHeight * 0.8,
                                width: double.infinity,
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
                              padding: const EdgeInsets.all(2.0),
                              decoration: BoxDecoration(
                                color: surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: _PieChartWithList(
                                isClearButtonVisible: isFilteredBySeller,
                                dataMap: model.sellersDataMap,
                                title: "Продавцы (ТОП-30)",
                                onTapValue: model.filterBySeller,
                                clearFilter: clearSellerBrandFilter,
                                isMobile: isMobileOrLaptop,
                                maxWidth: maxWidth,
                              ),
                            ),
                      model.loading
                          ? Shimmer(
                              gradient:
                                  Theme.of(context).colorScheme.shimmerGradient,
                              child: Container(
                                height: constraints.maxHeight * 0.8,
                                width: double.infinity,
                                margin: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            )
                          : Container(
                              height: constraints.maxHeight, // Height for bar
                              margin: const EdgeInsets.all(8.0),
                              padding: const EdgeInsets.all(2.0),
                              decoration: BoxDecoration(
                                color: surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: _PieChartWithList(
                                isClearButtonVisible: isFilteredByBrand,
                                title: "Бренды (ТОП-30)",
                                onTapValue: model.filterByBrand,
                                dataMap: model.brandsDataMap,
                                clearFilter: clearSellerBrandFilter,
                                isMobile: isMobileOrLaptop,
                                maxWidth: maxWidth,
                              ),
                            ),
                      if (isFilterVisible)
                        _buildFiltersWidget(context, isMobileOrLaptop),
                      model.loading
                          ? Shimmer(
                              gradient:
                                  Theme.of(context).colorScheme.shimmerGradient,
                              child: Container(
                                height:
                                    constraints.maxHeight, // Height for table
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
                              padding: isMobileOrLaptop
                                  ? null
                                  : const EdgeInsets.all(2.0),
                              decoration: BoxDecoration(
                                color: surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: const _TableWidget(),
                            ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 8,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _showBackFAB
                        ? FloatingActionButton(
                            key: const ValueKey('backFab'),
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            highlightElevation: 0,
                            hoverElevation: 0,
                            focusElevation: 0,
                            splashColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            foregroundColor: Colors.black,
                            shape: const CircleBorder(),
                            onPressed: onNavigateBack,
                            child: const Icon(Icons.arrow_back_ios),
                          )
                        : const SizedBox.shrink(),
                  ),
                )
              ],
            );
          }

          // Desktop //////////////////////////////////////////////////////////
          return Column(
            children: [
              if (!model.loading) _Header(),
              if (!isFilterVisible)
                Flexible(
                  flex: 1,
                  child: Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: model.loading
                            ? Shimmer(
                                gradient: Theme.of(context)
                                    .colorScheme
                                    .shimmerGradient,
                                child: Container(
                                  width: double.infinity,
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
                                child: _PieChartWithList(
                                  isClearButtonVisible: isFilteredBySeller,
                                  dataMap: model.sellersDataMap,
                                  title: "Продавцы (ТОП-30)",
                                  onTapValue: model.filterBySeller,
                                  clearFilter: clearSellerBrandFilter,
                                  isMobile: isMobileOrLaptop,
                                  maxWidth: maxWidth,
                                ),
                              ),
                      ),
                      Flexible(
                        flex: 1,
                        child: model.loading
                            ? Shimmer(
                                gradient: Theme.of(context)
                                    .colorScheme
                                    .shimmerGradient,
                                child: Container(
                                  width: double.infinity,
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
                                child: Column(
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      child: _PieChartWithList(
                                        isClearButtonVisible: isFilteredByBrand,
                                        title: "Бренды (ТОП-30)",
                                        onTapValue: model.filterByBrand,
                                        dataMap: model.brandsDataMap,
                                        clearFilter: clearSellerBrandFilter,
                                        isMobile: isMobileOrLaptop,
                                        maxWidth: maxWidth,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              if (isFilterVisible)
                _buildFiltersWidget(context, isMobileOrLaptop),
              Flexible(
                flex: 2,
                child: model.loading
                    ? Shimmer(
                        gradient: Theme.of(context).colorScheme.shimmerGradient,
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
                        child: const _TableWidget(),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFiltersWidget(BuildContext context, bool isMobileOrLaptop) {
    final model = context.watch<SubjectProductsViewModel>();
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

  void _applyFilters(SubjectProductsViewModel model) {
    final ctrls = model.filterControllers;
    model.filterData(
      minRevenue: _parseInt(ctrls["Выручка (₽)"]!["min"]!.text),
      maxRevenue: _parseInt(ctrls["Выручка (₽)"]!["max"]!.text),
      minOrders: _parseInt(ctrls["Кол-во заказов"]!["min"]!.text),
      maxOrders: _parseInt(ctrls["Кол-во заказов"]!["max"]!.text),
      minPrice: _parseInt(ctrls["Цена со скидкой (₽)"]!["min"]!.text),
      maxPrice: _parseInt(ctrls["Цена со скидкой (₽)"]!["max"]!.text),
    );
  }

  int? _parseInt(String value) => int.tryParse(value.isEmpty ? '' : value);
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SubjectProductsViewModel>();
    final onNavigateBack = model.onNavigateBack;
    final onNavigateToEmptySubject = model.onNavigateToEmptySubject;
    final String subjectName = model.subjectName;
    final ThemeData theme = Theme.of(context);
    final bool isFbs = model.isFbs;
    final Future<void> Function() switchToFbs = model.switchToFbs;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: IconButton(
                onPressed: () => onNavigateBack(),
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: theme.colorScheme.primary,
                )),
          ),
          Text(subjectName,
              style: TextStyle(
                fontSize: theme.textTheme.titleLarge!.fontSize,
                fontWeight: FontWeight.bold,
              )),
          Transform.scale(
            scale: 0.5,
            child: Switch(
              value: isFbs,
              onChanged: (isFbs) => switchToFbs(),
              activeColor: theme.colorScheme.primary,
              inactiveThumbColor: theme.colorScheme.primaryContainer,
            ),
          ),
          Text(
            isFbs ? 'FBS' : 'FBW',
            style: theme.textTheme.bodySmall,
          )
        ]),
        IconButton(
          onPressed: () => onNavigateToEmptySubject(),
          icon: Icon(Icons.search_sharp, size: 24),
          color: theme.colorScheme.primary,
        ),
      ],
    );
  }
}

class _PieChartWithList extends StatelessWidget {
  final Map<String, double> dataMap;
  final String title;
  final bool isClearButtonVisible;
  final void Function() clearFilter;
  final void Function(String) onTapValue;
  final double maxWidth;
  final bool isMobile;
  const _PieChartWithList({
    required this.title,
    required this.dataMap,
    this.isClearButtonVisible = false,
    required this.clearFilter,
    required this.onTapValue,
    required this.maxWidth,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (dataMap.isEmpty) {
      return const Center(child: Text("Загрузка данных..."));
    }

    final colorList = _generateColorList(dataMap.length);

    return LayoutBuilder(builder: (context, constraints) {
      // final maxHeight = constraints.maxHeight;

      return Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: isMobile
                ? Column(children: [
                    _buildChart(
                      colorList,
                    ),
                    _buildList(theme, colorList, isMobile: true),
                  ])
                : Row(
                    children: [
                      _buildChart(colorList),
                      _buildList(theme, colorList),
                    ],
                  ),
          ),
          if (isClearButtonVisible)
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                onPressed: () => clearFilter(),
                icon: Icon(Icons.filter_alt_off_outlined,
                    color: theme.colorScheme.primary, size: 18),
              ),
            ),
        ],
      );
    });
  }

  Expanded _buildList(ThemeData theme, List<Color> colorList,
      {bool isMobile = false}) {
    return Expanded(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile
                  ? theme.textTheme.bodyLarge!.fontSize
                  : theme.textTheme.bodyMedium!.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: dataMap.keys.length,
              itemBuilder: (context, index) {
                final key = dataMap.keys.elementAt(index);
                final value = dataMap[key]!;
                final color = colorList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => onTapValue(key),
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
                              '$key: ${value.toStringAsFixed(0).formatWithThousands()} ₽',
                              style: TextStyle(
                                  fontSize: isMobile
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

  Expanded _buildChart(List<Color> colorList) {
    return Expanded(
      flex: 2,
      child: pie_chart.PieChart(
        dataMap: dataMap,
        animationDuration: const Duration(milliseconds: 800),
        chartValuesOptions: const pie_chart.ChartValuesOptions(
          showChartValuesInPercentage: true,
        ),
        colorList: colorList,
        legendOptions: const pie_chart.LegendOptions(
          showLegends: false,
        ),
      ),
    );
  }

  List<Color> _generateColorList(int length) {
    final colors = <Color>[];
    for (int i = 0; i < length; i++) {
      colors.add(Colors.primaries[i % Colors.primaries.length]);
    }
    return colors;
  }
}

// TODO Align the supplier column content

class _TableWidget extends StatefulWidget {
  const _TableWidget();

  @override
  State<_TableWidget> createState() => _TableWidgetState();
}

class _TableWidgetState extends State<_TableWidget> {
  final tableViewController = TableViewController();

  @override
  void dispose() {
    tableViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SubjectProductsViewModel>();
    final selectedRows = model.selectedRows;
    final selectRow = model.selectRow;
    final detailedOrders = model.detailedOrders;
    final sortData = model.sortData;
    final sortColumnIndex = model.sortColumnIndex;
    final isAscending = model.isAscending;
    final theme = Theme.of(context);
    final toggleFilterVisibility = model.toggleFilterVisibility;
    final navigateToProduct = model.onNavigateToProductScreen;
    final addProductImage = model.addProductImage;
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final maxHeight = constraints.maxHeight;
              final isMobile = maxWidth < 600 && maxHeight < 690;
              final isMobileOrLaptop = maxWidth < 900 && maxHeight < 690;

              // Минимальные ширины для мобильных:
              final mobileMinColumnWidths = [
                40.0, // колонка с чекбоксом
                150.0, // Товар
                80.0, // Выручка
                80.0, // Цена
                80.0, // Продавец
                80.0, // Бренд
                80.0, // Заказы
                80.0, // Детали
              ];

              // Пропорции столбцов для десктопа:
              final columnProportions = [
                0.05, // Чекбокс
                0.3, // Товар
                0.1, // Выручка
                0.1, // Цена
                0.1, // Продавец
                0.1, // Бренд
                0.1, // Заказы
                0.12, // Детали
              ];

              // Вычислим итоговые ширины
              final columnWidths = isMobile
                  ? mobileMinColumnWidths
                  : columnProportions.map((p) => p * maxWidth).toList();

              // Итого 8 столбцов (1 чекбокс + 7 ваших)
              final columns = <TableColumn>[
                TableColumn(width: columnWidths[0]), // Чекбокс
                TableColumn(width: columnWidths[1]),
                TableColumn(width: columnWidths[2]),
                TableColumn(width: columnWidths[3]),
                TableColumn(width: columnWidths[4]),
                TableColumn(width: columnWidths[5]),
                TableColumn(width: columnWidths[6]),
                TableColumn(width: columnWidths[7]),
              ];

              return Stack(
                children: [
                  // Само тело таблицы
                  Positioned.fill(
                    child: Container(
                      margin: isMobileOrLaptop
                          ? EdgeInsets.zero
                          : EdgeInsets.all(8.0),
                      padding: isMobile
                          ? EdgeInsets.only(top: 50.0)
                          : const EdgeInsets.fromLTRB(16.0, 50.0, 16.0, 16.0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: TableView.builder(
                        controller: tableViewController,
                        columns: columns,
                        rowHeight: model.tableRowHeight,
                        rowCount: detailedOrders.length,
                        headerBuilder: (context, contentBuilder) {
                          // Заголовки столбцов
                          return contentBuilder(context,
                              (context, columnIndex) {
                            if (columnIndex == 0) {
                              return SizedBox();
                            }

                            // Остальные 7 колонок:
                            final headers = [
                              "Товар",
                              "Выручка (₽)",
                              "Цена со скидкой (₽)",
                              "Продавец",
                              "Бренд",
                              "Заказы кол-во",
                              "Детали",
                            ];
                            final headerIndex = columnIndex - 1;
                            final alignment = headerIndex == 0
                                ? Alignment.centerLeft
                                : Alignment.center;

                            return GestureDetector(
                              onTap: () {
                                if (headerIndex == 6) return;
                                sortData(headerIndex);
                              },
                              child: Container(
                                alignment: alignment,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: headerIndex == 0
                                      ? MainAxisAlignment.start
                                      : MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        headers[headerIndex],
                                        textAlign: headerIndex == 0
                                            ? TextAlign.left
                                            : TextAlign.center,
                                        style: TextStyle(
                                          fontSize: isMobile
                                              ? theme.textTheme.bodyMedium!
                                                      .fontSize! *
                                                  1.2
                                              : theme.textTheme.bodyMedium!
                                                  .fontSize,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        softWrap: true,
                                      ),
                                    ),
                                    if (headerIndex == sortColumnIndex)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 4.0),
                                        child: Icon(
                                          isAscending
                                              ? Icons.arrow_drop_down
                                              : Icons.arrow_drop_up,
                                          color: theme.colorScheme.onSurface,
                                          size: theme
                                              .textTheme.bodyMedium!.fontSize,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          });
                        },
                        rowBuilder: (context, rowIndex, contentBuilder) {
                          final item = detailedOrders[rowIndex];

                          final basketNum = getBasketNum(item.productId);
                          final imageUrl =
                              calculateImageUrl(basketNum, item.productId);
                          final cardUrl = calculateCardUrl(imageUrl);
                          return contentBuilder(context,
                              (context, columnIndex) {
                            // 0-й столбец: чекбокс выбора
                            if (columnIndex == 0) {
                              return Container(
                                  alignment: Alignment.center,
                                  child: McCheckBox(
                                      value:
                                          selectedRows.contains(item.productId),
                                      theme: theme,
                                      onChanged: (bool? value) {
                                        selectRow(
                                          item.productId,
                                        );
                                      }));
                            }

                            // Остальные данные (columnIndex - 1)
                            final dataIndex = columnIndex - 1;
                            Widget content;
                            switch (dataIndex) {
                              case 0: // Товар
                                content = imageUrl.isEmpty
                                    ? Row(
                                        children: [
                                          Image.asset(
                                            'images/no_image.jpg',
                                            width: 50,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text("Описание отсутствует"),
                                        ],
                                      )
                                    : FutureBuilder<String>(
                                        future: fetchCardInfo(cardUrl)
                                            .then((value) => value.imtName),
                                        builder: (context, snapshot) {
                                          final description =
                                              snapshot.data ?? "Загрузка...";
                                          addProductImage(item.productId,
                                              imageUrl, snapshot.data ?? "");
                                          final wildberriesUrl =
                                              "https://wildberries.ru/catalog/${item.productId}/detail.aspx?targetUrl=EX";
                                          return Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  if (imageUrl.isNotEmpty) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          Dialog(
                                                        child:
                                                            InteractiveViewer(
                                                          child: FittedBox(
                                                            fit: BoxFit.contain,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      18.0),
                                                              child:
                                                                  Image.network(
                                                                imageUrl,
                                                                fit: BoxFit
                                                                    .contain,
                                                                loadingBuilder:
                                                                    (context,
                                                                        child,
                                                                        loadingProgress) {
                                                                  if (loadingProgress ==
                                                                      null) {
                                                                    return child;
                                                                  }
                                                                  return const SizedBox(
                                                                    width: 100,
                                                                    height: 100,
                                                                    child: Center(
                                                                        child:
                                                                            CircularProgressIndicator()),
                                                                  );
                                                                },
                                                                errorBuilder:
                                                                    (context,
                                                                        error,
                                                                        stackTrace) {
                                                                  return const Center(
                                                                    child: Text(
                                                                        'Ошибка загрузки изображения'),
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                                child: Image.network(
                                                  imageUrl,
                                                  width: 50,
                                                  height: 50,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Image.asset(
                                                      'images/no_image.jpg',
                                                      width: 50,
                                                    );
                                                  },
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress ==
                                                        null) {
                                                      return child;
                                                    }
                                                    return const SizedBox(
                                                      width: 50,
                                                      height: 50,
                                                      child: Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: MouseRegion(
                                                  cursor:
                                                      SystemMouseCursors.click,
                                                  child: GestureDetector(
                                                    onTap: () => launchUrl(
                                                        Uri.parse(
                                                            wildberriesUrl)),
                                                    child: Text(
                                                      description,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                        decorationColor:
                                                            Color(0xFF5166e3),
                                                        color:
                                                            Color(0xFF5166e3),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                break;
                              case 1: // Выручка
                                content = Text(
                                  (item.price * item.orders)
                                      .toString()
                                      .formatWithThousands(),
                                  style: TextStyle(
                                      fontSize: isMobileOrLaptop
                                          ? columns[6].width * 0.12
                                          : theme
                                              .textTheme.bodyMedium!.fontSize,
                                      fontWeight: FontWeight.bold),
                                );
                                break;
                              case 2: // Цена
                                content = Text(
                                  item.price.toString().formatWithThousands(),
                                  style: TextStyle(
                                      fontSize: isMobileOrLaptop
                                          ? columns[6].width * 0.12
                                          : theme
                                              .textTheme.bodyMedium!.fontSize,
                                      fontWeight: FontWeight.bold),
                                );
                                break;
                              case 3: // Продавец
                                content = Text(
                                  item.supplier.toString(),
                                  style: TextStyle(
                                      fontSize: isMobileOrLaptop
                                          ? columns[6].width * 0.12
                                          : theme
                                              .textTheme.bodyMedium!.fontSize,
                                      fontWeight: FontWeight.bold),
                                );
                                break;
                              case 4: // Бренд
                                content = Text(
                                  item.brand,
                                  style: TextStyle(
                                      fontSize: isMobileOrLaptop
                                          ? columns[6].width * 0.12
                                          : theme
                                              .textTheme.bodyMedium!.fontSize,
                                      fontWeight: FontWeight.bold),
                                );
                                break;
                              case 5: // Заказы
                                content = Text(
                                  item.orders.toString().formatWithThousands(),
                                  style: TextStyle(
                                      fontSize: isMobileOrLaptop
                                          ? columns[6].width * 0.12
                                          : theme
                                              .textTheme.bodyMedium!.fontSize,
                                      fontWeight: FontWeight.bold),
                                );
                                break;
                              case 6: // Детали
                                content = MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () => navigateToProduct(
                                        item.productId, item.price),
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: isMobileOrLaptop
                                          ? columns[columnIndex].width * 0.7
                                          : columns[columnIndex].width * 0.35,
                                      height: isMobileOrLaptop
                                          ? columns[columnIndex].width * 0.3
                                          : columns[columnIndex].width * 0.15,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                        border: Border.all(
                                          color: theme.colorScheme.primary,
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Text(
                                        'Перейти',
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontSize: isMobileOrLaptop
                                              ? columns[columnIndex].width *
                                                  0.12
                                              : columns[columnIndex].width *
                                                  0.06,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                                break;
                              default:
                                content = const SizedBox();
                            }

                            return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: theme.colorScheme.onSurface
                                        .withAlpha((0.2 * 255).toInt()),
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              alignment: dataIndex == 0
                                  ? Alignment.centerLeft
                                  : Alignment.center,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: content,
                            );
                          });
                        },
                      ),
                    ),
                  ),
                  // Кнопка "Фильтры"
                  Positioned(
                    right: 26,
                    top: 26,
                    child: TextButton(
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
                  ),
                  // Заголовок таблицы
                  Positioned(
                    left: 26,
                    top: 26,
                    child: Text(
                      model.tableHeaderText,
                      style: TextStyle(
                        fontSize: theme.textTheme.titleLarge!.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (selectedRows.isNotEmpty)
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
                            selectedRows.clear();
                          });
                        },
                        children: [
                          SpeedDialChild(
                            backgroundColor: theme.colorScheme.secondary,
                            child: Icon(Icons.analytics,
                                color: theme.colorScheme.onSecondary),
                            label: "Расширение запросов",
                            labelStyle: TextStyle(
                                fontSize: theme.textTheme.bodyLarge!.fontSize),
                            onTap: () =>
                                model.navigateToSeoRequestsExtendScreen(),
                          ),
                          SpeedDialChild(
                            backgroundColor: theme.colorScheme.secondary,
                            child: Icon(Icons.visibility,
                                color: theme.colorScheme.onSecondary),
                            label: "Отслеживать",
                            labelStyle: TextStyle(
                                fontSize: theme.textTheme.bodyLarge!.fontSize),
                            onTap: () => model.saveProducts(),
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
}
