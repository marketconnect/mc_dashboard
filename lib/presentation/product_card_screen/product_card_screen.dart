import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mc_dashboard/core/utils/open_url.dart';

import 'package:mc_dashboard/domain/entities/product_card.dart';
import 'package:mc_dashboard/domain/entities/product_cost_data.dart';
import 'package:mc_dashboard/domain/entities/product_cost_data_details.dart';
import 'package:mc_dashboard/domain/entities/wb_box_tariff.dart';
import 'package:mc_dashboard/domain/entities/wb_pallet_tariff.dart';
import 'package:mc_dashboard/domain/entities/wb_tariff.dart';
import 'package:mc_dashboard/presentation/product_card_screen/product_card_view_model.dart';

import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:provider/provider.dart';

// TODO Add current quantity and Inventory Threshold (quantity that triggers the notification (some kind of alarm -> AGENT ))
class ProductCardScreen extends StatefulWidget {
  const ProductCardScreen({super.key});

  @override
  State<ProductCardScreen> createState() => _ProductCardScreenState();
}

class _ProductCardScreenState extends State<ProductCardScreen> {
  String _selectedWarehouse = "Маркетплейс";

  // Controllers
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _deliveryController = TextEditingController();
  final TextEditingController _packageController = TextEditingController();
  final TextEditingController _paidAcceptanceController =
      TextEditingController();
  final TextEditingController _returnRateController = TextEditingController();
  final TextEditingController _storageController = TextEditingController();
  final TextEditingController _taxRateController = TextEditingController();
  final TextEditingController _desiredMarginController1 =
      TextEditingController();
  final TextEditingController _desiredMarginController2 =
      TextEditingController();
  final TextEditingController _desiredMarginController3 =
      TextEditingController();

  int _selectedVariant = 1; // выбранный вариант рентабельности

  @override
  void initState() {
    super.initState();
    _addAllListeners();
  }

  void _addAllListeners() {
    _costController.addListener(_onInputChanged);
    _deliveryController.addListener(_onInputChanged);
    _packageController.addListener(_onInputChanged);
    _paidAcceptanceController.addListener(_onInputChanged);
    _returnRateController.addListener(_onInputChanged);
    _storageController.addListener(_onInputChanged);
    _taxRateController.addListener(_onInputChanged);
    _desiredMarginController1.addListener(_onMarginChanged);
    _desiredMarginController2.addListener(_onMarginChanged);
    _desiredMarginController3.addListener(_onMarginChanged);
  }

  void _removeAllListeners() {
    _costController.removeListener(_onInputChanged);
    _deliveryController.removeListener(_onInputChanged);
    _packageController.removeListener(_onInputChanged);
    _paidAcceptanceController.removeListener(_onInputChanged);
    _returnRateController.removeListener(_onInputChanged);
    _storageController.removeListener(_onInputChanged);
    _taxRateController.removeListener(_onInputChanged);
    _desiredMarginController1.removeListener(_onMarginChanged);
    _desiredMarginController2.removeListener(_onMarginChanged);
    _desiredMarginController3.removeListener(_onMarginChanged);
  }

  void _onInputChanged() {
    final model = context.read<ProductCardViewModel>();
    _updateProductCostData(model);
  }

  void _onMarginChanged() {
    final model = context.read<ProductCardViewModel>();
    _updateProductCostData(model);
    if (model.productCostData != null) {
      model.saveProductCost(model.productCostData!);
    }
  }

  @override
  void dispose() {
    _removeAllListeners();
    _costController.dispose();
    _deliveryController.dispose();
    _packageController.dispose();
    _paidAcceptanceController.dispose();
    _returnRateController.dispose();
    _storageController.dispose();
    _desiredMarginController1.dispose();
    _desiredMarginController2.dispose();
    _desiredMarginController3.dispose();
    _taxRateController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fillData();
  }

