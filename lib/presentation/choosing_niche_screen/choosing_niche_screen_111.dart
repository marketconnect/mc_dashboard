// import 'package:flutter/material.dart';

// class ChoosingNixxcheScreen extends StatefulWidget {
//   const ChoosingNixxcheScreen({Key? key}) : super(key: key);

//   @override
//   State<ChoosingNixxcheScreen> createState() => _ChoosingNicheScreenState();
// }

// class _ChoosingNicheScreenState extends State<ChoosingNicheScreen> {
//   final List<String> metrics = [
//     "Выручка",
//     "Количество товаров",
//     "Количество заказов",
//     "Товары с заказами"
//   ];
//   String selectedMetric = "Выручка";

//   @override
//   Widget build(BuildContext context) {
//     final model = context.watch<ChoosingNicheViewModel>();
//     final theme = Theme.of(context);
//     final isMobile = MediaQuery.of(context).size.width < 600;
//     final selectedParentName = model.selectedParentName ?? 'Не выбрано';

//     return Scaffold(
//       body: Column(
//         children: [
//           // Верхняя часть: две диаграммы
//           Container(
//             padding: const EdgeInsets.all(16),
//             child: isMobile
//                 ? Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Данные для: $selectedParentName",
//                         style: theme.textTheme.titleMedium
//                             ?.copyWith(fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 8),
//                       _buildMetricSelector(theme, model),
//                       const SizedBox(height: 16),
//                       SizedBox(
//                           height: 200, child: _buildPieChart(context, model)),
//                       const SizedBox(height: 16),
//                       Text("Распределение медианных цен:",
//                           style: theme.textTheme.titleSmall
//                               ?.copyWith(fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 8),
//                       SizedBox(
//                           height: 200, child: _buildBarChart(context, model)),
//                     ],
//                   )
//                 : Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(
//                         flex: 1,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "Данные для: $selectedParentName",
//                               style: theme.textTheme.titleMedium
//                                   ?.copyWith(fontWeight: FontWeight.bold),
//                             ),
//                             const SizedBox(height: 8),
//                             _buildMetricSelector(theme, model),
//                             const SizedBox(height: 16),
//                             SizedBox(
//                                 height: 200,
//                                 child: _buildPieChart(context, model)),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(width: 32),
//                       Expanded(
//                         flex: 1,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text("Распределение медианных цен:",
//                                 style: theme.textTheme.titleSmall
//                                     ?.copyWith(fontWeight: FontWeight.bold)),
//                             const SizedBox(height: 8),
//                             SizedBox(
//                                 height: 200,
//                                 child: _buildBarChart(context, model)),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//           ),
//           // Таблица с фильтрами (кнопка "Фильтры" в правом верхнем углу)
//           Expanded(
//             flex: 2,
//             child: Stack(
//               children: [
//                 Positioned(
//                   right: 16,
//                   top: 16,
//                   child: TextButton(
//                     onPressed: () {
//                       _showFilterDialog(context, model);
//                     },
//                     child: const Text("Фильтры"),
//                   ),
//                 ),
//                 Positioned.fill(
//                   child: Padding(
//                     padding: const EdgeInsets.only(top: 48.0),
//                     child: const TableWidget(),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMetricSelector(ThemeData theme, ChoosingNicheViewModel model) {
//     return Row(
//       children: [
//         const Text("Метрика: "),
//         DropdownButton<String>(
//           value: selectedMetric,
//           items: metrics
//               .map((m) => DropdownMenuItem(value: m, child: Text(m)))
//               .toList(),
//           onChanged: (value) {
//             if (value != null) {
//               setState(() {
//                 selectedMetric = value;
//               });
//               _updateModelMetric(model);
//             }
//           },
//         ),
//       ],
//     );
//   }

