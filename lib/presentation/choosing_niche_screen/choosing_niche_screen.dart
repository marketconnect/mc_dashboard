import 'package:flutter/material.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';
import 'package:mc_dashboard/presentation/choosing_niche_screen/choosing_niche_view_model.dart';

class ChoosingNicheScreen extends StatelessWidget {
  const ChoosingNicheScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ChoosingNicheViewModel>();
    final surfaceContainerHighest =
        Theme.of(context).colorScheme.surfaceContainerHighest;
    return Scaffold(
      body: Column(
        children: [
          // Верхняя часть с фильтром и диаграммой
          Flexible(
            flex: 1,
            child: Row(
              children: [
                // Фильтр
                Flexible(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Center(
                      child: Text(
                        "Фильтр",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                // Диаграмма
                Flexible(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: PieChartWidget(model: model),
                  ),
                ),
              ],
            ),
          ),
          // Таблица
          Flexible(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TableWidget(model: model),
            ),
          ),
        ],
      ),
    );
  }
}

class PieChartWidget extends StatelessWidget {
  final ChoosingNicheViewModel model;

  const PieChartWidget({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Получаем текущий subjectParentName и суммарную выручку
    final selectedParentName = model.currentDataMap.keys.isNotEmpty
        ? model.currentDataMap.keys.first
        : 'Unknown';
    final totalRevenue = model.currentDataMap.values.isNotEmpty
        ? model.currentDataMap.values.reduce((a, b) => a + b)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок с subjectParentName и суммарной выручкой
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            '$selectedParentName: ${totalRevenue.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // График и легенда
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // График
              Expanded(
                flex: 2,
                child: PieChart(
                  dataMap: model.currentDataMap,
                  animationDuration: const Duration(milliseconds: 800),
                  chartValuesOptions: const ChartValuesOptions(
                    showChartValuesInPercentage: true,
                  ),
                ),
              ),
              // Легенда
              Expanded(
                flex: 1,
                child: ListView.builder(
                  itemCount: model.currentDataMap.keys.length,
                  itemBuilder: (context, index) {
                    final key = model.currentDataMap.keys.elementAt(index);
                    final value = model.currentDataMap[key]!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        '$key: ${value.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  },
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
  final ChoosingNicheViewModel model;

  const TableWidget({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subjectsSummary = model.subjectsSummary;
    final sortData = model.sortData;
    final sortColumnIndex = model.sortColumnIndex;
    final isAscending = model.isAscending;

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
          columns: columns,
          rowHeight: 48,
          rowCount: subjectsSummary.length,
          headerBuilder: (context, contentBuilder) {
            return contentBuilder(context, (context, columnIndex) {
              final headers = [
                "Предметы",
                "Выручка",
                "Товары",
                "Кол-во заказов",
                "Медианная цена",
                "Товары с заказами"
              ];
              return GestureDetector(
                onTap: () => sortData(columnIndex),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    headers[columnIndex],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.visible,
                    softWrap: true,
                  ),
                ),
              );
            });
          },
          rowBuilder: (context, rowIndex, contentBuilder) {
            final item = subjectsSummary[rowIndex];
            return GestureDetector(
              onTap: () => model
                  .updateTopSubjectRevenue(item.subjectParentName ?? 'Unknown'),
              child: contentBuilder(context, (context, columnIndex) {
                TextAlign textAlign =
                    columnIndex == 0 ? TextAlign.left : TextAlign.center;
                String text;
                switch (columnIndex) {
                  case 0:
                    text =
                        '${item.subjectParentName ?? ''}/${item.subjectName}';
                    break;
                  case 1:
                    text = item.totalRevenue.toString();
                    break;
                  case 2:
                    text = item.totalSkus.toString();
                    break;
                  case 3:
                    text = item.totalOrders.toString();
                    break;
                  case 4:
                    text = item.medianPrice.toString();
                    break;
                  case 5:
                    text = item.skusWithOrders.toString();
                    break;
                  default:
                    text = '';
                }
                return Container(
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
                );
              }),
            );
          },
        );
      },
    );
  }
}
