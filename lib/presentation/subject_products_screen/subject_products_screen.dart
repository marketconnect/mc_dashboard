import 'package:flutter/material.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:mc_dashboard/core/utils/basket_num.dart';
import 'package:mc_dashboard/core/utils/strings_ext.dart';
import 'package:provider/provider.dart';
import 'package:mc_dashboard/presentation/subject_products_screen/subject_products_view_model.dart';

import 'package:pie_chart/pie_chart.dart' as pie_chart;
import 'package:url_launcher/url_launcher.dart';

// TODO back button
class SubjectProductsScreen extends StatelessWidget {
  const SubjectProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SubjectProductsViewModel>();
    final subjectName = model.subjectName;
    final switchToFbs = model.switchToFbs;
    final isFbs = model.isFbs;
    final isFilterVisible = model.isFilterVisible;
    final surfaceContainerHighest =
        Theme.of(context).colorScheme.surfaceContainerHighest;

    final theme = Theme.of(context);
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final maxHeight = constraints.maxHeight;
          final isMobileOrLaptop = maxWidth < 900 || maxHeight < 690;
          final model = context.watch<SubjectProductsViewModel>();
          final onNavigateToEmptySubject = model.onNavigateToEmptySubject;
          final clearSellerBrandFilter = model.clearSellerBrandFilter;
          final isFilteredBySeller = model.filteredSeller != null;
          final isFilteredByBrand = model.filteredBrand != null;
          if (isMobileOrLaptop) {
            // Mobile and Laptop ///////////////////////////////////////////////
            return SingleChildScrollView(
              controller: ScrollController(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(
                      subjectName: subjectName,
                      theme: theme,
                      isFbs: isFbs,
                      switchToFbs: switchToFbs,
                      onNavigateToEmptySubject: onNavigateToEmptySubject),
                  Container(
                    height: constraints.maxHeight * 0.3, // Height for graph
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
                    ),
                  ),
                  Container(
                    height: constraints.maxHeight * 0.3, // Height for bar
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(16.0),
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
                    ),
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
                    child: const _TableWidget(),
                  ),
                ],
              ),
            );
          }

          // Desktop //////////////////////////////////////////////////////////
          return Column(
            children: [
              _Header(
                  subjectName: subjectName,
                  theme: theme,
                  isFbs: isFbs,
                  switchToFbs: switchToFbs,
                  onNavigateToEmptySubject: onNavigateToEmptySubject),
              if (!isFilterVisible)
                Flexible(
                  flex: 1,
                  child: Row(
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
                          child: _PieChartWithList(
                            isClearButtonVisible: isFilteredBySeller,
                            dataMap: model.sellersDataMap,
                            title: "Продавцы (ТОП-30)",
                            onTapValue: model.filterBySeller,
                            clearFilter: clearSellerBrandFilter,
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Container(
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
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (isFilterVisible) _buildFiltersWidget(context),
              Flexible(
                flex: 2,
                child: Container(
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

  Widget _buildFiltersWidget(BuildContext context) {
    final model = context.watch<SubjectProductsViewModel>();
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
  const _Header({
    required this.subjectName,
    required this.theme,
    required this.isFbs,
    required this.switchToFbs,
    required this.onNavigateToEmptySubject,
  });

  final String subjectName;
  final ThemeData theme;
  final bool isFbs;
  final Future<void> Function() switchToFbs;
  final void Function() onNavigateToEmptySubject;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(subjectName,
                style: TextStyle(
                  fontSize: theme.textTheme.titleLarge!.fontSize,
                  fontWeight: FontWeight.bold,
                )),
          ),
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
            color: Colors.black),
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

  const _PieChartWithList({
    required this.title,
    required this.dataMap,
    this.isClearButtonVisible = false,
    required this.clearFilter,
    required this.onTapValue,
  });

  @override
  Widget build(BuildContext context) {
    if (dataMap.isEmpty) {
      return const Center(child: Text("Нет данных"));
    }
    final theme = Theme.of(context);
    final colorList = _generateColorList(dataMap.length);

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
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
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: theme.textTheme.bodyMedium!.fontSize,
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
                                            fontSize: theme.textTheme
                                                .bodyMedium!.fontSize),
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
              ),
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
    final detailedOrders = model.detailedOrders;
    final sortData = model.sortData;
    final sortColumnIndex = model.sortColumnIndex;
    final isAscending = model.isAscending;
    final theme = Theme.of(context);
    final toggleFilterVisibility = model.toggleFilterVisibility;
    final navigateToProduct = model.onNavigateToProductScreen;
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;
        final isMobile = maxWidth < 600 && maxHeight < 690;
        final isMobileOrLaptop = maxWidth < 900 && maxHeight < 690;
        final mobileMinColumnWidths = [
          100.0,
          80.0,
          80.0,
          80.0,
          80.0,
          80.0,
          80.0
        ];

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
                    rowCount: detailedOrders.length,
                    headerBuilder: (context, contentBuilder) {
                      // Header builder //////////////////////////////////////////

                      return contentBuilder(context, (context, columnIndex) {
                        final headers = [
                          "Товар",
                          "Выручка (₽)",
                          "Цена со скидкой (₽)",
                          "Продавец",
                          "Бренд",
                          "Заказы кол-во",
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
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
                                      fontSize:
                                          theme.textTheme.bodyMedium!.fontSize,
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
                                      size:
                                          theme.textTheme.bodyMedium!.fontSize,
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

                      return contentBuilder(context, (context, columnIndex) {
                        Widget content;
                        switch (columnIndex) {
                          case 0:
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
                                    future:
                                        fetchCardInfo(cardUrl).then((value) {
                                      return value.imtName;
                                    }),
                                    builder: (context, snapshot) {
                                      final description =
                                          snapshot.data ?? "Загрузка...";
                                      final wildberriesUrl =
                                          "https://wildberries.ru/catalog/${item.productId}/detail.aspx?targetUrl=EX";
                                      return Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              if (imageUrl.isNotEmpty) {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => Dialog(
                                                    child: InteractiveViewer(
                                                      child: FittedBox(
                                                        fit: BoxFit.contain,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(18.0),
                                                          child: Image.network(
                                                            imageUrl,
                                                            fit: BoxFit.contain,
                                                            loadingBuilder:
                                                                (context, child,
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
                                                                (context, error,
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
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Image.asset(
                                                  'images/no_image.jpg',
                                                  width: 50,
                                                );
                                              },
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return const SizedBox(
                                                  width: 50,
                                                  height: 50,
                                                  child: Center(
                                                      child:
                                                          CircularProgressIndicator()),
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: MouseRegion(
                                              cursor: SystemMouseCursors.click,
                                              child: GestureDetector(
                                                onTap: () => launchUrl(
                                                    Uri.parse(wildberriesUrl)),
                                                child: Text(
                                                  description,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    decoration: TextDecoration
                                                        .underline,
                                                    decorationColor:
                                                        Color(0xFF5166e3),
                                                    color: Color(0xFF5166e3),
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
                          case 1: // REVENUE
                            content = Text((item.price * item.orders)
                                .toString()
                                .formatWithThousands());
                            break;
                          case 2: // PRICE
                            content = Text(
                                item.price.toString().formatWithThousands());

                            break;
                          case 3: // SALLER
                            content = Text(item.supplier.toString());
                            break;
                          case 4: // Brand
                            content = Text(item.brand);
                            break;
                          case 5: // Orders count
                            content = Text(
                                item.orders.toString().formatWithThousands());
                            break;

                          case 6:
                            content = MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () => navigateToProduct(
                                    item.productId, item.price),
                                child: Container(
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
                            );
                          default:
                            content = const SizedBox();
                        }

                        return Container(
                          decoration: BoxDecoration(
                              border: Border(
                            bottom: BorderSide(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.2),
                              width: 1.0,
                            ),
                          )),
                          alignment: columnIndex == 0
                              ? Alignment.centerLeft
                              : Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: content,
                        );
                      });
                    }),
              ),
            ),
            Positioned(
              right: 26,
              top: 26,
              child: TextButton(
                onPressed: () {
                  // _showFilterDialog(context, model);
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
          ],
        );
      },
    );
  }
}
