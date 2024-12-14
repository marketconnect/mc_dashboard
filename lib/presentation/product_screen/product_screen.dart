import 'package:fl_chart/fl_chart.dart';
import 'package:mc_dashboard/presentation/product_screen/product_view_model.dart';
import 'package:pie_chart/pie_chart.dart' as pie_chart;
import 'package:flutter/material.dart';

import 'dart:math' as math;

import 'package:provider/provider.dart';

final Map<String, dynamic> mockData = {
  "name": "Пример товара",
  "id": "12345",
  "images": ["assets/image1.jpg", "assets/image2.jpg"],
  "price": 1500,
  "sales30d": 250,
  "rating": 4.7,
  "salesData": [
    {"date": "2024-10-26", "sales": 10, "revenue": 15000},
    {"date": "2024-10-27", "sales": 12, "revenue": 18000},
    {"date": "2024-10-28", "sales": 15, "revenue": 22500},
    {"date": "2024-10-29", "sales": 20, "revenue": 30000},
    {"date": "2024-10-30", "sales": 18, "revenue": 27000},
    {"date": "2024-10-31", "sales": 22, "revenue": 33000},
    {"date": "2024-11-01", "sales": 25, "revenue": 37500},
  ],
  "priceHistory": [
    {"date": "2024-10-26", "price": 1500},
    {"date": "2024-10-27", "price": 1490},
    {"date": "2024-10-28", "price": 1520},
    {"date": "2024-10-29", "price": 1500},
    {"date": "2024-10-30", "price": 1480},
    {"date": "2024-10-31", "price": 1510},
    {"date": "2024-11-01", "price": 1500},
  ],
  "ratingDistribution": [
    {"rating": 1, "count": 5},
    {"rating": 2, "count": 10},
    {"rating": 3, "count": 20},
    {"rating": 4, "count": 50},
    {"rating": 5, "count": 100}
  ],
  "warehouseShares": [
    {"name": "Склад 1", "value": 30},
    {"name": "Склад 2", "value": 70}
  ],
  "competitors": [
    {"name": "Конкурент 1", "price": 1600, "sales": 200, "rating": 4.5},
    {"name": "Конкурент 2", "price": 1400, "sales": 180, "rating": 4.3},
    {"name": "Конкурент 3", "price": 1550, "sales": 210, "rating": 4.6},
  ],
  "reviews": [
    {
      "author": "Иван",
      "date": "2024-10-27",
      "rating": 5,
      "text": "Отличный товар!"
    },
    {
      "author": "Мария",
      "date": "2024-10-28",
      "rating": 4,
      "text": "Хороший товар, но доставка задержалась."
    },
    {
      "author": "Сергей",
      "date": "2024-10-29",
      "rating": 3,
      "text": "Среднее качество, ожидал большего."
    },
  ]
};

