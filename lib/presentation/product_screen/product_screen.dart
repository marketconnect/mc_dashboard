import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:mc_dashboard/core/utils/dates.dart';
import 'package:mc_dashboard/presentation/product_screen/product_view_model.dart';
import 'package:pie_chart/pie_chart.dart' as pie_chart;
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// TODO Search btn color in dark theme
// TODO Add link on payments page and also tokenReset method
// TODO Add competitors analisis by https://identical-products.wildberries.ru/api/v1/identical?nmID=217712605
// TODO add subject name next to name
// TODO style AppBar
// TODO in the wb_api add token type checking for some methods
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
    final theme = Theme.of(context);
    final model = context.watch<ProductViewModel>();
    final id = model.productId;
    final onNavigateToEmptyProductScreen = model.onNavigateToEmptyProductScreen;
    final name = model.name;
    // final subjName = model.subjectName;
    final images = model.images;

    final price = model.productPrice;
    final rating = model.rating;

    // final stocks = model.stocks;
    final orders = model.orders;

    final dailyStockSums = model.dailyStocksSums;

    final pieDataMap = model.warehousesOrdersSum;
    final onNavigateBack = model.onNavigateBack;
    //
    final orders30d = model.orders30d;
    final priceHistoryData = model.priceHistory;

    List<DateTime> ordersDates =
        orders.map((e) => e['date'] as DateTime).toList();
    List<double> salesValues =
        orders.map((e) => (e['totalOrders'] as int).toDouble()).toList();

    List<DateTime> priceDates =
        priceHistoryData.map((e) => e['date'] as DateTime).toList();
    List<double> priceValues = priceHistoryData.map((e) {
      return (e["price"] as num).toDouble();
    }).toList();
    final wildberriesUrl =
        "https://wildberries.ru/catalog/${id}/detail.aspx?targetUrl=EX";
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => onNavigateBack(),
                              icon: Icon(
                                Icons.arrow_back_ios,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                name,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => onNavigateToEmptyProductScreen(),
                        icon: const Icon(Icons.search_sharp, size: 24),
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => launchUrl(Uri.parse(wildberriesUrl)),
                      child: Text(
                        'Артикул: $id',
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFF5166e3),
                          color: Color(0xFF5166e3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                      height: 400, child: ImageCarousel(imageUrls: images)),
                  const SizedBox(height: 24),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      if (price != 0)
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
                            isSales: true, valueSuffix: 'шт.'),
                      ),
                      _buildChartContainer(
                        title: 'Доля продаж по складам',
                        child: _buildPieChart(pieDataMap),
                      ),
                      _buildChartContainer(
                        title: 'История изменения цены',
                        child: _buildLineChart(priceDates, priceValues,
                            isSales: false, valueSuffix: '₽'),
                      ),
                      _buildChartContainer(
                          title: "История остатков",
                          child: BarChartWidget(dailyStockSums: dailyStockSums))
                    ],
                  ),
                  const SizedBox(height: 24),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1016),
                    child: StocksSectionWidget(),
                  ),
                  const SizedBox(height: 24),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1016),
                    child: _Feedback(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Ключевые запросы',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1016),
                    child: NormqueryTableWidget(),
                  ),
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

  Widget _buildLineChart(
    List<DateTime> dates,
    List<double> values, {
    required bool isSales,
    String valueSuffix = '',
  }) {
    if (dates.isEmpty || values.isEmpty || dates.length != values.length) {
      return _noDataPlaceholder();
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < dates.length; i++) {
      spots.add(FlSpot(i.toDouble(), values[i]));
    }

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                final index = touchedSpot.x.toInt(); // Индекс даты
                final value = touchedSpot.y.toInt(); // Значение графика
                if (index < 0 || index >= dates.length) {
                  return const LineTooltipItem('', TextStyle()); // Без данных
                }
                final date = dates[index];
                return LineTooltipItem(
                  '${_formatDate(date)}\n$value$valueSuffix', // Форматирование
                  const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(
          drawVerticalLine: true,
          drawHorizontalLine: true,
          horizontalInterval: values.isNotEmpty
              ? (values.reduce((a, b) => a > b ? a : b) / 5)
              : 1,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.3),
            strokeWidth: 0.5,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.3),
            strokeWidth: 0.5,
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(bottom: BorderSide(), left: BorderSide()),
        ),
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
                final valueText = val.toInt().toString();
                return Text(valueText, style: const TextStyle(fontSize: 10));
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

  /// Вспомогательный метод для форматирования даты
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} ${_monthName(date.month)}';
  }

  /// Метод для получения названия месяца
  String _monthName(int month) {
    const months = [
      'Янв',
      'Фев',
      'Мар',
      'Апр',
      'Май',
      'Июн',
      'Июл',
      'Авг',
      'Сен',
      'Окт',
      'Ноя',
      'Дек'
    ];
    return months[month - 1];
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
}

