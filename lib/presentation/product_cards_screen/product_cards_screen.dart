import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mc_dashboard/domain/entities/product_card.dart';
import 'package:mc_dashboard/domain/entities/wb_box_tariff.dart';
import 'package:mc_dashboard/domain/entities/wb_pallet_tariff.dart';
import 'package:mc_dashboard/presentation/product_cards_screen/product_cards_view_model.dart';
import 'package:mc_dashboard/presentation/widgets/progress_bar.dart';

import 'package:provider/provider.dart';

class ProductCardsScreen extends StatefulWidget {
  const ProductCardsScreen({Key? key});

  @override
  State<ProductCardsScreen> createState() => _ProductCardsScreenState();
}

class _ProductCardsScreenState extends State<ProductCardsScreen> {
  bool _ascending = false;
  int _sortColumnIndex = 6;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  double _calculateLogistics(WbBoxTariff? tariff, WbPalletTariff? tariffPallet,
      double volume, bool isBox) {
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

  double _calculateVolumeLiters(int length, int width, int height) {
    return (length * width * height) / 1000.0;
  }

  double? _calculateProfit(ProductCard card, ProductCardsViewModel viewModel) {
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
      double volumeLiters =
          _calculateVolumeLiters(card.length, card.width, card.height);
      double logistics = _calculateLogistics(
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

  double? _calculateMargin(ProductCard card, ProductCardsViewModel viewModel) {
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
      double volumeLiters =
          _calculateVolumeLiters(card.length, card.width, card.height);
      double logistics = _calculateLogistics(
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

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductCardsViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(110),
            child: AppBar(
              scrolledUnderElevation: 2,
              shadowColor: Colors.black,
              surfaceTintColor: Colors.transparent,
              title: const Text(
                "Список карточек товаров",
                style: TextStyle(color: Colors.black),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 400,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: "Поиск по nmID или коду продавца...",
                            hintStyle: const TextStyle(color: Colors.grey),
                            prefixIcon:
                                const Icon(Icons.search, color: Colors.grey),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear,
                                        color: Colors.grey),
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                        _searchQuery = "";
                                      });
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 12.0,
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value.trim().toLowerCase();
                            });
                          },
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: viewModel.isLoading
              ? Center(
                  child: McProgressBar(),
                )
              : viewModel.errorMessage != null
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
        );
      },
    );
  }

  Widget _buildProductTable(ProductCardsViewModel viewModel) {
    List<ProductCard> sortedCards = _filterCards(viewModel.productCards);
    _sortProductCards(sortedCards, viewModel);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
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
                  dataRowHeight: 55,
                  headingRowHeight: 55,
                  columnSpacing: 20,
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _ascending,
                  columns: [
                    DataColumn(
                      label: const Text('Фото',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    _sortableColumn('nmID', 1),
                    // _sortableColumn('subjectID', 2),
                    _sortableColumn('Название предмета', 3),
                    _sortableColumn('Код продавца', 4),
                    _sortableColumn('Цена', 5),
                    _sortableColumn('Рентабельность', 6),
                    _sortableColumn('Чистая прибыль', 7),
                    DataColumn(
                      label: const Text('Длина (см)',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    DataColumn(
                      label: const Text('Ширина (см)',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    DataColumn(
                      label: const Text('Высота (см)',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    DataColumn(
                      label: const Text('Размеры валидны?',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    DataColumn(
                      label: const Text('Действие',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                  rows: sortedCards
                      .map((card) => _buildDataRow(viewModel, card))
                      .toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  DataRow _buildDataRow(ProductCardsViewModel viewModel, ProductCard card) {
    double? price = viewModel.goodsPrices[card.nmID];
    final costData = viewModel.productCosts[card.nmID];
    final rowColor = costData == null || costData.costPrice == 0
        ? MaterialStateProperty.all(
            Theme.of(context).colorScheme.errorContainer.withOpacity(0.3))
        : MaterialStateProperty.all(Theme.of(context).colorScheme.surface);
    String marginText = "—";
    String netProfitText = "—";

    final wbTariff = viewModel.allTariffs.firstWhere(
      (t) => t.subjectID == card.subjectID,
    );
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

    if (price != null && price > 0 && costData != null && boxTariff != null) {
      double volumeLiters = (card.length * card.width * card.height) / 1000.0;
      double logistics = _calculateLogistics(
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
      marginText = "${marginPercent.toStringAsFixed(1)}%";

      double netProfit = price - totalCosts;
      netProfitText = "${netProfit.toStringAsFixed(2)} ₽";
    }
    final onSubjectNameTap = viewModel.onNavigateToSubjectProductsScreen;
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
        // _copyableCell(card.subjectID.toString()),
        _categoryCell(
          card.subjectName,
          card.subjectID,
          onSubjectNameTap,
        ),
        _copyableCell(card.vendorCode),
        DataCell(
          Text(price != null ? "${price.toStringAsFixed(2)} ₽" : "—",
              style: const TextStyle(color: Colors.black)),
        ),
        DataCell(
          Text(marginText, style: const TextStyle(color: Colors.black)),
        ),
        DataCell(
          Text(netProfitText, style: const TextStyle(color: Colors.black)),
        ),
        DataCell(
          Text(card.length.toString(),
              style: const TextStyle(color: Colors.black)),
        ),
        DataCell(
          Text(card.width.toString(),
              style: const TextStyle(color: Colors.black)),
        ),
        DataCell(
          Text(card.height.toString(),
              style: const TextStyle(color: Colors.black)),
        ),
        DataCell(
          Icon(
            card.isValidDimensions ? Icons.check : Icons.close,
            color: card.isValidDimensions ? Colors.green : Colors.red,
          ),
        ),
        DataCell(
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.onPrimary,
                textStyle:
                    TextStyle(color: Theme.of(context).colorScheme.surface)),
            onPressed: () => viewModel.navTo(card.imtID, card.nmID),
            child: const Text("Перейти", style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  List<ProductCard> _filterCards(List<ProductCard> productCards) {
    if (_searchQuery.isEmpty) {
      return productCards;
    }

    return productCards.where((card) {
      return card.nmID.toString().contains(_searchQuery) ||
          card.vendorCode.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  DataColumn _sortableColumn(String title, int index) {
    return DataColumn(
      label: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black)),
      onSort: (columnIndex, ascending) {
        setState(() {
          _sortColumnIndex = columnIndex;
          _ascending = ascending;
        });
      },
    );
  }

  void _sortProductCards(
      List<ProductCard> cards, ProductCardsViewModel viewModel) {
    cards.sort((a, b) {
      switch (_sortColumnIndex) {
        case 1:
          return _ascending
              ? a.nmID.compareTo(b.nmID)
              : b.nmID.compareTo(a.nmID);
        // case 2:
        //   return _ascending
        //       ? a.subjectID.compareTo(b.subjectID)
        //       : b.subjectID.compareTo(a.subjectID);
        case 3:
          return _ascending
              ? a.subjectName.compareTo(b.subjectName)
              : b.subjectName.compareTo(a.subjectName);
        case 4:
          return _ascending
              ? a.vendorCode.compareTo(b.vendorCode)
              : b.vendorCode.compareTo(a.vendorCode);
        case 5:
          double priceA = viewModel.goodsPrices[a.nmID] ?? double.infinity;
          double priceB = viewModel.goodsPrices[b.nmID] ?? double.infinity;
          return _ascending
              ? priceA.compareTo(priceB)
              : priceB.compareTo(priceA);
        case 6:
          double? marginA = _calculateMargin(a, viewModel);
          double? marginB = _calculateMargin(b, viewModel);
          if (marginA == null && marginB == null) return 0;
          if (marginA == null) return 1;
          if (marginB == null) return -1;
          return _ascending
              ? marginA.compareTo(marginB)
              : marginB.compareTo(marginA);
        case 7:
          double? profitA = _calculateProfit(a, viewModel);
          double? profitB = _calculateProfit(b, viewModel);
          if (profitA == null && profitB == null) return 0;
          if (profitA == null) return 1;
          if (profitB == null) return -1;
          return _ascending
              ? profitA.compareTo(profitB)
              : profitB.compareTo(profitA);
        default:
          return 0;
      }
    });
  }

  // TODO Add for category name onnavigate to a related category analisys screen (category screen)
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