// TODO back button
// TODO scrolling for images
class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  String selectedPeriod = '30 дней';
  bool _prosExpanded = false;
  bool _consExpanded = false;
  final List<String> periods = ['7 дней', '30 дней', '90 дней', 'год'];

  Map<String, dynamic> get data => mockData;

  List<Map<String, dynamic>> get filteredSalesData {
    if (selectedPeriod == '7 дней') {
      final salesData = data["salesData"] as List<Map<String, dynamic>>?;
      if (salesData == null) return [];
      return salesData.sublist(math.max(0, salesData.length - 7));
    } else if (selectedPeriod == '30 дней') {
      return data["salesData"];
    } else if (selectedPeriod == '90 дней') {
      return data["salesData"];
    } else if (selectedPeriod == 'год') {
      return data["salesData"];
    }
    return data["salesData"];
  }

  List<Map<String, dynamic>> get filteredPriceHistory {
    return data["priceHistory"];
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ProductViewModel>();
    final id = model.productId;

    final name = model.name;
    final images = model.images;
    final ratingDistribution = model.ratingDistribution;

    final price = model.productPrice;
    final rating = model.rating;

    // final stocks = model.stocks;
    final orders = model.orders;

    final pieDataMap = model.warehousesOrdersSum;

    //
    final orders30d = model.orders30d;
    final priceHistoryData = model.priceHistory;
    final warehouseShares = model.warehouseShares;

    // final salesDataList = filteredSalesData;
    // final priceHistoryData = filteredPriceHistory;
    print("orders length ${orders.length}");
    List<DateTime> ordersDates =
        orders.map((e) => e['date'] as DateTime).toList();
    List<double> salesValues =
        orders.map((e) => (e['totalOrders'] as int).toDouble()).toList();

    List<DateTime> priceDates =
        priceHistoryData.map((e) => e['date'] as DateTime).toList();
    List<double> priceValues =
        priceHistoryData.map((e) => (e["price"] as num).toDouble()).toList();

    List<BarChartGroupData> ratingBars = ratingDistribution.keys.map((key) {
      final rateValue = int.parse(key);
      final count = ratingDistribution[key] as int;
      return BarChartGroupData(
        x: rateValue,
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            color: Colors.blue,
            width: 20,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      );
    }).toList();

    // bool hasSalesData = ordersDates.isNotEmpty;
    // bool hasCompetitorsData = competitors.isNotEmpty;
    // bool hasReviewsData = reviews.isNotEmpty;

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
                  // Row(
                  //   children: [
                  //     const Text('Период:'),
                  //     const SizedBox(width: 8),
                  //     DropdownButton<String>(
                  //       value: selectedPeriod,
                  //       items: periods.map((period) {
                  //         return DropdownMenuItem(
                  //           value: period,
                  //           child: Text(period),
                  //         );
                  //       }).toList(),
                  //       onChanged: (val) {
                  //         if (val != null) {
                  //           setState(() {
                  //             selectedPeriod = val;
                  //           });
                  //         }
                  //       },
                  //     ),
                  //   ],
                  // ),
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
                      _buildChartContainer(
                        title: 'Распределение оценок',
                        child: _buildBarChart(ratingBars),
                      ),
                      _buildChartContainer(
                        title: 'Доля продаж по складам',
                        child: _buildPieChart(pieDataMap),
                      ),
                    ],
                  ),
                  if (model.pros.isNotEmpty || model.cons.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Плюсы и минусы',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (model.pros.isNotEmpty) ...[
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _prosExpanded = !_prosExpanded;
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Плюсы:',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Icon(
                              _prosExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                            ),
                          ],
                        ),
                      ),
                      if (_prosExpanded)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: model.pros.map((pro) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.add,
                                    color: Colors.green, size: 16),
                                const SizedBox(width: 8),
                                Expanded(child: Text(pro)),
                              ],
                            );
                          }).toList(),
                        ),
                    ],
                    const SizedBox(height: 16),
                    if (model.cons.isNotEmpty) ...[
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _consExpanded = !_consExpanded;
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Минусы:',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Icon(
                              _consExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                            ),
                          ],
                        ),
                      ),
                      if (_consExpanded)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: model.cons.map((con) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.remove,
                                    color: Colors.red, size: 16),
                                const SizedBox(width: 8),
                                Expanded(child: Text(con)),
                              ],
                            );
                          }).toList(),
                        ),
                    ],
                  ],
                  const SizedBox(height: 24),
                  // Text(
                  //   'Подробная информация о продажах',
                  //   style: Theme.of(context)
                  //       .textTheme
                  //       .titleLarge
                  //       ?.copyWith(fontWeight: FontWeight.bold),
                  // ),
                  // const SizedBox(height: 8),
                  // hasSalesData
                  //     ? _buildTable(
                  //         columns: const [
                  //           'Дата',
                  //           'Количество продаж',
                  //           'Выручка'
                  //         ],
                  //         rows: orders.map((e) {
                  //           return [
                  //             e["date"] as String,
                  //             '${e["totalOrders"]} шт.',
                  //             '${_formatPrice(e["revenue"])} ₽'
                  //           ];
                  //         }).toList(),
                  //       )
                  //     : _noDataPlaceholder(),
                  // const SizedBox(height: 24),
                  // Text(
                  //   'Информация о конкурентах',
                  //   style: Theme.of(context)
                  //       .textTheme
                  //       .titleLarge
                  //       ?.copyWith(fontWeight: FontWeight.bold),
                  // ),
                  // const SizedBox(height: 8),
                  // hasCompetitorsData
                  //     ? _buildTable(
                  //         columns: const [
                  //           'Название конкурента',
                  //           'Цена',
                  //           'Продажи',
                  //           'Рейтинг'
                  //         ],
                  //         rows: competitors.map((c) {
                  //           return [
                  //             c["name"] as String,
                  //             '${_formatPrice(c["price"])} ₽',
                  //             '${c["sales"]} шт.',
                  //             '${c["rating"]} ★'
                  //           ];
                  //         }).toList(),
                  //       )
                  //     : _noDataPlaceholder(),
                  // const SizedBox(height: 24),
                  // Text(
                  //   'Отзывы',
                  //   style: Theme.of(context)
                  //       .textTheme
                  //       .titleLarge
                  //       ?.copyWith(fontWeight: FontWeight.bold),
                  // ),
                  // const SizedBox(height: 8),
                  // hasReviewsData
                  //     ? _buildTable(
                  //         columns: const [
                  //           'Автор',
                  //           'Дата',
                  //           'Оценка',
                  //           'Текст отзыва'
                  //         ],
                  //         rows: reviews.map((r) {
                  //           return [
                  //             r["author"] as String,
                  //             r["date"] as String,
                  //             '${r["rating"]} ★',
                  //             r["text"] as String,
                  //           ];
                  //         }).toList(),
                  //       )
                  //     : _noDataPlaceholder(),
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
                ],
              ),
            ),
          ),
        ),
      ),
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

  Widget _buildBarChart(List<BarChartGroupData> bars) {
    if (bars.isEmpty) return _noDataPlaceholder();

    return BarChart(
      BarChartData(
        borderData: FlBorderData(
            show: true,
            border: const Border(bottom: BorderSide(), left: BorderSide())),
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, _) {
                return Text(val.toInt().toString(),
                    style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, _) {
                return Text(val.toInt().toString(),
                    style: const TextStyle(fontSize: 10));
              },
            ),
          ),
        ),
        barGroups: bars,
      ),
    );
  }

  Widget _buildPieChart(Map<String, double> dataMap) {
    if (dataMap.isEmpty) return _noDataPlaceholder();

    return Row(
      children: [
        Expanded(
          child: pie_chart.PieChart(
            dataMap: dataMap,
            chartType: pie_chart.ChartType.ring,
            // chartRadius: 80,
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
            // spacing: 16,
            // runSpacing: 8,
            child: SingleChildScrollView(
          child: Column(
              children: dataMap.keys.map((k) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    width: 12,
                    height: 12,
                    color: Colors.primaries[dataMap.keys.toList().indexOf(k) %
                        Colors.primaries.length]),
                const SizedBox(width: 4),
                Text(k),
              ],
            );
          }).toList()),
        )),
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
