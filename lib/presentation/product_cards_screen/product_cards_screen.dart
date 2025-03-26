import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

import 'package:mc_dashboard/domain/entities/product_card.dart';
import 'package:mc_dashboard/domain/entities/wb_box_tariff.dart';
import 'package:mc_dashboard/domain/entities/wb_pallet_tariff.dart';
import 'package:mc_dashboard/presentation/product_cards_screen/product_cards_view_model.dart';

import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';

import 'package:provider/provider.dart';

// Filter state class
class FilterState {
  final String value;
  final FilterOperator operator;

  FilterState({required this.value, required this.operator});
}

enum FilterOperator {
  equals,
  greaterThan,
  lessThan,
  contains,
  startsWith,
  endsWith,
}

class ProductCardsScreen extends StatefulWidget {
  const ProductCardsScreen({
    super.key,
  });

  @override
  State<ProductCardsScreen> createState() => _ProductCardsScreenState();
}

class _ProductCardsScreenState extends State<ProductCardsScreen> {
  bool _ascending = false;
  int _sortColumnIndex = 6;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  List<ProductCard> _filteredAndSortedCards = [];
  List<ProductCard> _displayedCards = [];
  bool _isProcessing = false;
  bool _isLoadingMore = false;
  Timer? _debounceTimer;
  static const int _chunkSize = 50;
  final ScrollController _scrollController = ScrollController();

