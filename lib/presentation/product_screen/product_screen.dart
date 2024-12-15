import 'package:fl_chart/fl_chart.dart';
import 'package:mc_dashboard/presentation/product_screen/product_view_model.dart';
import 'package:pie_chart/pie_chart.dart' as pie_chart;
import 'package:flutter/material.dart';

import 'dart:math' as math;

import 'package:provider/provider.dart';

// TODO back button
// TODO scrolling for images
class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  String selectedPeriod = '30 дней';

  final List<String> periods = ['7 дней', '30 дней', '90 дней', 'год'];

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ProductViewModel>();
    final id = model.productId;

    final name = model.name;
    final images = model.images;

    final price = model.productPrice;
    final rating = model.rating;

    // final stocks = model.stocks;
    final orders = model.orders;

    final pieDataMap = model.warehousesOrdersSum;

    //
    final orders30d = model.orders30d;
    final priceHistoryData = model.priceHistory;
    final warehouseShares = model.warehouseShares;

    List<DateTime> ordersDates =
        orders.map((e) => e['date'] as DateTime).toList();
    List<double> salesValues =
        orders.map((e) => (e['totalOrders'] as int).toDouble()).toList();

    List<DateTime> priceDates =
        priceHistoryData.map((e) => e['date'] as DateTime).toList();
    List<double> priceValues =
        priceHistoryData.map((e) => (e["price"] as num).toDouble()).toList();

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Артикул: $id',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: images.map((img) {
                        return MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              if (img.isNotEmpty) {
                                showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
                                    child: InteractiveViewer(
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: Image.network(
                                          img,
                                          fit: BoxFit.contain,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null) {
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
                                              (context, error, stackTrace) {
                                            return const Center(
                                              child: Text(
                                                  'Ошибка загрузки изображения'),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Image.network(
                                img,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'images/no_image.jpg',
                                    width: 50,
                                  );
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  }
                                  return const SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildStatCard('Цена', '${_formatPrice(price)} ₽'),
                      _buildStatCard('Продажи за 30 дней', '$orders30d шт.'),
                      _buildStatCard('Рейтинг', '$rating ★'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Графики',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildChartContainer(
                        title: 'Динамика продаж',
                        child: _buildLineChart(ordersDates, salesValues,
                            isSales: true),
                      ),
                      _buildChartContainer(
                        title: 'История изменения цены',
                        child: _buildLineChart(priceDates, priceValues,
                            isSales: false),
                      ),
                      // _buildChartContainer(
                      //   title: 'Распределение оценок',
                      //   child: _buildBarChart(ratingBars),
                      // ),
                      _buildChartContainer(
                        title: 'Доля продаж по складам',
                        child: _buildPieChart(pieDataMap),
                      ),
                    ],
                  ),
                  // if (model.pros.isNotEmpty || model.cons.isNotEmpty) ...[
                  //   const SizedBox(height: 24),
                  //   Text(
                  //     'Плюсы и минусы',
                  //     style: Theme.of(context)
                  //         .textTheme
                  //         .titleLarge
                  //         ?.copyWith(fontWeight: FontWeight.bold),
                  //   ),
                  //   const SizedBox(height: 8),
                  //   if (model.pros.isNotEmpty) ...[
                  //     GestureDetector(
                  //       onTap: () {
                  //         setState(() {
                  //           _prosExpanded = !_prosExpanded;
                  //         });
                  //       },
                  //       child: Row(
                  //         mainAxisAlignment: MainAxisAlignment.start,
                  //         children: [
                  //           Text(
                  //             'Плюсы:',
                  //             style: Theme.of(context)
                  //                 .textTheme
                  //                 .titleMedium
                  //                 ?.copyWith(fontWeight: FontWeight.bold),
                  //           ),
                  //           Icon(
                  //             _prosExpanded
                  //                 ? Icons.keyboard_arrow_up
                  //                 : Icons.keyboard_arrow_down,
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //     if (_prosExpanded)
                  //       Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: model.pros.map((pro) {
                  //           return Row(
                  //             crossAxisAlignment: CrossAxisAlignment.start,
                  //             children: [
                  //               const Icon(Icons.add,
                  //                   color: Colors.green, size: 16),
                  //               const SizedBox(width: 8),
                  //               Expanded(child: Text(pro)),
                  //             ],
                  //           );
                  //         }).toList(),
                  //       ),
                  //   ],
                  //   const SizedBox(height: 16),
                  //   if (model.cons.isNotEmpty) ...[
                  //     GestureDetector(
                  //       onTap: () {
                  //         setState(() {
                  //           _consExpanded = !_consExpanded;
                  //         });
                  //       },
                  //       child: Row(
                  //         mainAxisAlignment: MainAxisAlignment.start,
                  //         children: [
                  //           Text(
                  //             'Минусы:',
                  //             style: Theme.of(context)
                  //                 .textTheme
                  //                 .titleMedium
                  //                 ?.copyWith(fontWeight: FontWeight.bold),
                  //           ),
                  //           Icon(
                  //             _consExpanded
                  //                 ? Icons.keyboard_arrow_up
                  //                 : Icons.keyboard_arrow_down,
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //     if (_consExpanded)
                  //       Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: model.cons.map((con) {
                  //           return Row(
                  //             crossAxisAlignment: CrossAxisAlignment.start,
                  //             children: [
                  //               const Icon(Icons.remove,
                  //                   color: Colors.red, size: 16),
                  //               const SizedBox(width: 8),
                  //               Expanded(child: Text(con)),
                  //             ],
                  //           );
                  //         }).toList(),
                  //       ),
                  //   ],
                  // ],
                  const SizedBox(height: 24),
                  Text(
                    'Остатки',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  warehouseShares.isNotEmpty
                      ? _buildTable(
                          columns: const ['Склад', 'Доля (%)'],
                          rows: warehouseShares.map((w) {
                            return [
                              w["name"] as String,
                              '${(w["value"] as double).toStringAsFixed(2)} %', // Преобразование в строку
                            ];
                          }).toList(),
                        )
                      : _noDataPlaceholder(),

                  const SizedBox(height: 24),
                  _Feedback()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatPrice(num value) {
    final s = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(s[i]);
    }
    return buffer.toString();
  }

  Widget _buildStatCard(String title, String value) {
    final theme = Theme.of(context);
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildChartContainer({required String title, required Widget child}) {
    final theme = Theme.of(context);

    return Container(
      width: 500,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(height: 200, child: child),
        ],
      ),
    );
  }

  Widget _buildLineChart(List<DateTime> dates, List<double> values,
      {required bool isSales}) {
    if (dates.isEmpty || values.isEmpty || dates.length != values.length) {
      return _noDataPlaceholder();
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < dates.length; i++) {
      spots.add(FlSpot(i.toDouble(), values[i]));
    }

    return LineChart(
      LineChartData(
        gridData:
            FlGridData(drawVerticalLine: false, drawHorizontalLine: false),
        borderData: FlBorderData(
            show: true,
            border: const Border(bottom: BorderSide(), left: BorderSide())),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, _) {
                int index = val.toInt();
                if (index < 0 || index >= dates.length) return const SizedBox();
                final dt = dates[index];
                return Text('${dt.day} ${_monthName(dt.month)}',
                    style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, _) {
                if (isSales) {
                  return Text(val.toInt().toString(),
                      style: const TextStyle(fontSize: 10));
                } else {
                  return Text('${val.toInt()} ₽',
                      style: const TextStyle(fontSize: 10));
                }
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 2,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(Map<String, double> dataMap) {
    if (dataMap.isEmpty) return _noDataPlaceholder();

    final List<Color> colorList = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.cyan,
      Colors.amber,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
      Colors.lime,
      Colors.brown,
      Colors.black
    ];

    final keys = dataMap.keys.toList();

    return Row(
      children: [
        Expanded(
          child: pie_chart.PieChart(
            dataMap: dataMap,
            chartType: pie_chart.ChartType.ring,
            colorList: List.generate(
                dataMap.length, (index) => colorList[index % colorList.length]),
            legendOptions: const pie_chart.LegendOptions(
              showLegends: false,
            ),
            chartValuesOptions: const pie_chart.ChartValuesOptions(
              showChartValuesInPercentage: true,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(keys.length, (index) {
                final k = keys[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        color: colorList[index % colorList.length],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$k ${dataMap[k]}шт.',
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _noDataPlaceholder() {
    return Row(
      children: const [
        Icon(Icons.info, color: Colors.grey),
        SizedBox(width: 8),
        Text('Нет данных для отображения'),
      ],
    );
  }

  Widget _buildTable({
    required List<String> columns,
    required List<List<String>> rows,
  }) {
    if (rows.isEmpty) return _noDataPlaceholder();

    return Table(
      border: TableBorder.all(),
      columnWidths: {
        for (var i = 0; i < columns.length; i++)
          i: const IntrinsicColumnWidth(),
      },
      children: [
        TableRow(
          children: columns
              .map((column) => TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        column,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ))
              .toList(),
        ),
        for (var row in rows)
          TableRow(
            children: row
                .map((cell) => TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(cell),
                      ),
                    ))
                .toList(),
          ),
      ],
    );
  }

  String _monthName(int month) {
    switch (month) {
      case 1:
        return 'янв';
      case 2:
        return 'фев';
      case 3:
        return 'мар';
      case 4:
        return 'апр';
      case 5:
        return 'мая';
      case 6:
        return 'июн';
      case 7:
        return 'июл';
      case 8:
        return 'авг';
      case 9:
        return 'сен';
      case 10:
        return 'окт';
      case 11:
        return 'ноя';
      case 12:
        return 'дек';
      default:
        return '';
    }
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ProductViewModel>();
    final ratingDistribution = model.ratingDistribution;

    final totalCount =
        ratingDistribution.values.fold(0, (sum, count) => sum + count);
    final ratingsData = ratingDistribution.entries.map((entry) {
      final rating = entry.key;
      final count = entry.value;
      return [rating, '$count шт.', '${(count * 100 / totalCount).ceil()}%'];
    }).toList()
      ..sort((a, b) => int.parse(a[0]).compareTo(int.parse(b[0])));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Отзывы покупателей',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Распределение оценок в виде таблицы
              Text(
                'Распределение оценок',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (ratingsData.isNotEmpty)
                _buildTable(
                  context,
                  columns: const ['Оценка', 'Количество', 'Процент'],
                  rows: ratingsData,
                )
              else
                _noDataPlaceholder(),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Плюсы и Минусы (всегда развернуты)
              if (model.pros.isNotEmpty || model.cons.isNotEmpty) ...[
                Text(
                  'Плюсы и минусы',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Плюсы
                if (model.pros.isNotEmpty) ...[
                  Text(
                    'Плюсы:',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...model.pros.map((pro) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.add, color: Colors.green, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(pro)),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],

                // Минусы
                if (model.cons.isNotEmpty) ...[
                  Text(
                    'Минусы:',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...model.cons.map((con) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.remove, color: Colors.red, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(con)),
                        ],
                      ),
                    );
                  }),
                ],
              ] else
                const Text('Нет отзывов или мнений покупателей'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _noDataPlaceholder() {
    return Row(
      children: const [
        Icon(Icons.info, color: Colors.grey),
        SizedBox(width: 8),
        Text('Нет данных для отображения'),
      ],
    );
  }

  Widget _buildTable(BuildContext context,
      {required List<String> columns, required List<List<String>> rows}) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Table(
        columnWidths: const {
          0: IntrinsicColumnWidth(),
          1: IntrinsicColumnWidth(),
          2: IntrinsicColumnWidth(),
        },
        border: TableBorder(
          horizontalInside: BorderSide(color: Colors.grey.shade300),
        ),
        children: [
          TableRow(
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              color: theme.colorScheme.primary.withOpacity(0.1),
            ),
            children: columns
                .map((column) => Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        column,
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ))
                .toList(),
          ),
          for (var row in rows)
            TableRow(
              children: row
                  .map((cell) => Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(cell, style: theme.textTheme.bodyMedium),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }
}