//   void _updateModelMetric(ChoosingNicheViewModel model) {
//     // Соответствие метрик колонкам:
//     // "Выручка" -> columnIndex = 1
//     // "Количество товаров" -> columnIndex = 2
//     // "Количество заказов" -> columnIndex = 3
//     // "Товары с заказами" -> columnIndex = 5
//     int columnIndex;
//     switch (selectedMetric) {
//       case "Количество товаров":
//         columnIndex = 2;
//         break;
//       case "Количество заказов":
//         columnIndex = 3;
//         break;
//       case "Товары с заказами":
//         columnIndex = 5;
//         break;
//       case "Выручка":
//       default:
//         columnIndex = 1;
//         break;
//     }
//     if (model.selectedParentName != null) {
//       model.updateTopSubjectRevenue(model.selectedParentName!, columnIndex);
//     }
//   }

//   Widget _buildPieChart(BuildContext context, ChoosingNicheViewModel model) {
//     final theme = Theme.of(context);
//     final loading = model.loading;
//     final error = model.error;
//     final colorList = generateColorList(model.currentDataMap.keys.length);

//     if (error != null) {
//       return Center(
//           child: Text(error.toString(),
//               style: const TextStyle(color: Colors.red)));
//     }
//     if (loading || model.currentDataMap.isEmpty) {
//       return const Center(child: Text('Загрузка...'));
//     }

//     return PieChart(
//       dataMap: model.currentDataMap,
//       animationDuration: const Duration(milliseconds: 800),
//       chartValuesOptions: const ChartValuesOptions(
//         showChartValuesInPercentage: true,
//       ),
//       colorList: colorList,
//       legendOptions: const LegendOptions(showLegends: false),
//     );
//   }

//   Widget _buildBarChart(BuildContext context, ChoosingNicheViewModel model) {
//     // Предположим, что medianPrice у subjectSummaryItem - это целое число.
//     // Отобразим гистограмму распределения medianPrice для выбранной категории.

//     if (model.selectedParentName == null) {
//       return const Center(child: Text("Не выбрано"));
//     }

//     // Собираем данные medianPrice для всех subjectSummaryItem с нужным parentName
//     final filtered = model.subjectsSummary
//         .where((item) => item.subjectParentName == model.selectedParentName)
//         .toList();
//     if (filtered.isEmpty) {
//       return const Center(child: Text("Нет данных"));
//     }

//     // Возьмём medianPrice у каждого.
//     final prices = filtered.map((e) => e.medianPrice.toDouble()).toList();
//     if (prices.isEmpty) {
//       return const Center(child: Text("Нет данных"));
//     }

//     // Создадим столбики
//     // Просто равномерно распределим цены: один столбик на элемент
//     final barSpots = <BarChartGroupData>[];
//     for (int i = 0; i < prices.length; i++) {
//       barSpots.add(
//         BarChartGroupData(
//           x: i,
//           barsSpace: 2,
//           barRods: [
//             BarChartRodData(
//               toY: prices[i],
//               color: Colors.blue,
//               width: 10,
//             )
//           ],
//         ),
//       );
//     }

//     return BarChart(
//       BarChartData(
//         titlesData: FlTitlesData(
//           leftTitles: AxisTitles(
//             sideTitles: SideTitles(showTitles: true),
//           ),
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(showTitles: false),
//           ),
//           rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//         ),
//         borderData: FlBorderData(show: false),
//         barGroups: barSpots,
//       ),
//     );
//   }

//   void _showFilterDialog(BuildContext context, ChoosingNicheViewModel model) {
//     final filters = [
//       "Выручка (₽)",
//       "Кол-во заказов",
//       "Товары",
//       "Медианная цена (₽)",
//       "Процент тов. с заказами"
//     ];

//     final controllers = <String, Map<String, TextEditingController>>{};
//     for (var f in filters) {
//       controllers[f] = {
//         "min": TextEditingController(),
//         "max": TextEditingController(),
//       };
//     }

//     showDialog(
//       context: context,
//       builder: (context) {
//         final isMobile = MediaQuery.of(context).size.width < 600;
//         final textStyle = const TextStyle(fontSize: 14);
//         final content = isMobile
//             ? SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: filters.map((f) {
//                     return Padding(
//                       padding: const EdgeInsets.only(bottom: 16.0),
//                       child:
//                           _buildDialogFilterFields(f, controllers, textStyle),
//                     );
//                   }).toList(),
//                 ),
//               )
//             : SingleChildScrollView(
//                 child: Wrap(
//                   spacing: 16.0,
//                   runSpacing: 16.0,
//                   children: filters.map((f) {
//                     return SizedBox(
//                       width: 200,
//                       child:
//                           _buildDialogFilterFields(f, controllers, textStyle),
//                     );
//                   }).toList(),
//                 ),
//               );