  void _fillData() {
    final model = context.read<ProductCardViewModel>();
    final costData = model.productCostData;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (costData != null) {
        _safeFillController(_costController, costData.costPrice.toString());
        _safeFillController(_deliveryController, costData.delivery.toString());
        _safeFillController(_packageController, costData.packaging.toString());
        _safeFillController(
            _paidAcceptanceController, costData.paidAcceptance.toString());
        _safeFillController(
            _returnRateController, costData.returnRate.toString());
        _safeFillController(_taxRateController, costData.taxRate.toString());
        _safeFillController(
            _desiredMarginController1, costData.desiredMargin1.toString());
        _safeFillController(
            _desiredMarginController2, costData.desiredMargin2.toString());
        _safeFillController(
            _desiredMarginController3, costData.desiredMargin3.toString());
      }
      _safeFillController(_storageController, "0");
      if (model.selectedWarehouse != null) {
        setState(() {
          _selectedWarehouse = model.selectedWarehouse!;
        });
      }
    });
  }

  void _safeFillController(TextEditingController controller, String text) {
    if (controller.text.isEmpty) {
      controller.text = text;
    }
  }

  void _updateProductCostData(ProductCardViewModel model) {
    model.updateProductCostData(
      costPrice: double.tryParse(_costController.text) ?? 0,
      delivery: double.tryParse(_deliveryController.text) ?? 0,
      packaging: double.tryParse(_packageController.text) ?? 0,
      paidAcceptance: double.tryParse(_paidAcceptanceController.text) ?? 0,
      returnRate: double.tryParse(_returnRateController.text) ?? 10.0,
      taxRate: int.tryParse(_taxRateController.text) ?? 7,
      desiredMargin1: double.tryParse(_desiredMarginController1.text) ?? 30,
      desiredMargin2: double.tryParse(_desiredMarginController2.text) ?? 35,
      desiredMargin3: double.tryParse(_desiredMarginController3.text) ?? 40,
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ProductCardViewModel>();
    final productCard = model.productCard;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(productCard?.title ?? "Loading..."),
            Text(
              'WB',
              style: TextStyle(
                color: Color(0xFF9a41fe),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (model.hasNextProduct)
            IconButton(
              icon: const Icon(Icons.navigate_next),
              tooltip: 'Следующий товар',
              onPressed: () => model.navigateToNextProduct(),
            ),
        ],
        scrolledUnderElevation: 2,
        shadowColor: Colors.black,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        tooltip: 'Меню',
        heroTag: 'speed-dial-hero-tag',
        backgroundColor: Color(0xFF9a41fe),
        foregroundColor: Theme.of(context).colorScheme.surface,
        visible: true,
        curve: Curves.bounceIn,
        children: [
          SpeedDialChild(
            label: 'Товары',
            labelStyle: const TextStyle(fontSize: 16.0),
            onTap: () =>
                openUrl('https://seller.wildberries.ru/new-goods/all-goods'),
          ),
          SpeedDialChild(
            label: 'Цены',
            labelStyle: const TextStyle(fontSize: 16.0),
            onTap: () =>
                openUrl('https://seller.wildberries.ru/discount-and-prices'),
          ),
          SpeedDialChild(
            label: 'Карточка',
            labelStyle: const TextStyle(fontSize: 16.0),
            onTap: () {
              openUrl(
                  'https://www.wildberries.ru/catalog/${model.nmID}/detail.aspx');
            },
          ),
          if (model.hasNextProduct)
            SpeedDialChild(
              label: 'Следующий товар',
              labelStyle: const TextStyle(fontSize: 16.0),
              child: const Icon(Icons.navigate_next),
              onTap: () => model.navigateToNextProduct(),
            ),
        ],
        // onOpen: () => debugPrint('OPENING DIAL'),
        // onClose: () => debugPrint('DIAL CLOSED'),
      ),
      body: OverlayLoaderWithAppIcon(
        isLoading: model.isLoading,
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
                    fontFamily: GoogleFonts.waitingForTheSunrise().fontFamily,
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
                    fontFamily: GoogleFonts.waitingForTheSunrise().fontFamily,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        child: model.errorMessage != null
            ? Center(
                child: Text(
                  model.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProductCardDetails(model),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildProductCardDetails(ProductCardViewModel model) {
    final productCard = model.productCard;
    if (productCard == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final widgets = <Widget>[];

    // Блок с информацией о товаре
    final double? goodPrice = model.goodPrice;
    if (goodPrice != null) {
      widgets
          .add(_buildInfoSection(productCard, model.volumeLiters, goodPrice));
    }

    // Блок с выбором склада
    final warehouses = [
      "Маркетплейс",
      "Доставка из-за рубежа",
      "Доставка на склад"
    ];
    widgets.add(_buildWarehouseSection(model, warehouses));

    // Блок с выбором типа доставки
    widgets.add(_buildDeliveryTypeSection(model));

    // Блок с расходами
    if (model.productCostData != null && model.wbTariff != null) {
      WbBoxTariff? boxTariff;
      WbPalletTariff? palletTariff;
      if (model.boxTariffs.isNotEmpty) {
        boxTariff = model.boxTariffs.first;
      }
      if (model.palletTariffs.isNotEmpty) {
        palletTariff = model.palletTariffs.first;
      }

      // Блок ручного ввода расходов
      widgets.add(Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Расходы',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _buildNumberInputField("Себестоимость", _costController,
                  onInputChanged: null),
              _buildNumberInputField("Доставка", _deliveryController,
                  onInputChanged: null),
              _buildNumberInputField("Упаковка", _packageController,
                  onInputChanged: null),
              _buildNumberInputField("Платный прием", _paidAcceptanceController,
                  onInputChanged: null),
              _buildNumberInputField("Возвраты", _returnRateController,
                  unit: "%", onInputChanged: null),
              _buildNumberInputField("Хранение", _storageController,
                  onInputChanged: null),
              _buildNumberInputField("Налог", _taxRateController,
                  unit: "%", onInputChanged: null),
            ],
          ),
        ),
      ));

      // Блок с детализацией расходов
      widgets.add(Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Детализация расходов',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // Себестоимость
              _ProductCostItemCard(
                title: 'Себестоимость',
                value:
                    '₽ ${model.productCostData!.costPrice.toStringAsFixed(2)}',
                details: model.costDetails['costPrice'],
                costType: 'costPrice',
                currentAmount: double.tryParse(_costController.text) ?? 0,
                onSyncPressed: _updateCostAmount,
                onAddDetail: model.saveDetailItem,
                onDeleteDetail: model.deleteDetailItem,
              ),

              // Доставка
              _ProductCostItemCard(
                title: 'Доставка',
                value:
                    '₽ ${model.productCostData!.delivery.toStringAsFixed(2)}',
                details: model.costDetails['delivery'],
                costType: 'delivery',
                currentAmount: double.tryParse(_deliveryController.text) ?? 0,
                onSyncPressed: _updateCostAmount,
                onAddDetail: model.saveDetailItem,
                onDeleteDetail: model.deleteDetailItem,
              ),

              // Упаковка
              _ProductCostItemCard(
                title: 'Упаковка',
                value:
                    '₽ ${model.productCostData!.packaging.toStringAsFixed(2)}',
                details: model.costDetails['packaging'],
                costType: 'packaging',
                currentAmount: double.tryParse(_packageController.text) ?? 0,
                onSyncPressed: _updateCostAmount,
                onAddDetail: model.saveDetailItem,
                onDeleteDetail: model.deleteDetailItem,
              ),

              // Платный прием
              _ProductCostItemCard(
                title: 'Платный приём',
                value:
                    '₽ ${model.productCostData!.paidAcceptance.toStringAsFixed(2)}',
                details: model.costDetails['paidAcceptance'],
                costType: 'paidAcceptance',
                currentAmount:
                    double.tryParse(_paidAcceptanceController.text) ?? 0,
                onSyncPressed: _updateCostAmount,
                onAddDetail: model.saveDetailItem,
                onDeleteDetail: model.deleteDetailItem,
              ),
            ],
          ),
        ),
      ));

      // Блок с расчетом рентабельности
      final costData = model.productCostData!;
      widgets.add(_buildCostCalculationSection(
        costData: costData,
        tariff: model.wbTariff,
        boxTariff: boxTariff,
        palletTariff: palletTariff,
        volume: model.volumeLiters,
        nmID: productCard.nmID,
        length: productCard.length,
        width: productCard.width,
        height: productCard.height,
      ));

      // Блок с расчетом рентабельности при разных наценках
      widgets.add(_buildProfitabilitySection(
        costData: costData,
        tariff: model.wbTariff,
        boxTariff: boxTariff,
        palletTariff: palletTariff,
        volume: model.volumeLiters,
        nmID: productCard.nmID,
        length: productCard.length,
        width: productCard.width,
        height: productCard.height,
      ));
    } else {
      widgets.add(const Center(
        child: Text('Загрузка данных о тарифах...'),
      ));
    }

    return Column(children: widgets);
  }

  Widget _buildWarehouseSection(
      ProductCardViewModel model, List<String> warehouses) {
    final bool isBox = model.productCostData?.isBox ?? true;
    final bool tariffNotFound = isBox
        ? !model.boxTariffs
            .any((tariff) => tariff.warehouseName == model.selectedWarehouse)
        : !model.palletTariffs
            .any((tariff) => tariff.warehouseName == model.selectedWarehouse);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle("Склад"),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: model.selectedWarehouse,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: warehouses.map((String warehouse) {
                  return DropdownMenuItem<String>(
                    value: warehouse,
                    child: Text(warehouse),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    model.setSelectedWarehouse(newValue);
                  }
                },
              ),
              if (tariffNotFound) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "Внимание! Для выбранного склада отсутствуют тарифы для ${isBox ? "коробов" : "паллет"}. Логистика рассчитана неверно.",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryTypeSection(ProductCardViewModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle("Тип поставки"),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Короб",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Switch(
                value: !(model.productCostData?.isBox ?? true),
                onChanged: (bool value) {
                  model.updateProductCostData(isBox: !value);
                },
              ),
              const Text("Паллета",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(
      ProductCard productCard, double volumeLiters, double goodPrice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content:
                      Image.network(productCard.photoUrl, fit: BoxFit.contain),
                );
              },
            );
          },
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.network(
                productCard.photoUrl,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
                key: ValueKey(productCard.nmID),
                cacheWidth: 200,
                cacheHeight: 200,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoRow("Цена WB", goodPrice.toStringAsFixed(2)),
        _buildInfoRow("nmID", productCard.nmID.toString()),
        _buildInfoRow("Название", productCard.subjectName),
        _buildInfoRow("Код продавца", productCard.vendorCode),
        _buildInfoRow("Объем (л)", volumeLiters.toStringAsFixed(2)),
      ],
    );
  }

  Widget _buildCostCalculationSection({
    required ProductCostData costData,
    required WbTariff? tariff,
    required WbBoxTariff? boxTariff,
    required WbPalletTariff? palletTariff,
    required double volume,
    required int nmID,
    required int length,
    required int width,
    required int height,
  }) {
    // Вычисляем необходимые значения на основе параметров
    double logistics = 0.0;
    if (boxTariff != null) {
      logistics = volume < 1
          ? boxTariff.boxDeliveryBase
          : (volume - 1) * boxTariff.boxDeliveryLiter +
              boxTariff.boxDeliveryBase;
    }

    double commissionPercent = (tariff?.kgvpMarketplace.ceil() ?? 0).toDouble();
    double price = double.tryParse(_costController.text) ?? 0.0;
    double commissionAmount = price * (commissionPercent / 100);
    double totalReturnCost =
        _calculateReturnCost(logistics, costData.returnRate);
    double taxCost = price * (costData.taxRate / 100);

    double totalCosts = costData.costPrice +
        costData.delivery +
        costData.packaging +
        costData.paidAcceptance +
        totalReturnCost +
        logistics +
        commissionAmount +
        taxCost;

    double netProfit = price - totalCosts;
    double breakEvenPrice = totalCosts / 0.85; // Примерный расчет

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle("Расчёт затрат"),
        CalculationRow(
            "Затраты на возвраты:", "${totalReturnCost.toStringAsFixed(2)} ₽"),
        CalculationRow("Логистика:", "${logistics.toStringAsFixed(2)} ₽"),
        CalculationRow(
            "Комиссия WB (${commissionPercent.toStringAsFixed(1)}%):",
            "${commissionAmount.toStringAsFixed(2)} ₽"),
        CalculationRow("Налог (${costData.taxRate}% от цены):",
            "${taxCost.toStringAsFixed(2)} ₽"),
        CalculationRow("Все затраты (без учета рентабельности):",
            "${totalCosts.toStringAsFixed(2)} ₽"),
        const Divider(),
        CalculationRow("Цена:", "${price.toStringAsFixed(2)} ₽", isBold: true),
        CalculationRow("Чистая прибыль:", "${netProfit.toStringAsFixed(2)} ₽",
            isBold: true),
        CalculationRow(
            "Точка безубыточности:", "${breakEvenPrice.toStringAsFixed(2)} ₽",
            isBold: true),
      ],
    );
  }

  Widget _buildProfitabilitySection({
    required ProductCostData costData,
    required WbTariff? tariff,
    required WbBoxTariff? boxTariff,
    required WbPalletTariff? palletTariff,
    required double volume,
    required int nmID,
    required int length,
    required int width,
    required int height,
  }) {
    double margin1 = double.tryParse(_desiredMarginController1.text) ?? 30;
    double margin2 = double.tryParse(_desiredMarginController2.text) ?? 35;
    double margin3 = double.tryParse(_desiredMarginController3.text) ?? 40;

    // Вычисляем необходимые значения
    double logistics = 0.0;
    if (boxTariff != null) {
      logistics = volume < 1
          ? boxTariff.boxDeliveryBase
          : (volume - 1) * boxTariff.boxDeliveryLiter +
              boxTariff.boxDeliveryBase;
    }

    _calculateReturnCost(logistics, costData.returnRate);
    (tariff?.kgvpMarketplace.ceil() ?? 0).toDouble();

    // Отображаем все варианты
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle("Варианты рентабельности"),
        const SizedBox(height: 10),
        _buildMarginCard("Вариант 1", _desiredMarginController1, margin1, 1),
        const SizedBox(height: 10),
        _buildMarginCard("Вариант 2", _desiredMarginController2, margin2, 2),
        const SizedBox(height: 10),
        _buildMarginCard("Вариант 3", _desiredMarginController3, margin3, 3),
      ],
    );
  }

  /// Карточка варианта с возможностью клика и регулировки (+/-)
  Widget _buildMarginCard(String title, TextEditingController controller,
      double margin, int variantIndex) {
    bool isSelected = (_selectedVariant == variantIndex);
    return InkWell(
      onTap: () {
        setState(() {
          _selectedVariant = variantIndex;
        });
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: isSelected
              ? const BorderSide(color: Colors.blue, width: 2)
              : BorderSide.none,
        ),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text("Желаемая рентабельность:"),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      _updateMargin(controller, margin, -1);
                    },
                  ),
                  SizedBox(
                    width: 50,
                    child: TextField(
                      controller: controller,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(border: OutlineInputBorder()),
                      onChanged: (_) {
                        setState(() {});
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      _updateMargin(controller, margin, 1);
                    },
                  ),
                  const Text("%"),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      _uploadPrices(controller);
                    },
                    child: const Text("Установить"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateMargin(
      TextEditingController controller, double margin, int change) {
    double current = double.tryParse(controller.text) ?? margin;
    current = (current + change).clamp(0, 100);
    controller.text = current.toStringAsFixed(0);
    setState(() {});
  }

  void _uploadPrices(TextEditingController controller) {
    final model = context.read<ProductCardViewModel>();
    final selectedMargin = double.tryParse(controller.text) ?? 30;
    final selectedResults = _calculateForMargin(
      selectedMargin,
      double.tryParse(_costController.text) ?? 0,
      double.tryParse(_deliveryController.text) ?? 0,
      double.tryParse(_packageController.text) ?? 0,
      double.tryParse(_paidAcceptanceController.text) ?? 0,
      _calculateReturnCost(
        _calculateLogistics(
          model.boxTariffs.firstWhere(
            (tariff) => tariff.warehouseName == _selectedWarehouse,
            orElse: () => WbBoxTariff(
              warehouseName: "Маркетплейс",
              boxDeliveryAndStorageExpr: 0.0,
              boxDeliveryBase: 0.0,
              boxDeliveryLiter: 0.0,
              boxStorageBase: 0.0,
              boxStorageLiter: 0.0,
              warehouseID: '',
            ),
          ),
          model.volumeLiters,
        ),
        double.tryParse(_returnRateController.text) ?? 10.0,
      ),
      _calculateLogistics(
        model.boxTariffs.firstWhere(
          (tariff) => tariff.warehouseName == _selectedWarehouse,
          orElse: () => WbBoxTariff(
            warehouseName: "Маркетплейс",
            boxDeliveryAndStorageExpr: 0.0,
            boxDeliveryBase: 0.0,
            boxDeliveryLiter: 0.0,
            boxStorageBase: 0.0,
            boxStorageLiter: 0.0,
            warehouseID: '',
          ),
        ),
        model.volumeLiters,
      ),
      double.tryParse(_storageController.text) ?? 0,
      model.wbTariff?.kgvpMarketplace.toDouble() ?? 0,
      int.tryParse(_taxRateController.text) ?? 7,
    );

    final price = selectedResults["finalPrice"]!;

    final newPrice = price * 1.05;
    final newDiscount = 5;

    model.uploadProductPrices([
      {
        "nmID": model.nmID,
        "price": newPrice.round(),
        "discount": newDiscount,
      }
    ]);
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('"$value" скопировано в буфер обмена')),
              );
            },
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberInputField(String label, TextEditingController controller,
      {String unit = "", Function(String)? onInputChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 1,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                suffixText: unit,
                border: const OutlineInputBorder(),
                hintText: "0",
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: onInputChanged,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateLogistics(WbBoxTariff tariff, double volume) {
    return volume < 1
        ? tariff.boxDeliveryBase
        : (volume - 1) * tariff.boxDeliveryLiter + tariff.boxDeliveryBase;
  }

  double _calculateReturnCost(double logistics, double? returnRate) {
    if (returnRate == null || returnRate >= 100) return 0;
    const double returnLogisticsCost = 50.0;
    return (logistics + returnLogisticsCost) *
        (returnRate / (100 - returnRate));
  }

  // Здесь налог считается как 0.07% (0.07)
  Map<String, double> _calculateForMargin(
    double desiredMargin,
    double costPrice,
    double delivery,
    double packaging,
    double paidAcceptance,
    double totalReturnCost,
    double logistics,
    double storage,
    double commissionPercent,
    int taxRate,
  ) {
    double finalPrice = 100.0;
    double oldPrice = 0.0;
    int iterationCount = 0;
    const int maxIterations = 20;
    const double epsilon = 0.01;
    while ((finalPrice - oldPrice).abs() > epsilon &&
        iterationCount < maxIterations) {
      iterationCount++;
      oldPrice = finalPrice;
      final double wbCommission = finalPrice * (commissionPercent / 100);
      final double taxCost = finalPrice * taxRate / 100;
      final double totalCosts = costPrice +
          delivery +
          packaging +
          paidAcceptance +
          totalReturnCost +
          logistics +
          storage +
          wbCommission +
          taxCost;
      final double marginRatio = desiredMargin / 100;
      finalPrice = totalCosts / (1 - marginRatio);
    }
    final double wbCommission = finalPrice * (commissionPercent / 100);
    final double taxCost = finalPrice * taxRate / 100;
    final double totalCosts = costPrice +
        delivery +
        packaging +
        paidAcceptance +
        totalReturnCost +
        logistics +
        storage +
        wbCommission +
        taxCost;
    final double netProfit = finalPrice - totalCosts;
    final double breakEvenPrice = (totalCosts - taxCost - wbCommission) /
        (1 - (commissionPercent / 100) - 0.07);
    return {
      "finalPrice": finalPrice,
      "netProfit": netProfit,
      "breakEvenPrice": breakEvenPrice,
    };
  }

  /// Обновление суммы расходов
  void _updateCostAmount(String costType, double amount) {
    final text = amount.toString();
    if (costType == 'costPrice') {
      _costController.text = text;
    } else if (costType == 'delivery') {
      _deliveryController.text = text;
    } else if (costType == 'packaging') {
      _packageController.text = text;
    } else if (costType == 'paidAcceptance') {
      _paidAcceptanceController.text = text;
    }
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}

class CalculationRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const CalculationRow(this.label, this.value,
      {super.key, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}

class _ProductCostItemCard extends StatefulWidget {
  final String title;
  final String value;
  final String costType;
  final List<ProductCostDataDetails>? details;
  final double currentAmount;
  final Function(String, String, double, {String? description}) onAddDetail;
  final Function(ProductCostDataDetails) onDeleteDetail;
  final Function(String, double) onSyncPressed;

  const _ProductCostItemCard({
    Key? key,
    required this.title,
    required this.value,
    required this.costType,
    required this.details,
    required this.currentAmount,
    required this.onAddDetail,
    required this.onDeleteDetail,
    required this.onSyncPressed,
  }) : super(key: key);

  @override
  State<_ProductCostItemCard> createState() => _ProductCostItemCardState();
}

class _ProductCostItemCardState extends State<_ProductCostItemCard> {
  double _detailsSum = 0;
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _amountController = TextEditingController();
    _descriptionController = TextEditingController();
    _calculateDetailsSum();
  }

  @override
  void didUpdateWidget(_ProductCostItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.details != widget.details) {
      _calculateDetailsSum();
    }
  }

  void _calculateDetailsSum() {
    setState(() {
      _detailsSum = widget.details
              ?.fold<double>(0, (sum, detail) => sum + detail.amount) ??
          0;
    });
  }

  bool get _hasDifference => widget.currentAmount != _detailsSum;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    if (_hasDifference)
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                      ),
                    Text(
                      widget.value,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _hasDifference ? Colors.orange : Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (widget.details != null && widget.details!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Детали:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...widget.details!.map((detail) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                detail.name,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Text(
                              '${detail.amount.toStringAsFixed(2)} ₽',
                              style: const TextStyle(fontSize: 14),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20),
                              onPressed: () => widget.onDeleteDetail(detail),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Итого:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_detailsSum.toStringAsFixed(2)} ₽',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color:
                                _hasDifference ? Colors.orange : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Добавить деталь'),
                  onPressed: _showAddDetailDialog,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
                if (_hasDifference)
                  TextButton.icon(
                    icon: const Icon(Icons.sync, size: 18),
                    label: const Text('Применить'),
                    onPressed: () {
                      widget.onSyncPressed(widget.costType, _detailsSum);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDetailDialog() {
    _nameController.clear();
    _amountController.clear();
    _descriptionController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить деталь'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Название',
                hintText: 'Введите название детали расхода',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Сумма (₽)',
                hintText: 'Введите сумму',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Описание (опционально)',
                hintText: 'Введите описание',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              // Validate inputs
              final name = _nameController.text.trim();
              final amountText = _amountController.text.trim();

              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Введите название')),
                );
                return;
              }

              double? amount = double.tryParse(amountText);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Введите корректную сумму')),
                );
                return;
              }

              final description = _descriptionController.text.trim();

              Navigator.of(context).pop();
              widget.onAddDetail(
                widget.costType,
                name,
                amount,
                description: description.isNotEmpty ? description : null,
              );
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

// class _ProductCostsBlock extends StatelessWidget {
//   final ProductCostData costData;
//   final WbTariff? tariff;
//   final WbBoxTariff? boxTariff;
//   final WbPalletTariff? palletTariff;
//   final int length;
//   final int width;
//   final int height;
//   final double volume;
//   final Map<String, List<ProductCostDataDetails>> costDetails;
//   final Function(String costType, String name, double amount,
//       {String? description}) onAddDetail;
//   final Function(ProductCostDataDetails detail) onDeleteDetail;

//   const _ProductCostsBlock({
//     Key? key,
//     required this.costData,
//     required this.tariff,
//     required this.boxTariff,
//     required this.palletTariff,
//     required this.length,
//     required this.width,
//     required this.height,
//     required this.volume,
//     required this.costDetails,
//     required this.onAddDetail,
//     required this.onDeleteDetail,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ... (existing header)

//             // Себестоимость
//             _ProductCostItemCard(
//               title: 'Себестоимость',
//               value: '₽ ${costData.costPrice.toStringAsFixed(2)}',
//               details: costDetails['costPrice'],
//               costType: 'costPrice',
//               onAddDetail: onAddDetail,
//               onDeleteDetail: onDeleteDetail,
//             ),

//             // Доставка
//             _ProductCostItemCard(
//               title: 'Доставка',
//               value: '₽ ${costData.delivery.toStringAsFixed(2)}',
//               details: costDetails['delivery'],
//               costType: 'delivery',
//               onAddDetail: onAddDetail,
//               onDeleteDetail: onDeleteDetail,
//             ),

//             // Упаковка
//             _ProductCostItemCard(
//               title: 'Упаковка',
//               value: '₽ ${costData.packaging.toStringAsFixed(2)}',
//               details: costDetails['packaging'],
//               costType: 'packaging',
//               onAddDetail: onAddDetail,
//               onDeleteDetail: onDeleteDetail,
//             ),

//             // Платный прием
//             _ProductCostItemCard(
//               title: 'Платный прием',
//               value: '₽ ${costData.paidAcceptance.toStringAsFixed(2)}',
//               details: costDetails['paidAcceptance'],
//               costType: 'paidAcceptance',
//               onAddDetail: onAddDetail,
//               onDeleteDetail: onDeleteDetail,
//             ),

//             // ... (other costs that should not be expanded)
//           ],
//         ),
//       ),
//     );
//   }
// }
