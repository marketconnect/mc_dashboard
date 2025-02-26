// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:excel/excel.dart' as exc;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:mc_dashboard/presentation/widgets/check_box.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mc_dashboard/core/utils/dates.dart';
import 'package:mc_dashboard/presentation/seo_requests_extend_screen/seo_requests_extend_view_model.dart';
import 'package:mc_dashboard/theme/color_schemes.dart';

class SeoRequestsExtendScreen extends StatelessWidget {
  const SeoRequestsExtendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SeoRequestsExtendViewModel>();
    final normqueryProducts = model.normqueries;
    final selectedRows = model.selectedRows;
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          toolbarHeight: 0.0,
          bottom: TabBar(
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurface,
            tabs: const [
              Tab(text: "Расширенные запросы"),
              Tab(text: "Характеристики"),
            ],
          ),
        ),
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
                            content:
                                Text('Нет выбранных элементов для экспорта'),
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
                          exc.TextCellValue(product.kw),
                          exc.TextCellValue(product.normquery),
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
                    child: IntrinsicWidth(
                      child: IntrinsicHeight(
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                                color: theme.colorScheme.onSecondary),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 20.0, horizontal: 16.0),
                          child: Row(
                            mainAxisSize:
                                MainAxisSize.min, // Минимизирует размер Row
                            children: [
                              Icon(
                                Icons.download,
                                color: theme.colorScheme.onSecondary,
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                'Экспорт в Excel',
                                style: TextStyle(
                                  color: theme.colorScheme.onSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),
              ),
        body: TabBarView(
          children: [
            Padding(
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
            _CharacteristicsTabView(),
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
    final loading = model.isLoading;
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
      return Shimmer(
        gradient: Theme.of(context).colorScheme.shimmerGradient,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isMobile = maxWidth < 600;

        final proportions = isMobile ? mobColumnProportions : columnProportions;
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
                        return McCheckBox(
                          theme: theme,
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
                        return McCheckBox(
                            theme: theme,
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
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
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

class _CharacteristicsTabView extends StatelessWidget {
  const _CharacteristicsTabView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SeoRequestsExtendViewModel>();
    // Словарь типа { "Состав": {"эластан", "вискоза"}, "Цвет": {"черный", "серый"}, ... }
    final characteristicsMap = model.parsedCharacteristics;

    // Список всех названий характеристик
    final allKeys = characteristicsMap.keys.toList();

    // Если нет характеристик
    if (allKeys.isEmpty) {
      return const Center(child: Text("Нет характеристик для отображения"));
    }

    // Для адаптивности используем DefaultTabController
    return DefaultTabController(
      length: allKeys.length,
      child: Column(
        children: [
          // Сам TabBar
          TabBar(
            isScrollable: true, // Можно прокручивать, если ключей много
            tabs: allKeys.map((key) => Tab(text: key)).toList(),
          ),
          // Содержимое вкладок
          Expanded(
            child: TabBarView(
              children: allKeys.map((key) {
                // Извлекаем все значения для этой характеристики
                final values = characteristicsMap[key]?.toList() ?? [];
                // Здесь решаем, как именно показывать — список, сетку и т.п.
                return _buildValuesList(context, key, values);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValuesList(
      BuildContext context, String key, List<String> values) {
    if (values.isEmpty) {
      return Center(
        child: Text("Нет значений для характеристики: $key"),
      );
    }
    return ListView.builder(
      itemCount: values.length,
      itemBuilder: (context, index) {
        final value = values[index];

        return Material(
          color: Colors.transparent,
          child: InkWell(
            // Подсветка при клике/hover, если нужно:
            hoverColor: Colors.blue.withOpacity(0.1),
            splashColor: Colors.blue.withOpacity(0.2),

            // Задаём поведение при долгом тапе (долгом нажатии):
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Текст скопирован: $value')),
              );
            },

            // Если нужно, чтобы курсор наводился именно «рукой»:
            mouseCursor: SystemMouseCursors.click,

            // Основной контейнер для контента строки
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              // Можно кастомизировать под дизайн
              child: Text(value),
            ),
          ),
        );
      },
    );
  }
}