//         return AlertDialog(
//           title: const Text("Фильтры"),
//           content: content,
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Отмена"),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 _applyDialogFilters(model, controllers);
//                 Navigator.pop(context);
//               },
//               child: const Text("Применить"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildDialogFilterFields(
//     String label,
//     Map<String, Map<String, TextEditingController>> controllers,
//     TextStyle textStyle,
//   ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
//         const SizedBox(height: 4.0),
//         Row(
//           children: [
//             Expanded(
//               child: TextField(
//                 controller: controllers[label]!["min"],
//                 keyboardType: TextInputType.number,
//                 style: textStyle,
//                 decoration: const InputDecoration(
//                   labelText: "Мин",
//                   border: OutlineInputBorder(),
//                   contentPadding:
//                       EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 8.0),
//             Expanded(
//               child: TextField(
//                 controller: controllers[label]!["max"],
//                 keyboardType: TextInputType.number,
//                 style: textStyle,
//                 decoration: const InputDecoration(
//                   labelText: "Макс",
//                   border: OutlineInputBorder(),
//                   contentPadding:
//                       EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
//                 ),
//               ),
//             ),
//           ],
//         )
//       ],
//     );
//   }

//   int? _parseInt(String value) => int.tryParse(value.isEmpty ? '' : value);

//   void _applyDialogFilters(ChoosingNicheViewModel model,
//       Map<String, Map<String, TextEditingController>> ctrls) {
//     model.filterData(
//       minTotalRevenue: _parseInt(ctrls["Выручка (₽)"]!["min"]!.text),
//       maxTotalRevenue: _parseInt(ctrls["Выручка (₽)"]!["max"]!.text),
//       minTotalOrders: _parseInt(ctrls["Кол-во заказов"]!["min"]!.text),
//       maxTotalOrders: _parseInt(ctrls["Кол-во заказов"]!["max"]!.text),
//       minTotalSkus: _parseInt(ctrls["Товары"]!["min"]!.text),
//       maxTotalSkus: _parseInt(ctrls["Товары"]!["max"]!.text),
//       minMedianPrice: _parseInt(ctrls["Медианная цена (₽)"]!["min"]!.text),
//       maxMedianPrice: _parseInt(ctrls["Медианная цена (₽)"]!["max"]!.text),
//       minSkusWithOrders:
//           _parseInt(ctrls["Процент тов. с заказами"]!["min"]!.text),
//       maxSkusWithOrders:
//           _parseInt(ctrls["Процент тов. с заказами"]!["max"]!.text),
//     );
//   }
// }

// class TableWidget extends StatelessWidget {
//   const TableWidget({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final model = context.watch<ChoosingNicheViewModel>();
//     final subjectsSummary = model.subjectsSummary;
//     final sortData = model.sortData;
//     final sortColumnIndex = model.sortColumnIndex;
//     final isAscending = model.isAscending;
//     final theme = Theme.of(context);
//     final tableViewController = model.tableViewController;

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final totalWidth = constraints.maxWidth;
//         final isMobile = totalWidth < 600;

//         final mobileMinColumnWidths = [100.0, 80.0, 80.0, 80.0, 80.0, 80.0];
//         final columnProportions = [0.2, 0.15, 0.15, 0.15, 0.15, 0.15];

//         final columnWidths = isMobile
//             ? mobileMinColumnWidths
//             : columnProportions.map((p) => p * totalWidth).toList();

//         final columns = <TableColumn>[
//           TableColumn(width: columnWidths[0]),
//           TableColumn(width: columnWidths[1]),
//           TableColumn(width: columnWidths[2]),
//           TableColumn(width: columnWidths[3]),
//           TableColumn(width: columnWidths[4]),
//           TableColumn(width: columnWidths[5]),
//         ];

