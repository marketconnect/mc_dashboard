import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mc_dashboard/presentation/ozon_product_cards_screen/ozon_product_cards_view_model.dart';
import 'package:mc_dashboard/domain/entities/ozon_product.dart';

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

class OzonProductCardsScreen extends StatefulWidget {
  const OzonProductCardsScreen({
    super.key,
  });

  @override
  State<OzonProductCardsScreen> createState() => _OzonProductCardsScreenState();
}

class _OzonProductCardsScreenState extends State<OzonProductCardsScreen> {
  bool _ascending = false;
  int _sortColumnIndex = 1;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  List<OzonProduct> _filteredAndSortedProducts = [];
  List<OzonProduct> _displayedProducts = [];
  bool _isProcessing = false;
  bool _isLoadingMore = false;
  Timer? _debounceTimer;
  static const int _chunkSize = 50;
  final ScrollController _scrollController = ScrollController();

  // Filter state
  final Map<int, FilterState> _columnFilters = {};
  final TextEditingController _marginFilterController = TextEditingController();
  final TextEditingController _profitFilterController = TextEditingController();
  final TextEditingController _stocksFilterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OzonProductCardsViewModel>().asyncInit();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _marginFilterController.dispose();
    _profitFilterController.dispose();
    _stocksFilterController.dispose();
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
        _displayedProducts.length >= _filteredAndSortedProducts.length) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
      final startIndex = _displayedProducts.length;
      final endIndex =
          (startIndex + _chunkSize).clamp(0, _filteredAndSortedProducts.length);
      _displayedProducts
          .addAll(_filteredAndSortedProducts.sublist(startIndex, endIndex));
      _isLoadingMore = false;
    });
  }

  Future<void> _processData() async {
    if (_isProcessing) return;
    _isProcessing = true;
    setState(() {
      _displayedProducts = [];
    });

    try {
      final viewModel = context.read<OzonProductCardsViewModel>();
      final products = viewModel.productCards;

      if (products.isEmpty) {
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      // Process data in isolate
      final processedProducts = await compute(_processProductsInIsolate, {
        'products': products,
        'searchQuery': _searchQuery,
        'columnFilters': _columnFilters,
        'sortColumnIndex': _sortColumnIndex,
        'ascending': _ascending,
        'viewModel': viewModel,
      });

      setState(() {
        _filteredAndSortedProducts = processedProducts;
        _displayedProducts = processedProducts.sublist(
            0, _chunkSize.clamp(0, processedProducts.length));
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
      case 3: // Рентабельность FBS
        title = 'Фильтр по рентабельности FBS';
        controller = _marginFilterController;
        defaultOperator = FilterOperator.greaterThan;
        break;
      case 4: // Чистая прибыль FBS
        title = 'Фильтр по чистой прибыли FBS';
        controller = _profitFilterController;
        defaultOperator = FilterOperator.greaterThan;
        break;
      case 7: // Остатки FBS
        title = 'Фильтр по остаткам FBS';
        controller = _stocksFilterController;
        defaultOperator = FilterOperator.greaterThan;
        break;
      default:
        return;
    }

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
                  labelText: 'Значение',
                ),
                keyboardType: TextInputType.number,
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

  @override
  Widget build(BuildContext context) {
    return Consumer<OzonProductCardsViewModel>(
      builder: (context, viewModel, child) {
        // Process data when ViewModel's data changes
        if (viewModel.productCards.isNotEmpty &&
            _filteredAndSortedProducts.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _processData();
          });
        }

        return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
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
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildProductTable(viewModel),
                    ),
            ));
      },
    );
  }

  Widget _buildProductTable(OzonProductCardsViewModel viewModel) {
    return Column(
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
                    _sortableColumn('Артикул', 1),
                    _sortableColumn('Цена', 2),
                    _sortableColumn('Рентабельность FBS', 3),
                    _sortableColumn('Чистая прибыль FBS', 4),
                    _sortableColumn('Рентабельность FBO', 5),
                    _sortableColumn('Чистая прибыль FBO', 6),
                    _sortableColumn('Остатки FBS', 7),
                    _sortableColumn('Остатки FBO', 8),
                    // _sortableColumn('Расходы', 9),
                    DataColumn(
                      label: Text('Действие',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface)),
                    ),
                  ],
                  rows: _displayedProducts
                      .map((product) => _buildDataRow(viewModel, product))
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

  DataRow _buildDataRow(
      OzonProductCardsViewModel viewModel, OzonProduct product) {
    final price = viewModel.prices[product.offerId];
    final fbsStock = viewModel.fbsStocks[product.offerId];
    final fboStock = viewModel.fboStocks[product.offerId];
    final image = viewModel.productInfo[product.offerId]?.image;
    // final costData = viewModel.productCosts[int.tryParse(product.offerId) ?? 0];
    // final suggestion = viewModel.costDataSuggestions[product.offerId];

    // Calculate profits and margins
    final profitFbs = viewModel.calcProfitFbs(product.offerId);
    final profitFbo = viewModel.calcProfitFbo(product.offerId);
    final marginFbs = viewModel.calcMarginFbs(product.offerId);
    final marginFbo = viewModel.calcMarginFbo(product.offerId);
    final navToOzonProductCardScreen = viewModel.navToOzonProductCardScreen;

    final rowColor = product.isDiscounted
        ? Colors.red[50]
        : product.archived
            ? Colors.grey[50]
            : null;

    return DataRow(
      color: WidgetStateProperty.all(rowColor),
      cells: [
        DataCell(
          image != null
              ? CachedNetworkImage(
                  imageUrl: image,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )
              : const Icon(Icons.image_not_supported, color: Colors.grey),
        ),
        _copyableCell(product.offerId),
        DataCell(
          Text(price != null ? '${price.price.price} ₽' : '—',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        ),
        DataCell(
          Text(marginFbs != null ? '${marginFbs.toStringAsFixed(2)}%' : '—',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        ),
        DataCell(
          Text(profitFbs != null ? '${profitFbs.toStringAsFixed(2)} ₽' : '—',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        ),
        DataCell(
          Text(marginFbo != null ? '${marginFbo.toStringAsFixed(2)}%' : '—',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        ),
        DataCell(
          Text(profitFbo != null ? '${profitFbo.toStringAsFixed(2)} ₽' : '—',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        ),
        DataCell(
          Tooltip(
            message: "Остатки на складах FBS",
            child: Text(
              fbsStock?.present.toString() ?? "—",
              style: TextStyle(
                color: (fbsStock?.present ?? 0) > 0 ? Colors.green : Colors.red,
              ),
            ),
          ),
        ),
        DataCell(
          Tooltip(
            message: "Остатки на складах FBO",
            child: Text(
              fboStock?.validStockCount.toString() ?? "—",
              style: TextStyle(
                color: (fboStock?.validStockCount ?? 0) > 0
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ),
        ),
        DataCell(
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF005bff),
                textStyle:
                    TextStyle(color: Theme.of(context).colorScheme.surface)),
            onPressed: () => navToOzonProductCardScreen(
              product.productId,
              product.offerId,
            ),
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
          if ([3, 4, 7].contains(index)) ...[
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
}

Future<List<OzonProduct>> _processProductsInIsolate(
    Map<String, dynamic> params) async {
  final products = params['products'] as List<OzonProduct>;
  final searchQuery = params['searchQuery'] as String;
  final columnFilters = params['columnFilters'] as Map<int, FilterState>;
  final sortColumnIndex = params['sortColumnIndex'] as int;
  final ascending = params['ascending'] as bool;
  final viewModel = params['viewModel'] as OzonProductCardsViewModel;

  List<OzonProduct> filteredProducts = products;

  // Apply search filter
  if (searchQuery.isNotEmpty) {
    filteredProducts = filteredProducts.where((product) {
      return product.offerId.toLowerCase().contains(searchQuery);
    }).toList();
  }

  // Apply column filters
  for (var entry in columnFilters.entries) {
    final columnIndex = entry.key;
    final filter = entry.value;
    final value = filter.value.toLowerCase();

    filteredProducts = filteredProducts.where((product) {
      switch (columnIndex) {
        case 3: // Рентабельность FBS
          final margin = viewModel.calcMarginFbs(product.offerId);
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
        case 4: // Чистая прибыль FBS
          final profit = viewModel.calcProfitFbs(product.offerId);
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
        case 7: // Остатки FBS
          final stocks = viewModel.fbsStocks[product.offerId]?.present ?? 0;
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

  // Sort products
  filteredProducts.sort((a, b) {
    switch (sortColumnIndex) {
      case 1: // Артикул
        return ascending
            ? a.offerId.compareTo(b.offerId)
            : b.offerId.compareTo(a.offerId);
      case 2: // Цена
        double priceA =
            viewModel.prices[a.offerId]?.price.price ?? double.infinity;
        double priceB =
            viewModel.prices[b.offerId]?.price.price ?? double.infinity;
        return ascending ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
      case 3: // Рентабельность FBS
        double? marginA = viewModel.calcMarginFbs(a.offerId);
        double? marginB = viewModel.calcMarginFbs(b.offerId);
        if (marginA == null && marginB == null) return 0;
        if (marginA == null) return 1;
        if (marginB == null) return -1;
        return ascending
            ? marginA.compareTo(marginB)
            : marginB.compareTo(marginA);
      case 4: // Чистая прибыль FBS
        double? profitA = viewModel.calcProfitFbs(a.offerId);
        double? profitB = viewModel.calcProfitFbs(b.offerId);
        if (profitA == null && profitB == null) return 0;
        if (profitA == null) return 1;
        if (profitB == null) return -1;
        return ascending
            ? profitA.compareTo(profitB)
            : profitB.compareTo(profitA);
      case 5: // Рентабельность FBO
        double? marginA = viewModel.calcMarginFbo(a.offerId);
        double? marginB = viewModel.calcMarginFbo(b.offerId);
        if (marginA == null && marginB == null) return 0;
        if (marginA == null) return 1;
        if (marginB == null) return -1;
        return ascending
            ? marginA.compareTo(marginB)
            : marginB.compareTo(marginA);
      case 6: // Чистая прибыль FBO
        double? profitA = viewModel.calcProfitFbo(a.offerId);
        double? profitB = viewModel.calcProfitFbo(b.offerId);
        if (profitA == null && profitB == null) return 0;
        if (profitA == null) return 1;
        if (profitB == null) return -1;
        return ascending
            ? profitA.compareTo(profitB)
            : profitB.compareTo(profitA);
      case 7: // Остатки FBS
        int stocksA = viewModel.fbsStocks[a.offerId]?.present ?? 0;
        int stocksB = viewModel.fbsStocks[b.offerId]?.present ?? 0;
        return ascending
            ? stocksA.compareTo(stocksB)
            : stocksB.compareTo(stocksA);
      case 8: // Остатки FBO
        int stocksA = viewModel.fboStocks[a.offerId]?.validStockCount ?? 0;
        int stocksB = viewModel.fboStocks[b.offerId]?.validStockCount ?? 0;
        return ascending
            ? stocksA.compareTo(stocksB)
            : stocksB.compareTo(stocksA);
      // case 9: // Расходы
      //   double costA =
      //       viewModel.productCosts[int.tryParse(a.offerId) ?? 0]?.costPrice ??
      //           double.infinity;
      //   double costB =
      //       viewModel.productCosts[int.tryParse(b.offerId) ?? 0]?.costPrice ??
      //           double.infinity;
      //   return ascending ? costA.compareTo(costB) : costB.compareTo(costA);
      default:
        return 0;
    }
  });

  return filteredProducts;
}
