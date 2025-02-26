// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:pie_chart/pie_chart.dart' as pie_chart;
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mc_dashboard/core/utils/dates.dart';
import 'package:mc_dashboard/presentation/product_screen/product_view_model.dart';
import 'package:mc_dashboard/presentation/product_screen/table_row_model.dart';
import 'package:mc_dashboard/presentation/widgets/check_box.dart';
import 'package:mc_dashboard/theme/color_schemes.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  String selectedPeriod = '30 дней';
  final List<String> periods = ['7 дней', '30 дней', '90 дней', 'год'];

  //
  final ScrollController _scrollController = ScrollController();
  bool _showBackFAB = false;
  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      setState(() {
        _showBackFAB = _scrollController.offset > 600;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final model = context.watch<ProductViewModel>();
    final id = model.productId;
    final onNavigateToEmptyProductScreen = model.onNavigateToEmptyProductScreen;
    final name = model.name;
    final subjectName = model.subjectName;
    final subjectId = model.subjectId;
    final price = model.price;
    final rating = model.rating;
    final productTariff = model.productTariff;
    final logisticsTariff = model.logisticsTariff;
    final orders = model.orders;
    final dailyStockSums = model.dailyStocksSums;
    final pieDataMap = model.warehousesOrdersSum;
    final onNavigateBack = model.onNavigateBack;
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
        "https://wildberries.ru/catalog/$id/detail.aspx?targetUrl=EX";

    return LayoutBuilder(builder: (context, constraints) {
      final maxWidth = constraints.maxWidth;
      // final maxHeight = constraints.maxHeight;

      final isMobile = maxWidth < 600;

      return Scaffold(
        body: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    children: [
                      Padding(
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
                                        onPressed: onNavigateBack,
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
                                          style: isMobile
                                              ? Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall
                                              : Theme.of(context)
                                                  .textTheme
                                                  .headlineMedium
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: onNavigateToEmptyProductScreen,
                                      icon: const Icon(Icons.search_sharp,
                                          size: 24),
                                      color: theme.colorScheme.primary,
                                      tooltip: 'Поиск по артикулу',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            MouseRegion(
                              // Артикул
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () =>
                                    launchUrl(Uri.parse(wildberriesUrl)),
                                child: Text(
                                  'Артикул: $id',
                                  style: TextStyle(
                                    fontSize: isMobile ? 12 : null,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Color(0xFF5166e3),
                                    color: Color(0xFF5166e3),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  'Категория:',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w300),
                                ),
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () => model
                                        .onNavigateToSubjectProductsScreen(),
                                    child: Row(
                                      children: [
                                        Text(
                                          ' $subjectName',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(Icons.arrow_forward_ios, size: 12),
                                      ],
                                    ),
                                  ),
                                ),
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    //Copy to clipboard
                                    onTap: () => Clipboard.setData(
                                        ClipboardData(
                                            text: subjectId.toString())),
                                    child: Row(
                                      children: [
                                        Text(
                                          '$subjectId',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(Icons.copy, size: 12),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                                height: 400,
                                child: ImageCarousel(
                                  isMobile: isMobile,
                                )),
                            const SizedBox(height: 24),
                            if (!isMobile) const SizedBox(height: 24),
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                if (price != 0)
                                  _buildStatCard(
                                      'Цена', '${_formatPrice(price)} ₽'),
                                _buildStatCard(
                                    'Продажи за 30 дней', '$orders30d шт.'),
                                _buildStatCard('Рейтинг', '$rating ★'),
                                if (productTariff != null && price != 0)
                                  _buildStatCard('Комиссия',
                                      '${productTariff.paidStorageKgvp} % ${(price * productTariff.paidStorageKgvp / 100).ceil()} ₽'),
                                if (logisticsTariff != 0)
                                  _buildStatCard('Логистика (FBS)',
                                      '${logisticsTariff.ceil()} ₽'),
                                if (price != 0 &&
                                    productTariff != null &&
                                    logisticsTariff != 0)
                                  _buildProfitCard(
                                    'Доход после WB',
                                    price,
                                    productTariff.paidStorageKgvp,
                                    logisticsTariff,
                                    context
                                        .watch<ProductViewModel>()
                                        .returnRate, // Передаем процент возвратов
                                    () => context
                                        .read<ProductViewModel>()
                                        .increaseDiscount(),
                                    () => context
                                        .read<ProductViewModel>()
                                        .decreaseDiscount(),
                                    () => context
                                        .read<ProductViewModel>()
                                        .increaseReturnRate(), // Увеличить возвраты
                                    () => context
                                        .read<ProductViewModel>()
                                        .decreaseReturnRate(), // Уменьшить возвраты
                                  ),
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
                                  child: _buildLineChart(
                                    ordersDates,
                                    salesValues,
                                    isSales: true,
                                    valueSuffix: 'шт.',
                                  ),
                                ),
                                _buildChartContainer(
                                  title: 'Доля продаж по складам',
                                  child: _buildPieChart(pieDataMap),
                                ),
                                _buildChartContainer(
                                  title: 'История изменения цены',
                                  child: _buildLineChart(
                                    priceDates,
                                    priceValues,
                                    isSales: false,
                                    valueSuffix: '₽',
                                  ),
                                ),
                                _buildChartContainer(
                                  title: "История остатков",
                                  child: BarChartWidget(
                                      dailyStockSums: dailyStockSums),
                                )
                              ],
                            ),
                            const SizedBox(height: 24),
                            if (!model.isLoading)
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 1016),
                                child: StocksSectionWidget(),
                              ),
                            const SizedBox(height: 24),
                            if (!model.isLoading)
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 1016),
                                child: _Feedback(),
                              ),
                            const SizedBox(height: 24),
                            if (model.normqueriesLoaded)
                              Text(
                                "Поисковые запросы",
                                style: theme.textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            const SizedBox(height: 8),
                            if (model.normqueriesLoaded)
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 1016),
                                child: NormqueryTableWidget(),
                              ),
                            const SizedBox(height: 24),
                            if (model.seoLoaded) ...[
                              const SizedBox(height: 16),
                              Text(
                                "Анализ релевантности",
                                style: theme.textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              if (model.seoTableSections.isNotEmpty)
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 1016),
                                  child: SeoSectionWidget(
                                    sectionTitle: "Заголовок",
                                    sectionText: name,
                                    querySimilarities:
                                        model.seoTableSections["title"] ?? [],
                                  ),
                                ),
                              const SizedBox(height: 16),
                              if (model.seoTableSections.isNotEmpty)
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 1016),
                                  child: SeoSectionWidget(
                                    sectionTitle: "Характеристики",
                                    sectionText: model.characteristics,
                                    querySimilarities: model.seoTableSections[
                                            "characteristics"] ??
                                        [],
                                  ),
                                ),
                              const SizedBox(height: 16),
                              if (model.seoTableSections.isNotEmpty)
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 1016),
                                  child: SeoSectionWidget(
                                    sectionTitle: "Описание",
                                    sectionText: model.description,
                                    querySimilarities:
                                        model.seoTableSections["description"] ??
                                            [],
                                  ),
                                ),
                            ],
                            const SizedBox(height: 24),
                            if (!model.isLoading &&
                                model.unusedQueriesLoaded) ...[
                              Text(
                                "Упущенные запросы",
                                style: theme.textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 1016),
                                child: UnusedQueryTableWidget(),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          alignment: Alignment.center,
                          width: isMobile ? null : constraints.maxWidth * 0.6,
                          margin: const EdgeInsets.only(bottom: 24),
                          child: Row(
                            mainAxisAlignment: isMobile
                                ? MainAxisAlignment.center
                                : MainAxisAlignment.end,
                            children: [
                              if (!model.normqueriesLoaded)
                                FloatingActionButton.extended(
                                  heroTag: 'queriesFab',
                                  backgroundColor:
                                      theme.colorScheme.surfaceContainerHighest,
                                  label: const Text("Поисковые запросы",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  // icon: const Icon(Icons.search),
                                  onPressed: () async {
                                    await model.loadNormqueries();
                                  },
                                ),
                              // const SizedBox(width: 8),

                              // Анализ релевантности
                              if (model.normqueriesLoaded &&
                                  !model.seoLoaded &&
                                  model.normqueries.isNotEmpty)
                                FloatingActionButton.extended(
                                  heroTag: 'seoFab',
                                  label: const Text("Анализ релевантности",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  backgroundColor:
                                      theme.colorScheme.surfaceContainerHighest,
                                  onPressed: () async {
                                    if (!model.normqueriesLoaded) {
                                      await model.loadNormqueries();
                                    }
                                    await model.loadSeo();
                                  },
                                ),
                              // const SizedBox(width: 8),
                              if (model.normqueriesLoaded &&
                                  !model.unusedQueriesLoaded)
                                const SizedBox(width: 8),
                              // Упущенные запросы
                              if (model.normqueriesLoaded &&
                                  !model.unusedQueriesLoaded)
                                FloatingActionButton.extended(
                                  heroTag: 'unusedFab',
                                  label: const Text("Упущенные запросы",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  backgroundColor:
                                      theme.colorScheme.surfaceContainerHighest,
                                  onPressed: () async {
                                    await model.loadUnusedQueries();
                                  },
                                ),
                              // const SizedBox(width: 28),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
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
        ),
      );
    });
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

  Widget _buildProfitCard(
      String title,
      int price,
      double commissionRate,
      double logistics,
      double returnRate, // Процент возвратов
      VoidCallback onIncreaseDiscount,
      VoidCallback onDecreaseDiscount,
      VoidCallback onIncreaseReturn,
      VoidCallback onDecreaseReturn) {
    final model = context.watch<ProductViewModel>();
    final int wbDiscount = model.wbDiscount;

    // Рассчитываем новую цену с учетом WB скидки
    final double discountedPrice = price * (1 + wbDiscount / 100);

    // Рассчитываем комиссию от новой цены
    final double commission = discountedPrice * (commissionRate / 100);

    // Стоимость возвратов по исправленной формуле
    final double returnLogisticsCost =
        50.0; // Фиксированная цена обратной логистики
    final double totalReturnCost =
        (logistics + returnLogisticsCost) * (returnRate / (100 - returnRate));

    // Итоговая сумма после вычета комиссии, логистики и возвратов
    final double netAmount =
        discountedPrice - commission - logistics - totalReturnCost;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '${netAmount.toStringAsFixed(2)} ₽',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Divider(),
            const SizedBox(height: 4),
            Text(
              "📌 Формула расчета:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "($price ₽ + $price ₽ * ($wbDiscount%)) - "
              "\n(${commission.toStringAsFixed(2)} ₽ комиссия) - "
              "\n(${logistics.toStringAsFixed(2)} ₽ логистика) - "
              "\n(${totalReturnCost.toStringAsFixed(2)} ₽ возвраты)",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      'WB Скидка: $wbDiscount%',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: onDecreaseDiscount,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: onIncreaseDiscount,
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Процент возвратов: ${returnRate.toStringAsFixed(1)}%',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: onDecreaseReturn,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: onIncreaseReturn,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    final theme = Theme.of(context);
    final model = context.read<ProductViewModel>();

    return model.isLoading
        ? Shimmer(
            gradient: Theme.of(context).colorScheme.shimmerGradient,
            child: Container(
              width: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(2),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "title",
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "value",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          )
        : Container(
            width: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4)
              ],
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
    final model = context.read<ProductViewModel>();

    return model.isLoading
        ? Shimmer(
            gradient: Theme.of(context).colorScheme.shimmerGradient,
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4)
                  ]),
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
            ),
          )
        : Container(
            width: 500,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4)
                ]),
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
            color: Colors.grey.withAlpha((0.3 * 255).toInt()),
            strokeWidth: 0.5,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: Colors.grey.withAlpha((0.3 * 255).toInt()),
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
                          columns: const ['Оценка', 'Количество', '%'],
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
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
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
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
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
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
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
              color: theme.colorScheme.primary.withAlpha((0.1 * 255).toInt()),
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
  const ImageCarousel({super.key, required this.isMobile});
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ProductViewModel>();
    final images = model.images;

    if (images.isEmpty) {
      return Shimmer(
        gradient: Theme.of(context).colorScheme.shimmerGradient,
        child: Container(
          height: 800,
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.grey,
          ),
        ),
      );
    }

    return CarouselSlider.builder(
      itemCount: images.length,
      options: CarouselOptions(
        height: isMobile ? 400 : 800,
        enlargeCenterPage: true,
        autoPlay: true,
        autoPlayCurve: Curves.easeInOut,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: Duration(milliseconds: 800),
        viewportFraction: isMobile ? 0.8 : 0.4,
      ),
      itemBuilder: (context, index, realIndex) {
        final imgUrl = images[index];
        return GestureDetector(
          onTap: () => _downloadImage(imgUrl),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 5.0),
            decoration: BoxDecoration(
              // border: isMobile
              //     ? Border.all(
              //         color: Colors.grey,
              //       )
              //     : null,
              borderRadius: BorderRadius.circular(8.0),
              image: DecorationImage(
                image: NetworkImage(imgUrl),
                fit: isMobile ? BoxFit.scaleDown : BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

  void _downloadImage(String imageUrl) {
    html.window.open(imageUrl, '_blank');
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
            color: Colors.grey.withAlpha((0.3 * 255).toInt()),
            strokeWidth: 0.5,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: Colors.grey.withAlpha((0.3 * 255).toInt()),
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
                      aspectRatio: 2 / 3,
                      child: _buildPieChart(context, pieDataMap, isMobile),
                    ),
                  ),
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
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
                      child: _buildPieChart(context, pieDataMap, isMobile),
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
              color: theme.colorScheme.primary.withAlpha((0.1 * 255).toInt()),
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

  Widget _buildPieChart(
      BuildContext context, Map<String, double> dataMap, bool isMobile) {
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
        baseChartColor: Colors.grey[200]!,
        chartRadius: isMobile
            ? MediaQuery.of(context).size.width / 2
            : MediaQuery.of(context).size.width / 5,
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

  int? _sortColumnIndex; // Индекс сортируемого столбца
  bool _sortAscending = true; // Направление сортировки

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

  void _sortData(int columnIndex) {
    setState(() {
      if (_sortColumnIndex == columnIndex) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumnIndex = columnIndex;
        _sortAscending = true;
      }

      context.read<ProductViewModel>().normqueries.sort((a, b) {
        int compare;
        switch (columnIndex) {
          case 1: // Ключевой запрос
            compare = a.normquery.compareTo(b.normquery);
            break;
          case 2: // Позиция
            compare = ((a.pageNumber - 1) * 100 + a.pagePos)
                .compareTo((b.pageNumber - 1) * 100 + b.pagePos);
            break;
          case 3: // Частота
            compare = a.freq.compareTo(b.freq);
            break;
          case 4: // Всего товаров
            compare = a.total.compareTo(b.total);
            break;
          default:
            compare = 0;
        }
        return _sortAscending ? compare : -compare;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final model = context.watch<ProductViewModel>();

    final normqueryProducts = model.normqueries;

    if (normqueryProducts.isEmpty) {
      return _noDataPlaceholder();
    }

    final columnProportions = [0.03, 0.2, 0.1, 0.1, 0.1];
    final mobColumnProportions = [0.1, 0.3, 0.2, 0.15, 0.15];
    final columnHeaders = [
      "Выбор",
      "Ключевой запрос",
      "Позиция товара",
      "Частота (нед.)",
      "Всего товаров",
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final maxWidth = constraints.maxWidth;

      final isMobile = maxWidth < 600;

      final proportions = isMobile ? mobColumnProportions : columnProportions;
      final columns = proportions
          .map((widthFraction) => TableColumn(
              width: widthFraction * MediaQuery.of(context).size.width))
          .toList();

      return Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
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
                      return McCheckBox(
                        value: selectAll,
                        theme: theme,
                        onChanged: (value) {
                          setState(() {
                            selectAll = value ?? false;
                            if (selectAll) {
                              selectedIndices.addAll(List.generate(
                                  normqueryProducts.length, (index) => index));
                            } else {
                              selectedIndices.clear();
                            }
                          });
                        },
                      );
                    }
                    return GestureDetector(
                      onTap: () => _sortData(columnIndex),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            columnHeaders[columnIndex],
                          ),
                          if (_sortColumnIndex == columnIndex)
                            Icon(
                              _sortAscending
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              size: 16,
                            ),
                        ],
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
                      return McCheckBox(
                        value: selectedIndices.contains(rowIndex),
                        theme: theme,
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
                    return GestureDetector(
                      onTap: () {
                        if (columnIndex == 1) {
                          final wildberriesUrl =
                              "https://www.wildberries.ru/catalog/0/search.aspx?search=$value";
                          launchUrl(Uri.parse(wildberriesUrl));
                        }
                      },
                      child: Container(
                        alignment: columnIndex == 1
                            ? Alignment.centerLeft
                            : Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: MouseRegion(
                          cursor: columnIndex == 1
                              ? SystemMouseCursors.click
                              : MouseCursor.defer,
                          child: Text(
                            value,
                            style: columnIndex == 1
                                ? const TextStyle(
                                    decoration: TextDecoration.underline,
                                    decorationColor: Color(0xFF5166e3),
                                    color: Color(0xFF5166e3),
                                  )
                                : theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    );
                  });
                },
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
                    selectAll = false;
                  });
                },
                children: [
                  SpeedDialChild(
                    backgroundColor: theme.colorScheme.secondary,
                    child:
                        Icon(Icons.copy, color: theme.colorScheme.onSecondary),
                    label: "Копировать",
                    labelStyle: TextStyle(
                        fontSize: theme.textTheme.bodyLarge!.fontSize),
                    onTap: () {
                      // Получение выбранных элементов
                      final selectedItems = selectedIndices
                          .map((index) => normqueryProducts[index])
                          .toList();

                      if (selectedItems.isEmpty) {
                        // Если ничего не выбрано, можно уведомить пользователя
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Нет выбранных элементов для копирования')),
                        );
                        return;
                      }

                      // Формирование строки для копирования
                      final clipboardContent = selectedItems.map((product) {
                        return '${product.normquery}\t${((product.pageNumber - 1) * 100 + product.pagePos)}\t${product.freq}\t${product.total}';
                      }).join('\n'); // Разделитель строк - перенос
                      final clipboardContentWithColumnNames =
                          'Ключевой запрос\tПозиция\tЧастота\tВсего товаров\n$clipboardContent';
                      // Копирование данных в буфер обмена
                      Clipboard.setData(
                          ClipboardData(text: clipboardContentWithColumnNames));

                      // Уведомление пользователя о выполнении копирования
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Данные скопированы в буфер обмена')),
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      );
    });
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

class SeoSectionWidget extends StatefulWidget {
  final String sectionTitle;
  final String sectionText;
  final List<SEOTableRowModel> querySimilarities;

  const SeoSectionWidget({
    super.key,
    required this.sectionTitle,
    required this.sectionText,
    required this.querySimilarities,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SeoSectionWidgetState createState() => _SeoSectionWidgetState();
}

class _SeoSectionWidgetState extends State<SeoSectionWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final model = context.watch<ProductViewModel>();
    final getSeoNameDescChar = model.getSeoNameDescChar;

    final visibleRows = _isExpanded
        ? widget.querySimilarities
        : widget.querySimilarities.take(5).toList();

    return Container(
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
            widget.sectionTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.sectionText,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          widget.querySimilarities.isEmpty
              ? _noDataPlaceholder()
              : Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1),
                  },
                  border: TableBorder.all(color: theme.dividerColor),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary
                            .withAlpha((0.1 * 255).toInt()),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Ключевой запрос',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Релевантность',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Частотность',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    ...visibleRows.map((row) {
                      final similarities = widget.sectionTitle == 'Заголовок'
                          ? row.titleSimilarity
                          : widget.sectionTitle == 'Описание'
                              ? row.descriptionSimilarity
                              : widget.sectionTitle == 'Характеристики'
                                  ? row.characteristicsSimilarity
                                  : 0.0;

                      return TableRow(
                        children: [
                          Tooltip(
                            message: getSeoNameDescChar(row.normquery),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                row.normquery,
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${(similarities * 100).toStringAsFixed(1)}%',
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('${row.freq}'),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Text(
              _isExpanded ? 'Свернуть' : 'Показать больше',
              style: const TextStyle(
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFF5166e3),
                color: Color(0xFF5166e3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _noDataPlaceholder() {
    return Center(child: Text("Нет данных для отображения"));
  }
}

class UnusedQueryTableWidget extends StatefulWidget {
  const UnusedQueryTableWidget({super.key});

  @override
  State<UnusedQueryTableWidget> createState() => _UnusedQueryTableWidgetState();
}

class _UnusedQueryTableWidgetState extends State<UnusedQueryTableWidget> {
  late TableViewController tableViewController;
  final Set<int> selectedIndices = {};
  bool selectAll = false;

  int? _sortColumnIndex;
  bool _sortAscending = true;

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

  void _sortData(int columnIndex) {
    setState(() {
      if (_sortColumnIndex == columnIndex) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumnIndex = columnIndex;
        _sortAscending = true;
      }

      context.read<ProductViewModel>().unusedNormqueries.sort((a, b) {
        int compare;
        switch (columnIndex) {
          case 1:
            compare = a.normquery.compareTo(b.normquery);
            break;
          case 2:
            compare = a.freq.compareTo(b.freq);
            break;
          case 3:
            compare = a.total.compareTo(b.total);
            break;
          default:
            compare = 0;
        }
        return _sortAscending ? compare : -compare;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final model = context.watch<ProductViewModel>();

    final unusedQueries = model.unusedNormqueries;

    if (unusedQueries.isEmpty) {
      return _noDataPlaceholder();
    }

    final columnProportions = [0.05, 0.4, 0.2, 0.2];
    final mobColumnProportions = [0.1, 0.4, 0.25, 0.25];
    final columnHeaders = [
      "Выбор",
      "Ключевой запрос",
      "Частота (нед.)",
      "Всего товаров",
    ];

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: SizedBox(
            height: 400,
            child: LayoutBuilder(builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final isMobile = maxWidth < 600;
              final proportions =
                  isMobile ? mobColumnProportions : columnProportions;
              final columns = proportions
                  .map((widthFraction) =>
                      TableColumn(width: widthFraction * maxWidth))
                  .toList();

              return TableView.builder(
                controller: tableViewController,
                columns: columns,
                rowHeight: 40,
                rowCount: unusedQueries.length,
                headerBuilder: (context, contentBuilder) {
                  return contentBuilder(context, (context, columnIndex) {
                    if (columnIndex == 0) {
                      return McCheckBox(
                          value: selectAll,
                          theme: theme,
                          onChanged: (value) {
                            setState(() {
                              selectAll = value ?? false;
                              if (selectAll) {
                                selectedIndices.addAll(
                                  List.generate(
                                    unusedQueries.length,
                                    (index) => index,
                                  ),
                                );
                              } else {
                                selectedIndices.clear();
                              }
                            });
                          });
                    }

                    return GestureDetector(
                      onTap: () => _sortData(columnIndex),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(columnHeaders[columnIndex]),
                          if (_sortColumnIndex == columnIndex)
                            Icon(
                              _sortAscending
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              size: 16,
                            ),
                        ],
                      ),
                    );
                  });
                },
                rowBuilder: (context, rowIndex, contentBuilder) {
                  final item = unusedQueries[rowIndex];
                  final rowValues = [
                    item.normquery,
                    item.freq.toString(),
                    item.total.toString(),
                  ];

                  return contentBuilder(context, (context, columnIndex) {
                    if (columnIndex == 0) {
                      return McCheckBox(
                        value: selectedIndices.contains(rowIndex),
                        theme: theme,
                        onChanged: (isSelected) {
                          setState(() {
                            if (isSelected == true) {
                              selectedIndices.add(rowIndex);
                              if (selectedIndices.length ==
                                  unusedQueries.length) {
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
                    return GestureDetector(
                      onTap: () {
                        if (columnIndex == 1) {
                          final wildberriesUrl =
                              "https://www.wildberries.ru/catalog/0/search.aspx?search=$value";
                          launchUrl(Uri.parse(wildberriesUrl));
                        }
                      },
                      child: Container(
                        alignment: columnIndex == 1
                            ? Alignment.centerLeft
                            : Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: MouseRegion(
                          cursor: columnIndex == 1
                              ? SystemMouseCursors.click
                              : MouseCursor.defer,
                          child: Text(
                            value,
                            style: columnIndex == 1
                                ? const TextStyle(
                                    decoration: TextDecoration.underline,
                                    decorationColor: Color(0xFF5166e3),
                                    color: Color(0xFF5166e3),
                                  )
                                : theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    );
                  });
                },
              );
            }),
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
                  selectAll = false;
                });
              },
              children: [
                SpeedDialChild(
                  backgroundColor: theme.colorScheme.secondary,
                  child: Icon(Icons.copy, color: theme.colorScheme.onSecondary),
                  label: "Копировать",
                  labelStyle:
                      TextStyle(fontSize: theme.textTheme.bodyLarge!.fontSize),
                  onTap: () {
                    final selectedItems = selectedIndices
                        .map((index) => unusedQueries[index])
                        .toList();

                    if (selectedItems.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Нет выбранных элементов для копирования')),
                      );
                      return;
                    }

                    final clipboardContent = selectedItems.map((product) {
                      return '${product.normquery}\t${product.freq}\t${product.total}';
                    }).join('\n');
                    final clipboardContentWithColumnNames =
                        'Ключевой запрос\tЧастота\tВсего товаров\n$clipboardContent';

                    Clipboard.setData(
                        ClipboardData(text: clipboardContentWithColumnNames));

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Данные скопированы в буфер обмена')),
                    );
                  },
                ),
              ],
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