  // Filter state
  final Map<int, FilterState> _columnFilters = {};
  final TextEditingController _subjectFilterController =
      TextEditingController();
  final TextEditingController _marginFilterController = TextEditingController();
  final TextEditingController _profitFilterController = TextEditingController();
  final TextEditingController _stocksFilterController = TextEditingController();
  final TextEditingController _stocksWBFilterController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _subjectFilterController.dispose();
    _marginFilterController.dispose();
    _profitFilterController.dispose();
    _stocksFilterController.dispose();
    _stocksWBFilterController.dispose();
    _debounceTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  void _loadMoreData() {
    if (_isLoadingMore ||
        _displayedCards.length >= _filteredAndSortedCards.length) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
      final startIndex = _displayedCards.length;
      final endIndex =
          (startIndex + _chunkSize).clamp(0, _filteredAndSortedCards.length);
      _displayedCards
          .addAll(_filteredAndSortedCards.sublist(startIndex, endIndex));
      _isLoadingMore = false;
    });
  }

  Future<void> _processData() async {
    if (_isProcessing) return;
    _isProcessing = true;
    setState(() {
      _displayedCards = [];
    });

    try {
      final viewModel = context.read<ProductCardsViewModel>();
      final cards = viewModel.productCards;

      if (cards.isEmpty) {
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      // Process data in isolate
      final processedCards = await compute(_processCardsInIsolate, {
        'cards': cards,
        'searchQuery': _searchQuery,
        'columnFilters': _columnFilters,
        'sortColumnIndex': _sortColumnIndex,
        'ascending': _ascending,
        'viewModel': viewModel,
      });

      setState(() {
        _filteredAndSortedCards = processedCards;
        _displayedCards = processedCards.sublist(
            0, _chunkSize.clamp(0, processedCards.length));
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      debugPrint('Error processing data: $e');
    }
  }

  void _debouncedProcessData() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _processData();
    });
  }

  Widget _buildFilterPopup(BuildContext context, int columnIndex) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.filter_list,
          size: 16, color: Theme.of(context).colorScheme.onSurface),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'filter',
          child: Text('Фильтр'),
        ),
        const PopupMenuItem(
          value: 'clear',
          child: Text('Очистить'),
        ),
      ],
      onSelected: (value) {
        if (value == 'clear') {
          setState(() {
            _columnFilters.remove(columnIndex);
          });
          _debouncedProcessData();
        } else if (value == 'filter') {
          _showFilterDialog(context, columnIndex);
        }
      },
    );
  }

  void _showFilterDialog(BuildContext context, int columnIndex) {
    String title = '';
    TextEditingController controller;
    FilterOperator defaultOperator;

    switch (columnIndex) {
      case 2: // Название предмета
        title = 'Фильтр по названию предмета';
        controller = _subjectFilterController;
        defaultOperator = FilterOperator.contains;
        break;
      case 5: // Рентабельность
        title = 'Фильтр по рентабельности';
        controller = _marginFilterController;
        defaultOperator = FilterOperator.equals;
        break;
      case 6: // Чистая прибыль
        title = 'Фильтр по чистой прибыли';
        controller = _profitFilterController;
        defaultOperator = FilterOperator.equals;
        break;
      case 7: // Остатки
        title = 'Фильтр по остаткам';
        controller = _stocksFilterController;
        defaultOperator = FilterOperator.equals;
        break;
      case 8: // Остатки WB
        title = 'Фильтр по остаткам WB';
        controller = _stocksWBFilterController;
        defaultOperator = FilterOperator.equals;
        break;
      default:
        return;
    }

    if (columnIndex == 2) {
      // Get unique subject names
      final viewModel = context.read<ProductCardsViewModel>();
      final uniqueSubjects = viewModel.productCards
          .map((card) => card.subjectName)
          .toSet()
          .toList()
        ..sort();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Поиск',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _subjectFilterController.text = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<FilterOperator>(
                  value:
                      _columnFilters[columnIndex]?.operator ?? defaultOperator,
                  items: FilterOperator.values.map((op) {
                    String label;
                    switch (op) {
                      case FilterOperator.contains:
                        label = 'Содержит';
                        break;
                      case FilterOperator.startsWith:
                        label = 'Начинается с';
                        break;
                      case FilterOperator.endsWith:
                        label = 'Заканчивается на';
                        break;
                      default:
                        label = 'Содержит';
                    }
                    return DropdownMenuItem(
                      value: op,
                      child: Text(label),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _columnFilters[columnIndex] = FilterState(
                          value: controller.text,
                          operator: value,
                        );
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Оператор',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Доступные значения:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: uniqueSubjects.length,
                      itemBuilder: (context, index) {
                        final subject = uniqueSubjects[index];
                        if (controller.text.isEmpty ||
                            subject
                                .toLowerCase()
                                .contains(controller.text.toLowerCase())) {
                          return ListTile(
                            dense: true,
                            title: Text(subject),
                            onTap: () {
                              setState(() {
                                controller.text = subject;
                                _columnFilters[columnIndex] = FilterState(
                                  value: subject,
                                  operator:
                                      _columnFilters[columnIndex]?.operator ??
                                          defaultOperator,
                                );
                              });
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _debouncedProcessData();
              },
              child: const Text('Применить'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<FilterOperator>(
                value: _columnFilters[columnIndex]?.operator ?? defaultOperator,
                items: FilterOperator.values.map((op) {
                  String label;
                  switch (op) {
                    case FilterOperator.equals:
                      label = 'Равно';
                      break;
                    case FilterOperator.greaterThan:
                      label = 'Больше';
                      break;
                    case FilterOperator.lessThan:
                      label = 'Меньше';
                      break;
                    default:
                      label = 'Равно';
                  }
                  return DropdownMenuItem(
                    value: op,
                    child: Text(label),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _columnFilters[columnIndex] = FilterState(
                        value: controller.text,
                        operator: value,
                      );
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Оператор',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Значение',
                ),
                keyboardType: columnIndex >= 5
                    ? TextInputType.number
                    : TextInputType.text,
                onChanged: (value) {
                  setState(() {
                    _columnFilters[columnIndex] = FilterState(
                      value: value,
                      operator: _columnFilters[columnIndex]?.operator ??
                          defaultOperator,
                    );
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _debouncedProcessData();
              },
              child: const Text('Применить'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductCardsViewModel>(
      builder: (context, viewModel, child) {
        // Process data when ViewModel's data changes
        if (viewModel.productCards.isNotEmpty &&
            _filteredAndSortedCards.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _processData();
          });
        }

        return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            // appBar: PreferredSize(
            //   preferredSize: const Size.fromHeight(110),
            //   child:
            //   AppBar(
            //     automaticallyImplyLeading: false,
            //     scrolledUnderElevation: 2,
            //     shadowColor: Colors.black,
            //     surfaceTintColor: Colors.transparent,
            //     title: PreferredSize(
            //       preferredSize: const Size.fromHeight(50),
            //       child: Padding(
            //         padding: const EdgeInsets.all(8.0),
            //         child: Row(
            //           mainAxisAlignment: MainAxisAlignment.start,
            //           children: [
            //             SizedBox(
            //               width: 400,
            //               child: TextField(
            //                 controller: _searchController,
            //                 decoration: InputDecoration(
            //                   hintText: "Поиск по nmID или коду продавца...",
            //                   hintStyle: const TextStyle(color: Colors.grey),
            //                   prefixIcon:
            //                       const Icon(Icons.search, color: Colors.grey),
            //                   suffixIcon: _searchController.text.isNotEmpty
            //                       ? IconButton(
            //                           icon: const Icon(Icons.clear,
            //                               color: Colors.grey),
            //                           onPressed: () {
            //                             setState(() {
            //                               _searchController.clear();
            //                               _searchQuery = "";
            //                             });
            //                             _debouncedProcessData();
            //                           },
            //                         )
            //                       : null,
            //                   border: OutlineInputBorder(
            //                     borderRadius: BorderRadius.circular(8.0),
            //                     borderSide: BorderSide.none,
            //                   ),
            //                   contentPadding: const EdgeInsets.symmetric(
            //                     vertical: 8.0,
            //                     horizontal: 12.0,
            //                   ),
            //                   filled: true,
            //                   fillColor: Colors.grey[50],
            //                 ),
            //                 onChanged: (value) {
            //                   setState(() {
            //                     _searchQuery = value.trim().toLowerCase();
            //                   });
            //                   _debouncedProcessData();
            //                 },
            //                 style: const TextStyle(color: Colors.black),
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            body: OverlayLoaderWithAppIcon(
              isLoading: viewModel.isLoading || _isProcessing,
              overlayBackgroundColor: Colors.black,
              circularProgressColor: Theme.of(context).colorScheme.onPrimary,
              appIconSize: 70,
              appIcon: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'M',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: GoogleFonts.alikeAngular().fontFamily,
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ARKET',
                        style: TextStyle(
                          fontSize: 9,
                          fontFamily:
                              GoogleFonts.waitingForTheSunrise().fontFamily,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 35,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        'CONNECT',
                        style: TextStyle(
                          fontSize: 9,
                          fontFamily:
                              GoogleFonts.waitingForTheSunrise().fontFamily,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              child: viewModel.errorMessage != null
                  ? Center(
                      child: Text(
                        viewModel.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : Center(child: _buildProductTable(viewModel)),
            ));
      },
    );
  }

  Widget _buildProductTable(ProductCardsViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Поиск по ID или артикулу',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim().toLowerCase();
                    });
                    _debouncedProcessData();
                  },
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Theme(
                data: ThemeData.light().copyWith(
                  cardColor: Theme.of(context).colorScheme.surface,
                  dataTableTheme: DataTableThemeData(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.surfaceBright,
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
                child: DataTable(
                  headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                  dataTextStyle: const TextStyle(color: Colors.black),
                  dividerThickness: 1.0,
                  dataRowMinHeight: 55,
                  dataRowMaxHeight: 55,
                  columnSpacing: 20,
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _ascending,
                  columns: [
                    DataColumn(
                      label: SizedBox(
                        width: 60,
                        child: Text('Фото',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).colorScheme.onSurface)),
                      ),
                    ),
                    _sortableColumn('nmID', 1),
                    _sortableColumn('Название предмета', 2),
                    _sortableColumn('Код продавца', 3),
                    _sortableColumn('Цена', 4),
                    _sortableColumn('Рентабельность', 5),
                    _sortableColumn('Чистая прибыль', 6),
                    _sortableColumn('Склад продавца', 7),
                    _sortableColumn('Склад WB', 8),
                    DataColumn(
                      label: Text('Действие',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface)),
                    ),
                  ],
                  rows: _displayedCards
                      .map((card) => _buildDataRow(viewModel, card))
                      .toList(),
                ),
              ),
            ),
          ),
        ),
        if (_isLoadingMore)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  DataRow _buildDataRow(ProductCardsViewModel viewModel, ProductCard card) {
    double? price = viewModel.goodsPrices[card.nmID];
    final costData = viewModel.productCosts[card.nmID];
    final marginText =
        viewModel.marginByNmId[card.nmID]?.toStringAsFixed(1) ?? "—";
    final netProfitText =
        viewModel.profitByNmId[card.nmID]?.toStringAsFixed(2) ?? "—";

    final rowColor = costData == null || costData.costPrice == 0
        ? WidgetStateProperty.all(
            Theme.of(context).colorScheme.errorContainer.withAlpha(51))
        : WidgetStateProperty.all(Theme.of(context).colorScheme.surface);

    return DataRow(
      color: rowColor,
      cells: [
        DataCell(
          card.photoUrl.isNotEmpty
              ? Image.network(
                  card.photoUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )
              : const Icon(Icons.image_not_supported, color: Colors.grey),
        ),
        _copyableCell(card.nmID.toString()),
        _categoryCell(
          card.subjectName,
          card.subjectID,
          viewModel.onNavigateToSubjectProductsScreen,
        ),
        _copyableCell(card.vendorCode),
        DataCell(
          Text(price != null ? "${price.toStringAsFixed(2)} ₽" : "—",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        ),
        DataCell(
          Text(marginText,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        ),
        DataCell(
          Text(netProfitText,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        ),
        DataCell(
          Tooltip(
            message: "Остатки на складах продавца",
            child: Text(
              viewModel.totalStocksByNmId[card.nmID]?.toString() ?? "—",
              style: TextStyle(
                color: (viewModel.totalStocksByNmId[card.nmID] ?? 0) > 0
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ),
        ),
        DataCell(
          Tooltip(
            message: viewModel.getWbStockTooltipText(card.nmID),
            child: Text(
              viewModel.totalStocksWBByNmId[card.nmID]?.toString() ?? "—",
              style: TextStyle(
                color: (viewModel.totalStocksWBByNmId[card.nmID] ?? 0) > 0
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ),
        ),
        DataCell(
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF9a41fe),
                textStyle:
                    TextStyle(color: Theme.of(context).colorScheme.surface)),
            onPressed: () => viewModel.navTo(card.imtID, card.nmID),
            child: const Text("Перейти", style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  DataColumn _sortableColumn(String title, int index) {
    return DataColumn(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface)),
          if ([2, 5, 6, 7, 8].contains(index)) ...[
            const SizedBox(width: 4),
            _buildFilterPopup(context, index),
          ],
        ],
      ),
      onSort: (columnIndex, ascending) {
        setState(() {
          _sortColumnIndex = columnIndex;
          _ascending = ascending;
        });
        _debouncedProcessData();
      },
    );
  }

  DataCell _copyableCell(String text) {
    return DataCell(
      InkWell(
        onTap: () {
          Clipboard.setData(ClipboardData(text: text));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Текст скопирован в буфер обмена')),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              text,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.copy,
              size: 8,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  DataCell _categoryCell(
      String subjectName,
      int subjectId,
      void Function(
              {required int selectedSubjectId,
              required String selectedSubjectName})
          onSubjectNameTap) {
    return DataCell(
      GestureDetector(
        onTap: () {
          onSubjectNameTap(
              selectedSubjectId: subjectId, selectedSubjectName: subjectName);
        },
        child: Text(
          subjectName,
          style: const TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}

Future<List<ProductCard>> _processCardsInIsolate(
    Map<String, dynamic> params) async {
  final cards = params['cards'] as List<ProductCard>;
  final searchQuery = params['searchQuery'] as String;
  final columnFilters = params['columnFilters'] as Map<int, FilterState>;
  final sortColumnIndex = params['sortColumnIndex'] as int;
  final ascending = params['ascending'] as bool;
  final viewModel = params['viewModel'] as ProductCardsViewModel;

  List<ProductCard> filteredCards = cards;

  // Apply search filter
  if (searchQuery.isNotEmpty) {
    filteredCards = filteredCards.where((card) {
      return card.nmID.toString().contains(searchQuery) ||
          card.vendorCode.toLowerCase().contains(searchQuery);
    }).toList();
  }

  // Apply column filters
  for (var entry in columnFilters.entries) {
    final columnIndex = entry.key;
    final filter = entry.value;
    final value = filter.value.toLowerCase();

    filteredCards = filteredCards.where((card) {
      switch (columnIndex) {
        case 2: // Название предмета
          switch (filter.operator) {
            case FilterOperator.contains:
              return card.subjectName.toLowerCase().contains(value);
            case FilterOperator.startsWith:
              return card.subjectName.toLowerCase().startsWith(value);
            case FilterOperator.endsWith:
              return card.subjectName.toLowerCase().endsWith(value);
            default:
              return true;
          }
        case 5: // Рентабельность
          final margin = _calculateMarginInIsolate(card, viewModel);
          if (margin == null) return false;
          final filterValue = double.tryParse(value);
          if (filterValue == null) return false;
          switch (filter.operator) {
            case FilterOperator.equals:
              return margin == filterValue;
            case FilterOperator.greaterThan:
              return margin > filterValue;
            case FilterOperator.lessThan:
              return margin < filterValue;
            default:
              return true;
          }
        case 6: // Чистая прибыль
          final profit = _calculateProfitInIsolate(card, viewModel);
          if (profit == null) return false;
          final filterValue = double.tryParse(value);
          if (filterValue == null) return false;
          switch (filter.operator) {
            case FilterOperator.equals:
              return profit == filterValue;
            case FilterOperator.greaterThan:
              return profit > filterValue;
            case FilterOperator.lessThan:
              return profit < filterValue;
            default:
              return true;
          }
        case 7: // Остатки
          final stocks = viewModel.totalStocksByNmId[card.nmID] ?? 0;
          final filterValue = int.tryParse(value);
          if (filterValue == null) return false;
          switch (filter.operator) {
            case FilterOperator.equals:
              return stocks == filterValue;
            case FilterOperator.greaterThan:
              return stocks > filterValue;
            case FilterOperator.lessThan:
              return stocks < filterValue;
            default:
              return true;
          }
        case 8: // Остатки WB
          final stocks = viewModel.totalStocksWBByNmId[card.nmID] ?? 0;
          final filterValue = int.tryParse(value);
          if (filterValue == null) return false;
          switch (filter.operator) {
            case FilterOperator.equals:
              return stocks == filterValue;
            case FilterOperator.greaterThan:
              return stocks > filterValue;
            case FilterOperator.lessThan:
              return stocks < filterValue;
            default:
              return true;
          }
        default:
          return true;
      }
    }).toList();
  }

  // Sort cards
  filteredCards.sort((a, b) {
    switch (sortColumnIndex) {
      case 1:
        return ascending ? a.nmID.compareTo(b.nmID) : b.nmID.compareTo(a.nmID);
      case 2:
        return ascending
            ? a.subjectName.compareTo(b.subjectName)
            : b.subjectName.compareTo(a.subjectName);
      case 3:
        return ascending
            ? a.vendorCode.compareTo(b.vendorCode)
            : b.vendorCode.compareTo(a.vendorCode);
      case 4:
        double priceA = viewModel.goodsPrices[a.nmID] ?? double.infinity;
        double priceB = viewModel.goodsPrices[b.nmID] ?? double.infinity;
        return ascending ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
      case 5:
        double? marginA = _calculateMarginInIsolate(a, viewModel);
        double? marginB = _calculateMarginInIsolate(b, viewModel);
        if (marginA == null && marginB == null) return 0;
        if (marginA == null) return 1;
        if (marginB == null) return -1;
        return ascending
            ? marginA.compareTo(marginB)
            : marginB.compareTo(marginA);
      case 6:
        double? profitA = _calculateProfitInIsolate(a, viewModel);
        double? profitB = _calculateProfitInIsolate(b, viewModel);
        if (profitA == null && profitB == null) return 0;
        if (profitA == null) return 1;
        if (profitB == null) return -1;
        return ascending
            ? profitA.compareTo(profitB)
            : profitB.compareTo(profitA);
      case 7:
        int stocksA = viewModel.totalStocksByNmId[a.nmID] ?? 0;
        int stocksB = viewModel.totalStocksByNmId[b.nmID] ?? 0;
        return ascending
            ? stocksA.compareTo(stocksB)
            : stocksB.compareTo(stocksA);
      case 8:
        int stocksWB = viewModel.totalStocksWBByNmId[a.nmID] ?? 0;
        int stocksWB2 = viewModel.totalStocksWBByNmId[b.nmID] ?? 0;
        return ascending
            ? stocksWB.compareTo(stocksWB2)
            : stocksWB2.compareTo(stocksWB);
      default:
        return 0;
    }
  });

  return filteredCards;
}

double? _calculateMarginInIsolate(
    ProductCard card, ProductCardsViewModel viewModel) {
  double? price = viewModel.goodsPrices[card.nmID];
  final costData = viewModel.productCosts[card.nmID];
  final wbTariff = viewModel.allTariffs
          .where((t) => t.subjectID == card.subjectID)
          .isNotEmpty
      ? viewModel.allTariffs.firstWhere((t) => t.subjectID == card.subjectID)
      : null;
  WbBoxTariff? boxTariff;
  WbPalletTariff? palletTariff;
  if (costData != null) {
    boxTariff = viewModel.allBoxTariffs
            .where((b) => b.warehouseName == costData.warehouseName)
            .isNotEmpty
        ? viewModel.allBoxTariffs
            .firstWhere((b) => b.warehouseName == costData.warehouseName)
        : null;
    palletTariff = viewModel.allPalletTariffs
            .where((b) => b.warehouseName == costData.warehouseName)
            .isNotEmpty
        ? viewModel.allPalletTariffs
            .firstWhere((b) => b.warehouseName == costData.warehouseName)
        : null;
  }
  if (price != null &&
      price > 0 &&
      costData != null &&
      wbTariff != null &&
      boxTariff != null) {
    double volumeLiters = (card.length * card.width * card.height) / 1000.0;
    double logistics = _calculateLogisticsInIsolate(
        boxTariff, palletTariff, volumeLiters, costData.isBox);
    double commissionPercent = wbTariff.kgvpMarketplace.ceilToDouble();
    double commission = price * (commissionPercent / 100);
    double costOfReturns = 0.0;
    if (costData.returnRate < 100) {
      const double returnLogisticsCost = 50.0;
      costOfReturns = (logistics + returnLogisticsCost) *
          (costData.returnRate / (100 - costData.returnRate));
    }
    double taxCost = price * (costData.taxRate / 100);
    double totalCosts = costData.costPrice +
        costData.delivery +
        costData.packaging +
        costData.paidAcceptance +
        logistics +
        commission +
        costOfReturns +
        taxCost;
    double marginPercent = ((price - totalCosts) / price) * 100;
    return marginPercent;
  }
  return null;
}

double? _calculateProfitInIsolate(
    ProductCard card, ProductCardsViewModel viewModel) {
  double? price = viewModel.goodsPrices[card.nmID];
  final costData = viewModel.productCosts[card.nmID];
  final wbTariff = viewModel.allTariffs
          .where((t) => t.subjectID == card.subjectID)
          .isNotEmpty
      ? viewModel.allTariffs.firstWhere((t) => t.subjectID == card.subjectID)
      : null;
  WbBoxTariff? boxTariff;
  WbPalletTariff? palletTariff;
  if (costData != null) {
    boxTariff = viewModel.allBoxTariffs
            .where((b) => b.warehouseName == costData.warehouseName)
            .isNotEmpty
        ? viewModel.allBoxTariffs
            .firstWhere((b) => b.warehouseName == costData.warehouseName)
        : null;
    palletTariff = viewModel.allPalletTariffs
            .where((b) => b.warehouseName == costData.warehouseName)
            .isNotEmpty
        ? viewModel.allPalletTariffs
            .firstWhere((b) => b.warehouseName == costData.warehouseName)
        : null;
  }
  if (price != null &&
      price > 0 &&
      costData != null &&
      wbTariff != null &&
      boxTariff != null) {
    double volumeLiters = (card.length * card.width * card.height) / 1000.0;
    double logistics = _calculateLogisticsInIsolate(
        boxTariff, palletTariff, volumeLiters, costData.isBox);
    double commissionPercent = wbTariff.kgvpMarketplace.ceilToDouble();
    double commission = price * (commissionPercent / 100);
    double costOfReturns = 0.0;
    if (costData.returnRate < 100) {
      const double returnLogisticsCost = 50.0;
      costOfReturns = (logistics + returnLogisticsCost) *
          (costData.returnRate / (100 - costData.returnRate));
    }
    double taxCost = price * (costData.taxRate / 100);
    double totalCosts = costData.costPrice +
        costData.delivery +
        costData.packaging +
        costData.paidAcceptance +
        logistics +
        commission +
        costOfReturns +
        taxCost;
    double profit = price - totalCosts;
    return profit;
  }
  return null;
}

double _calculateLogisticsInIsolate(WbBoxTariff? tariff,
    WbPalletTariff? tariffPallet, double volume, bool isBox) {
  if (!isBox && tariffPallet != null) {
    return volume < 1
        ? tariffPallet.palletDeliveryValueBase
        : (volume - 1) * tariffPallet.palletDeliveryValueLiter +
            tariffPallet.palletDeliveryValueBase;
  }
  if (isBox && tariff != null) {
    return volume < 1
        ? tariff.boxDeliveryBase
        : (volume - 1) * tariff.boxDeliveryLiter + tariff.boxDeliveryBase;
  }
  return 0.0;
}
