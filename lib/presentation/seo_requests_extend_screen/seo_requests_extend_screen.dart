import 'dart:ui';
import 'dart:html' as html;
import 'package:excel/excel.dart' as exc;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:mc_dashboard/core/utils/dates.dart';

import 'package:mc_dashboard/presentation/seo_requests_extend_screen/seo_requests_extend_view_model.dart';

import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class SeoRequestsExtendScreen extends StatelessWidget {
  const SeoRequestsExtendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SeoRequestsExtendViewModel>();
    final normqueryProducts = model.normqueries;
    final selectedRows = model.selectedRows;
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: selectedRows.isEmpty
          ? null
          : MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  final selectedItems = selectedRows
                      .map((index) => normqueryProducts[index])
                      .toList();

                  if (selectedItems.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Нет выбранных элементов для экспорта'),
                      ),
                    );
                    return;
                  }

                  // Создаём Excel
                  final excel = exc.Excel.createExcel();

                  final sheet = excel['Sheet1'];
                  sheet.appendRow(<exc.CellValue?>[
                    exc.TextCellValue("Ключевой запрос"),
                    exc.TextCellValue("Кластер"),
                    exc.TextCellValue("Частота"),
                    exc.TextCellValue("Всего товаров"),
                  ]);

                  for (var product in selectedItems) {
                    sheet.appendRow(<exc.CellValue?>[
                      exc.TextCellValue(product.normquery),
                      exc.TextCellValue(product.kw),
                      exc.IntCellValue(product.freq),
                      exc.IntCellValue(product.total),
                    ]);
                  }

                  final List<int>? fileBytes = excel.save(
                      fileName:
                          "${formatDateTimeToDayMonthYearHourMinute(DateTime.now())}_запросы.xlsx");
                  if (fileBytes == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Ошибка: fileBytes == null')),
                    );
                    return;
                  }

                  // -- Web-подход (скачиваем файл):
                  final bytes = Uint8List.fromList(fileBytes);
                  final blob = html.Blob([bytes]);
                  final url = html.Url.createObjectUrlFromBlob(blob);

                  final anchor = html.document.createElement('a')
                      as html.AnchorElement
                    ..href = url
                    ..style.display = 'none'
                    ..download =
                        "${formatDateTimeToDayMonthYearHourMinute(DateTime.now())}_запросы.xlsx"; // <-- здесь ваше желаемое имя

                  html.document.body!.children.add(anchor);
                  anchor.click();

                  // Удаляем ссылку и освобождаем URL-объект
                  Future.delayed(const Duration(seconds: 1), () {
                    anchor.remove();
                    html.Url.revokeObjectUrl(url);
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: theme.colorScheme.onSecondary),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Экспорт в Excel',
                    style: TextStyle(color: theme.colorScheme.onSecondary),
                  ),
                ),
              ),
            ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: const _NormqueryTableWidget(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SeoRequestsExtendViewModel>();
    final onNavigateBack = model.onNavigateBack;

    final ThemeData theme = Theme.of(context);

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
          Text("Расширение запросов",
              style: TextStyle(
                fontSize: theme.textTheme.titleLarge!.fontSize,
                fontWeight: FontWeight.bold,
              )),
        ]),
      ],
    );
  }
}

class _NormqueryTableWidget extends StatefulWidget {
  const _NormqueryTableWidget();

  @override
  State<_NormqueryTableWidget> createState() => _NormqueryTableWidgetState();
}

class _NormqueryTableWidgetState extends State<_NormqueryTableWidget> {
  late TableViewController tableViewController;
  // Хранит индексы выбранных строк
  // Управляет выбором всех строк

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

      context.read<SeoRequestsExtendViewModel>().normqueries.sort((a, b) {
        int compare;
        switch (columnIndex) {
          case 1: // Ключевой запрос
            compare = a.kw.compareTo(b.kw);
            break;
          case 2: // Кластер
            compare = a.normquery.compareTo(b.normquery);
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
    final model = context.watch<SeoRequestsExtendViewModel>();
    final loading = model.loading;
    final normqueryProducts = model.normqueries;
    final selectedIndices = model.selectedRows;
    final selectRow = model.selectRow;
    final selectAllMethod = model.selectAllMethod;
    final selectAll = model.selectAll;
    final setSelectAll = model.setSelectAll;

    final columnProportions = [0.05, 0.2, 0.1, 0.1, 0.1];
    final mobColumnProportions = [0.1, 0.3, 0.3, 0.15, 0.15];
    final columnHeaders = [
      "Выбор",
      "Ключевой запрос",
      "Кластер",
      "Частота (нед.)",
      "Всего товаров",
    ];

    if (loading) {
      return Shimmer.fromColors(
        baseColor: theme.colorScheme.surfaceContainerHighest,
        highlightColor: theme.colorScheme.surfaceContainer,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.grey,
          ),
        ),
      );
    }

    if (normqueryProducts.isEmpty) {
      return _noDataPlaceholder();
    }
    return Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final isMobile = maxWidth < 600;

            final proportions =
                isMobile ? mobColumnProportions : columnProportions;
            final columns = proportions
                .map(
                  (widthFraction) => TableColumn(
                    width: widthFraction * MediaQuery.of(context).size.width,
                  ),
                )
                .toList();

            return Column(
              children: [
                // Размещаем таблицу в Expanded, чтобы она заняла всё свободное место
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: TableView.builder(
                      controller: tableViewController,
                      columns: columns,
                      rowHeight: 40,
                      rowCount: normqueryProducts.length,
                      headerBuilder: (context, contentBuilder) {
                        return contentBuilder(context, (context, columnIndex) {
                          if (columnIndex == 0) {
                            return Checkbox(
                              activeColor: Colors.transparent,
                              checkColor: theme.colorScheme.secondary,
                              value: selectAll,
                              onChanged: (value) {
                                selectAllMethod();
                              },
                            );
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
                        final product = normqueryProducts[rowIndex];
                        final rowValues = [
                          product.kw,
                          product.normquery,
                          product.freq.toString(),
                          product.total.toString(),
                        ];

                        return contentBuilder(context, (context, columnIndex) {
                          if (columnIndex == 0) {
                            return Checkbox(
                                activeColor: Colors.transparent,
                                checkColor: theme.colorScheme.secondary,
                                value: selectedIndices.contains(rowIndex),
                                onChanged: (isSelected) {
                                  selectRow(rowIndex);
                                  if (isSelected == true) {
                                    if (selectedIndices.length ==
                                        normqueryProducts.length) {
                                      setSelectAll(true);
                                    } else {
                                      setSelectAll(false);
                                    }
                                  }
                                });
                          }

                          final value = rowValues[columnIndex - 1];
                          return GestureDetector(
                            onTap: () {
                              // Клик по столбцу "Ключевой запрос"
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: MouseRegion(
                                cursor: columnIndex == 1
                                    ? SystemMouseCursors.click
                                    : MouseCursor.defer,
                                child: Text(
                                  value,
                                  textAlign: TextAlign.center,
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
              ],
            );
          },
        ),
        if (model.isFree)
          Positioned.fill(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  model.onPaymentComplete();
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
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
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
