import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mc_dashboard/domain/entities/product_card.dart';
import 'package:mc_dashboard/domain/entities/wb_box_tariff.dart';
import 'package:mc_dashboard/presentation/product_cards_screen/product_cards_view_model.dart';
import 'package:provider/provider.dart';

class ProductCardsScreen extends StatefulWidget {
  const ProductCardsScreen({super.key});

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

  double? _calculateMargin(ProductCard card, ProductCardsViewModel viewModel) {
    double? price = viewModel.goodsPrices[card.nmID];
    final costData = viewModel.productCosts[card.nmID];
    final wbTariff = viewModel.allTariffs
            .where((t) => t.subjectID == card.subjectID)
            .isNotEmpty
        ? viewModel.allTariffs.firstWhere((t) => t.subjectID == card.subjectID)
        : null;
    WbBoxTariff? boxTariff;
    if (costData != null) {
      boxTariff = viewModel.allBoxTariffs
              .where((b) => b.warehouseName == costData.warehouseName)
              .isNotEmpty
          ? viewModel.allBoxTariffs
              .firstWhere((b) => b.warehouseName == costData.warehouseName)
          : null;
    }
    if (price != null &&
        price > 0 &&
        costData != null &&
        wbTariff != null &&
        boxTariff != null) {
      double volumeLiters = (card.length * card.width * card.height) / 1000.0;
      double logistics = volumeLiters < 1
          ? boxTariff.boxDeliveryBase
          : (volumeLiters - 1) * boxTariff.boxDeliveryLiter +
              boxTariff.boxDeliveryBase;
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
          appBar: AppBar(
            title: const Text("Список карточек товаров"),
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
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
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
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 12.0), // Делаем поле уже
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.trim().toLowerCase();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : viewModel.errorMessage != null
                  ? Center(
                      child: Text(
                        viewModel.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : _buildProductTable(viewModel),
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
              child: DataTable(
                columnSpacing: 20,
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _ascending,
                columns: [
                  const DataColumn(label: Text('Фото')),
                  _sortableColumn('nmID', 1),
                  _sortableColumn('subjectID', 2),
                  _sortableColumn('Название предмета', 3),
                  _sortableColumn('Код продавца', 4),
                  const DataColumn(label: Text('Цена')),
                  _sortableColumn('Рентабельность', 6),
                  const DataColumn(label: Text('Длина (см)')),
                  const DataColumn(label: Text('Ширина (см)')),
                  const DataColumn(label: Text('Высота (см)')),
                  const DataColumn(label: Text('Размеры валидны?')),
                  const DataColumn(label: Text('Действие')),
                ],
                rows: sortedCards
                    .map((card) => _buildDataRow(viewModel, card))
                    .toList(),
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

    // Если нет цены или нет costData, либо нет тарифа — ставим прочерк.
    String marginText = "—";

    // 1. Ищем тариф WB по subjectID (который в card.subjectID)
    final wbTariff = viewModel.allTariffs
            .where((t) => t.subjectID == card.subjectID)
            .isNotEmpty
        ? viewModel.allTariffs.firstWhere((t) => t.subjectID == card.subjectID)
        : null;

    // 2. Ищем тариф короба по warehouseName
    // (который берём из costData.warehouseName)
    // если costData == null — не сможем найти boxTariff
    WbBoxTariff? boxTariff;
    if (costData != null) {
      boxTariff = viewModel.allBoxTariffs
              .where((b) => b.warehouseName == costData.warehouseName)
              .isNotEmpty
          ? viewModel.allBoxTariffs
              .firstWhere((b) => b.warehouseName == costData.warehouseName)
          : null;
    }

    // Если всё необходимое есть
    if (price != null &&
        price > 0 &&
        costData != null &&
        wbTariff != null &&
        boxTariff != null) {
      // ----- Расчёт логистики -----
      double volumeLiters = (card.length * card.width * card.height) / 1000.0;
      double logistics = volumeLiters < 1
          ? boxTariff.boxDeliveryBase
          : (volumeLiters - 1) * boxTariff.boxDeliveryLiter +
              boxTariff.boxDeliveryBase;

      // ----- Расчёт комиссии -----
      // в примере вы писали:
      // double commissionPercent = (wbTariff.kgvpMarketplace.ceil() ?? 0).toDouble();
      // но .ceil() уже вернёт int, поэтому примерно так:
      double commissionPercent = wbTariff.kgvpMarketplace.ceilToDouble();
      double commission = price * (commissionPercent / 100);

      // ----- Расчёт возвратов -----
      // Допустим, формула та же, что и в ProductCardScreen:
      // const double returnLogisticsCost = 50.0;
      // double costOfReturns = (logistics + returnLogisticsCost) *
      //    (costData.returnRate / (100 - costData.returnRate));
      double costOfReturns = 0.0;
      if (costData.returnRate < 100) {
        const double returnLogisticsCost = 50.0;
        costOfReturns = (logistics + returnLogisticsCost) *
            (costData.returnRate / (100 - costData.returnRate));
      }

      // ----- Расчёт налога -----
      // taxRate хранится в costData.taxRate, допустим 7 = 7%
      double taxCost = price * (costData.taxRate / 100);

      // ----- Складываем все затраты -----
      double totalCosts = costData.costPrice +
          costData.delivery +
          costData.packaging +
          costData.paidAcceptance +
          logistics +
          commission +
          costOfReturns +
          taxCost;

      // ----- Рентабельность (%) -----
      double marginPercent = ((price - totalCosts) / price) * 100;

      marginText = "${marginPercent.toStringAsFixed(1)}%";
    }

    return DataRow(
      cells: [
        // (1) Фото
        DataCell(
          card.photoUrl.isNotEmpty
              ? Image.network(
                  card.photoUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )
              : const Icon(Icons.image_not_supported),
        ),
        // (2) nmID
        _copyableCell(card.nmID.toString()),
        // (3) subjectID
        _copyableCell(card.subjectID.toString()),
        // (4) Название предмета
        _copyableCell(card.subjectName),
        // (5) Код продавца
        _copyableCell(card.vendorCode),
        // (6) Цена
        DataCell(Text(price != null ? "${price.toStringAsFixed(2)} ₽" : "—")),
        // (7) Рентабельность
        DataCell(Text(marginText)),
        // (8) Длина (см)
        DataCell(Text(card.length.toString())),
        // (9) Ширина (см)
        DataCell(Text(card.width.toString())),
        // (10) Высота (см)
        DataCell(Text(card.height.toString())),
        // (11) Размеры валидны?
        DataCell(
          Icon(
            card.isValidDimensions ? Icons.check : Icons.close,
            color: card.isValidDimensions ? Colors.green : Colors.red,
          ),
        ),
        // (12) Кнопка "Перейти"
        DataCell(
          ElevatedButton(
            onPressed: () => viewModel.navTo(card.imtID, card.nmID),
            child: const Text("Перейти"),
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
      label: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
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
        case 2:
          return _ascending
              ? a.subjectID.compareTo(b.subjectID)
              : b.subjectID.compareTo(a.subjectID);
        case 3:
          return _ascending
              ? a.subjectName.compareTo(b.subjectName)
              : b.subjectName.compareTo(a.subjectName);
        case 4:
          return _ascending
              ? a.vendorCode.compareTo(b.vendorCode)
              : b.vendorCode.compareTo(a.vendorCode);
        case 6: // Сортировка по рентабельности
          double? marginA = _calculateMargin(a, viewModel);
          double? marginB = _calculateMargin(b, viewModel);
          if (marginA == null && marginB == null) return 0;
          if (marginA == null) return 1; // пустые значения в конце
          if (marginB == null) return -1;
          return _ascending
              ? marginA.compareTo(marginB)
              : marginB.compareTo(marginA);
        default:
          return 0;
      }
    });
  }

  // DataRow _buildDataRow(ProductCardsViewModel viewModel, ProductCard card) {
  //   return DataRow(cells: [
  //     DataCell(
  //       card.photoUrl.isNotEmpty
  //           ? Image.network(card.photoUrl,
  //               width: 50, height: 50, fit: BoxFit.cover)
  //           : const Icon(Icons.image_not_supported),
  //     ),
  //     _copyableCell(card.nmID.toString()),
  //     _copyableCell(card.subjectID.toString()),
  //     _copyableCell(card.subjectName),
  //     _copyableCell(card.vendorCode),
  //     DataCell(Text(card.length.toString())),
  //     DataCell(Text(card.width.toString())),
  //     DataCell(Text(card.height.toString())),
  //     DataCell(Icon(card.isValidDimensions ? Icons.check : Icons.close,
  //         color: card.isValidDimensions ? Colors.green : Colors.red)),
  //     DataCell(
  //       ElevatedButton(
  //         onPressed: () => viewModel.navTo(card.imtID, card.nmID),
  //         child: const Text("Перейти"),
  //       ),
  //     ),
  //   ]);
  // }

  DataCell _copyableCell(String text) {
    return DataCell(
      GestureDetector(
        onTap: () {
          Clipboard.setData(ClipboardData(text: text));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('"$text" скопировано в буфер обмена')),
          );
        },
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.blue, decoration: TextDecoration.underline),
        ),
      ),
    );
  }
}