class _Feedback extends StatelessWidget {
  const _Feedback();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ProductViewModel>();
    final ratingDistribution = model.ratingDistribution;

    final totalCount =
        ratingDistribution.values.fold(0, (sum, count) => sum + count);

    if (totalCount == 0) {
      return SizedBox();
    }
    final ratingsData = ratingDistribution.entries.map((entry) {
      final rating = entry.key;
      final count = entry.value;

      return [rating, '$count шт.', '${(count * 100 / totalCount).ceil()}%'];
    }).toList()
      ..sort((a, b) => int.parse(a[0]).compareTo(int.parse(b[0])));

    return LayoutBuilder(builder: (context, constraints) {
      final maxWidth = constraints.maxWidth;

      final isMobile = maxWidth < 600;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Распределение оценок',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ratingsData.isNotEmpty
                      ? _buildTable(
                          context,
                          columns: const ['Оценка', 'Количество', 'Процент'],
                          rows: ratingsData,
                        )
                      : _noDataPlaceholder(),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  if (model.pros.isNotEmpty) ...[
                    Text(
                      'Плюсы:',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildProsList(context, model.pros),
                  ] else
                    Text(
                      'Нет плюсов',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  const SizedBox(height: 16),
                  if (model.cons.isNotEmpty) ...[
                    Text(
                      'Минусы:',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildConsList(context, model.cons),
                  ] else
                    Text(
                      'Нет минусов',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Распределение оценок',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ratingsData.isNotEmpty
                            ? _buildTable(
                                context,
                                columns: const [
                                  'Оценка',
                                  'Количество',
                                  'Процент'
                                ],
                                rows: ratingsData,
                              )
                            : _noDataPlaceholder(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (model.pros.isNotEmpty) ...[
                          Text(
                            'Плюсы:',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          _buildProsList(context, model.pros),
                          const SizedBox(height: 24),
                        ] else
                          Text(
                            'Нет плюсов',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        if (model.cons.isNotEmpty) ...[
                          Text(
                            'Минусы:',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          _buildConsList(context, model.cons),
                        ] else
                          Text(
                            'Нет минусов',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
      );
    });
  }

  Widget _buildProsList(BuildContext context, List<String> pros) {
    final ScrollController scrollController = ScrollController();
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Scrollbar(
        controller: scrollController,
        thumbVisibility: true,
        child: ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(8.0),
          itemCount: pros.length,
          itemBuilder: (context, index) {
            final pro = pros[index];
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
          },
        ),
      ),
    );
  }

  Widget _buildConsList(BuildContext context, List<String> cons) {
    final ScrollController scrollController = ScrollController();
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Scrollbar(
        controller: scrollController,
        thumbVisibility: true,
        child: ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(8.0),
          itemCount: cons.length,
          itemBuilder: (context, index) {
            final con = cons[index];
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
          },
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

class ImageCarousel extends StatelessWidget {
  final List<String> imageUrls;

  const ImageCarousel({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 800,
        enlargeCenterPage: true,
        autoPlay: true,
        // aspectRatio: 9 / 12,
        autoPlayCurve: Curves.easeInOut,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: Duration(milliseconds: 800),
        viewportFraction: 0.4,
      ),
      items: imageUrls.map((imgUrl) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                image: DecorationImage(
                  image: NetworkImage(imgUrl),
                  fit: BoxFit.contain,
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

class BarChartWidget extends StatelessWidget {
  final Map<String, int> dailyStockSums;

  const BarChartWidget({super.key, required this.dailyStockSums});

  @override
  Widget build(BuildContext context) {
    final dates = dailyStockSums.keys.toList();
    final values = dailyStockSums.values.toList();

    if (dailyStockSums.isEmpty) {
      return const Center(child: Text("Нет данных"));
    }

    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < dates.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: values[i].toDouble(),
              color: Colors.blue,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        barGroups: barGroups,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, _) {
                int index = val.toInt();
                final keys = dates;

                if (index < 0 || index >= keys.length) return const SizedBox();

                if (index % 5 != 0) return const SizedBox();

                final dateKey = keys[index];
                return Text(
                  formatDate(dateKey),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, _) {
                return Text(
                  val.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          drawVerticalLine: true,
          drawHorizontalLine: true,
          horizontalInterval: values.isNotEmpty
              ? (values.reduce((a, b) => a > b ? a : b) / 5).ceilToDouble()
              : 1,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.3),
            strokeWidth: 0.5,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.3),
            strokeWidth: 0.5,
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(bottom: BorderSide(), left: BorderSide()),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${formatDate(dates[group.x])}\n${rod.toY.toInt()} шт',
                const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class StocksSectionWidget extends StatelessWidget {
  const StocksSectionWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final model = context.watch<ProductViewModel>();
    final warehouseShares = model.warehouseShares;
    final totalWhStocks = model.totalWhStocks;

    if (warehouseShares.isEmpty) {
      return Center(
        child: Text(
          'Нет данных об остатках',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    // Prepare data for PieChart
    final pieDataMap = {
      for (var warehouse in warehouseShares)
        warehouse["name"].toString():
            (warehouse["value"] as int).toDouble() / totalWhStocks * 100,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isMobile = maxWidth < 600;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Остатки по складам',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (isMobile)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTable(
                    theme,
                    columns: const ['Склад', 'Количество', 'Доля'],
                    rows: warehouseShares.map((warehouse) {
                      return [
                        warehouse["name"].toString(),
                        warehouse["value"].toString(),
                        totalWhStocks > 0
                            ? "${(warehouse["value"] / totalWhStocks * 100).toStringAsFixed(1)} %"
                            : "0.0 %",
                      ];
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: AspectRatio(
                      aspectRatio: 1, // Пропорциональное соотношение для круга
                      child: _buildPieChart(context, pieDataMap),
                    ),
                  ),
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1, // Относительная ширина для таблицы
                    child: _buildTable(
                      theme,
                      columns: const ['Склад', 'Количество', 'Доля'],
                      rows: warehouseShares.map((warehouse) {
                        return [
                          warehouse["name"].toString(),
                          warehouse["value"].toString(),
                          totalWhStocks > 0
                              ? "${(warehouse["value"] / totalWhStocks * 100).toStringAsFixed(1)} %"
                              : "0.0 %",
                        ];
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    flex: 1, // Относительная ширина для диаграммы
                    child: AspectRatio(
                      aspectRatio: 1, // Пропорциональное соотношение для круга
                      child: _buildPieChart(context, pieDataMap),
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _buildTable(ThemeData theme,
      {required List<String> columns, required List<List<String>> rows}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Table(
        columnWidths: {
          for (var i = 0; i < columns.length; i++) i: const FlexColumnWidth(),
        },
        border: TableBorder.all(color: theme.dividerColor),
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
            ),
            children: columns
                .map((column) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        column,
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ))
                .toList(),
          ),
          for (var row in rows)
            TableRow(
              children: row
                  .map((cell) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          cell,
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPieChart(BuildContext context, Map<String, double> dataMap) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: pie_chart.PieChart(
        dataMap: dataMap,
        chartType: pie_chart.ChartType.disc,
        baseChartColor: Colors.grey[200]!, // Цвет фона
        chartRadius: MediaQuery.of(context).size.width / 5, // Размер диаграммы
        chartValuesOptions: const pie_chart.ChartValuesOptions(
          showChartValuesInPercentage: true,
          showChartValuesOutside: false,
        ),
        legendOptions: const pie_chart.LegendOptions(
          showLegendsInRow: true,
          legendPosition: pie_chart.LegendPosition.bottom,
        ),
      ),
    );
  }
}

class NormqueryTableWidget extends StatefulWidget {
  const NormqueryTableWidget({super.key});

  @override
  State<NormqueryTableWidget> createState() => _NormqueryTableWidgetState();
}

class _NormqueryTableWidgetState extends State<NormqueryTableWidget> {
  late TableViewController tableViewController;
  final Set<int> selectedIndices = {}; // Хранит индексы выбранных строк
  bool selectAll = false; // Управляет выбором всех строк

  @override
  void initState() {
    super.initState();
    tableViewController = TableViewController();
  }

  @override
  void dispose() {
    tableViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final model = context.watch<ProductViewModel>();
    final paymentUrl = model.paymentUrl;
    final normqueryProducts = model.normqueries;

    if (normqueryProducts.isEmpty) {
      return _noDataPlaceholder();
    }

    final columnProportions = [0.05, 0.3, 0.1, 0.1, 0.1];
    final mobColumnProportions = [0.1, 0.4, 0.15, 0.15, 0.15];
    final columnHeaders = [
      "Выбор",
      "Ключевой запрос",
      "Позиция",
      "Частота",
      "Всего товаров",
    ];

    return Stack(
      children: [
        LayoutBuilder(builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;

          final isMobile = maxWidth < 600;

          final proportions =
              isMobile ? mobColumnProportions : columnProportions;
          final columns = proportions
              .map((widthFraction) => TableColumn(
                  width: widthFraction * MediaQuery.of(context).size.width))
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4)
                  ],
                ),
                child: SizedBox(
                  height: 400,
                  child: TableView.builder(
                    controller: tableViewController,
                    columns: columns,
                    rowHeight: 40,
                    rowCount: normqueryProducts.length,
                    headerBuilder: (context, contentBuilder) {
                      return contentBuilder(context, (context, columnIndex) {
                        if (columnIndex == 0) {
                          return Checkbox(
                            value: selectAll,
                            onChanged: (value) {
                              setState(() {
                                selectAll = value ?? false;
                                if (selectAll) {
                                  selectedIndices.addAll(List.generate(
                                      normqueryProducts.length,
                                      (index) => index));
                                } else {
                                  selectedIndices.clear();
                                }
                              });
                            },
                          );
                        }
                        return Container(
                          alignment: Alignment.center,
                          child: Text(
                            columnHeaders[columnIndex],
                          ),
                        );
                      });
                    },
                    rowBuilder: (context, rowIndex, contentBuilder) {
                      final product = normqueryProducts[rowIndex];
                      final rowValues = [
                        product.normquery,
                        ((product.pageNumber - 1) * 100 + product.pagePos)
                            .toString(),
                        product.freq.toString(),
                        product.total.toString(),
                      ];

                      return contentBuilder(context, (context, columnIndex) {
                        if (columnIndex == 0) {
                          return Checkbox(
                            value: selectedIndices.contains(rowIndex),
                            onChanged: (isSelected) {
                              setState(() {
                                if (isSelected == true) {
                                  selectedIndices.add(rowIndex);
                                  if (selectedIndices.length ==
                                      normqueryProducts.length) {
                                    selectAll = true;
                                  }
                                } else {
                                  selectedIndices.remove(rowIndex);
                                  selectAll = false;
                                }
                              });
                            },
                          );
                        }

                        final value = rowValues[columnIndex - 1];
                        return Container(
                          alignment: columnIndex == 1
                              ? Alignment.centerLeft
                              : Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            value,
                            style: theme.textTheme.bodyMedium,
                          ),
                        );
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // TODO add something
                  final selectedItems = selectedIndices
                      .map((index) => normqueryProducts[index])
                      .toList();
                },
                child: const Text('Показать выбранные'),
              ),
            ],
          );
        }),
        if (model.isFree)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                if (paymentUrl != null) {
                  launchUrl(Uri.parse(paymentUrl));
                }
                return;
              },
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.black.withOpacity(0.2),
                    alignment: Alignment.center,
                    child: Text(
                      "Доступно только для подписчиков",
                      style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _noDataPlaceholder() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.info, color: Colors.grey),
        SizedBox(width: 8),
        Text('Нет данных для отображения'),
      ],
    );
  }
}