//         return TableView.builder(
//           controller: tableViewController,
//           columns: columns,
//           rowHeight: 48,
//           rowCount: subjectsSummary.length,
//           headerBuilder: (context, contentBuilder) {
//             return contentBuilder(context, (context, columnIndex) {
//               final headers = [
//                 "Предметы",
//                 "Выручка (₽)",
//                 "Товары",
//                 "Кол-во заказов",
//                 "Медианная цена (₽)",
//                 "Товары с заказами"
//               ];
//               final alignment =
//                   columnIndex == 0 ? Alignment.centerLeft : Alignment.center;
//               return GestureDetector(
//                 onTap: () {
//                   if (columnIndex == 4) return;
//                   sortData(columnIndex);
//                 },
//                 child: Container(
//                   alignment: alignment,
//                   padding: const EdgeInsets.symmetric(horizontal: 4.0),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     mainAxisAlignment: columnIndex == 0
//                         ? MainAxisAlignment.start
//                         : MainAxisAlignment.center,
//                     children: [
//                       Flexible(
//                         child: Text(
//                           headers[columnIndex],
//                           textAlign: columnIndex == 0
//                               ? TextAlign.left
//                               : TextAlign.center,
//                           style: TextStyle(
//                             fontSize:
//                                 theme.textTheme.titleMedium?.fontSize ?? 14,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 2,
//                           softWrap: true,
//                         ),
//                       ),
//                       if (columnIndex == sortColumnIndex)
//                         Padding(
//                           padding: const EdgeInsets.only(left: 4.0),
//                           child: Icon(
//                             isAscending
//                                 ? Icons.arrow_drop_down
//                                 : Icons.arrow_drop_up,
//                             color: theme.colorScheme.onSurface,
//                             size: theme.textTheme.bodyMedium?.fontSize ?? 14,
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               );
//             });
//           },
//           rowBuilder: (context, rowIndex, contentBuilder) {
//             final item = subjectsSummary[rowIndex];
//             return contentBuilder(context, (context, columnIndex) {
//               TextAlign textAlign =
//                   columnIndex == 0 ? TextAlign.left : TextAlign.center;
//               String text;
//               switch (columnIndex) {
//                 case 0:
//                   text = '${item.subjectParentName ?? ''}/${item.subjectName}';
//                   break;
//                 case 1:
//                   text = item.totalRevenue.toString().formatWithThousands();
//                   break;
//                 case 2:
//                   text = item.totalSkus.toString().formatWithThousands();
//                   break;
//                 case 3:
//                   text = item.totalOrders.toString().formatWithThousands();
//                   break;
//                 case 4:
//                   text = item.medianPrice.toString().formatWithThousands();
//                   break;
//                 case 5:
//                   final percent = item.totalSkus == 0
//                       ? "0"
//                       : (item.skusWithOrders / item.totalSkus * 100.0)
//                           .toStringAsFixed(0);
//                   text =
//                       '${item.skusWithOrders.toString().formatWithThousands()} шт. ($percent%)';
//                   break;
//                 default:
//                   text = '';
//               }
//               return MouseRegion(
//                 cursor: columnIndex == 0 || columnIndex == 4
//                     ? SystemMouseCursors.basic
//                     : SystemMouseCursors.click,
//                 child: GestureDetector(
//                   onTap: () {
//                     if (columnIndex == 4) return;
//                     if (item.subjectParentName != null) {
//                       model.updateTopSubjectRevenue(
//                           item.subjectParentName!, columnIndex);
//                     }
//                   },
//                   child: Container(
//                     decoration: BoxDecoration(
//                         border: Border(
//                       bottom: BorderSide(
//                         color: theme.colorScheme.onSurface.withOpacity(0.2),
//                         width: 1.0,
//                       ),
//                     )),
//                     alignment: columnIndex == 0
//                         ? Alignment.centerLeft
//                         : Alignment.center,
//                     padding: const EdgeInsets.symmetric(horizontal: 4.0),
//                     child: Text(
//                       text,
//                       textAlign: textAlign,
//                       style: TextStyle(fontSize: isMobile ? 12 : 14),
//                       overflow: TextOverflow.visible,
//                       softWrap: true,
//                     ),
//                   ),
//                 ),
//               );
//             });
//           },
//         );
//       },
//     );
//   }
// }
