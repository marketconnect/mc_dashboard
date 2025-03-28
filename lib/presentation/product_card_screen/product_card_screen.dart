import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mc_dashboard/core/utils/open_url.dart';

import 'package:mc_dashboard/domain/entities/product_card.dart';
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

  double _calculatePalletLogistics(WbPalletTariff tariff, double volume) {
    return volume < 1
        ? tariff.palletDeliveryValueBase
        : (volume - 1) * tariff.palletDeliveryValueLiter +
            tariff.palletDeliveryValueBase;
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
    if (model.productCard == null) {
      return const Center(child: Text("Карточка не найдена"));
    }
    final double goodPrice = model.goodPrice ?? 0;
    final ProductCard productCard = model.productCard!;
    final WbTariff? wbTariff = model.wbTariff;
    final List<WbBoxTariff> boxTariffs = model.boxTariffs;
    final List<WbPalletTariff> palletTariffs = model.palletTariffs;

    // Список складов
    List<String> warehouses = boxTariffs.map((e) => e.warehouseName).toList();
    for (var palletTariff in palletTariffs) {
      if (!warehouses.contains(palletTariff.warehouseName)) {
        warehouses.add(palletTariff.warehouseName);
      }
    }
    if (!warehouses.contains("Маркетплейс")) {
      warehouses.insert(0, "Маркетплейс");
    }

    final bool isBox = model.productCostData?.isBox ?? true;
    double logistics;
    if (isBox) {
      WbBoxTariff selectedBoxTariff = boxTariffs.firstWhere(
        (tariff) => tariff.warehouseName == model.selectedWarehouse,
        orElse: () => WbBoxTariff(
          warehouseName: "Маркетплейс",
          boxDeliveryAndStorageExpr: 0.0,
          boxDeliveryBase: 0.0,
          boxDeliveryLiter: 0.0,
          boxStorageBase: 0.0,
          boxStorageLiter: 0.0,
          warehouseID: '',
        ),
      );
      logistics = _calculateLogistics(selectedBoxTariff, model.volumeLiters);
    } else {
      WbPalletTariff selectedPalletTariff = model.palletTariffs.firstWhere(
        (tariff) => tariff.warehouseName == model.selectedWarehouse,
        orElse: () => WbPalletTariff(
          warehouseName: "Маркетплейс",
          palletDeliveryExpr: 0.0,
          palletDeliveryValueBase: 0.0,
          palletDeliveryValueLiter: 0.0,
          palletStorageExpr: 0.0,
          palletStorageValueExpr: 0.0,
        ),
      );
      logistics =
          _calculatePalletLogistics(selectedPalletTariff, model.volumeLiters);
    }

    final double costPrice = double.tryParse(_costController.text) ?? 0;
    final double delivery = double.tryParse(_deliveryController.text) ?? 0;
    final double packaging = double.tryParse(_packageController.text) ?? 0;
    final int taxRate = int.tryParse(_taxRateController.text) ?? 7;
    final double paidAcceptance =
        double.tryParse(_paidAcceptanceController.text) ?? 0;
    final double returnRate =
        double.tryParse(_returnRateController.text) ?? 10.0;
    final double storage = double.tryParse(_storageController.text) ?? 0;

    final double totalReturnCost = _calculateReturnCost(logistics, returnRate);
    final double commissionPercent =
        (wbTariff?.kgvpMarketplace.ceil() ?? 0).toDouble();

    double selectedMargin;
    if (_selectedVariant == 1) {
      selectedMargin = double.tryParse(_desiredMarginController1.text) ?? 30;
    } else if (_selectedVariant == 2) {
      selectedMargin = double.tryParse(_desiredMarginController2.text) ?? 35;
    } else {
      selectedMargin = double.tryParse(_desiredMarginController3.text) ?? 40;
    }

    final selectedResults = _calculateForMargin(
      selectedMargin,
      costPrice,
      delivery,
      packaging,
      paidAcceptance,
      totalReturnCost,
      logistics,
      storage,
      commissionPercent,
      taxRate,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Info Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection(productCard, model.volumeLiters, goodPrice),
                const Divider(height: 32),
                _buildWarehouseSection(model, warehouses),
                const Divider(height: 32),
                _buildDeliveryTypeSection(model),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Costs Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle("Расходы"),
                _buildNumberInputField("Себестоимость", _costController,
                    suffix: "₽"),
                _buildNumberInputField("Доставка", _deliveryController,
                    suffix: "₽"),
                _buildNumberInputField("Упаковка", _packageController,
                    suffix: "₽"),
                _buildNumberInputField(
                    "Платная приемка", _paidAcceptanceController,
                    suffix: "₽"),
                _buildNumberInputField("Возвраты", _returnRateController,
                    suffix: "%"),
                _buildNumberInputField("Хранение", _storageController,
                    suffix: "₽"),
                _buildNumberInputField("Налог", _taxRateController,
                    suffix: "%"),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Cost Calculation Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCostCalculationSection(
                  selectedResults["finalPrice"]!,
                  selectedResults["netProfit"]!,
                  selectedResults["breakEvenPrice"]!,
                  totalReturnCost,
                  logistics,
                  commissionPercent,
                  selectedResults["finalPrice"]! * (commissionPercent / 100),
                  selectedResults["finalPrice"]! * (taxRate / 100),
                  costPrice +
                      delivery +
                      packaging +
                      paidAcceptance +
                      totalReturnCost +
                      logistics +
                      storage +
                      selectedResults["finalPrice"]! *
                          (commissionPercent / 100) +
                      selectedResults["finalPrice"]! * (taxRate / 100),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Profitability Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfitabilitySection(
                  costPrice: costPrice,
                  delivery: delivery,
                  packaging: packaging,
                  paidAcceptance: paidAcceptance,
                  totalReturnCost: totalReturnCost,
                  logistics: logistics,
                  storage: storage,
                  commissionPercent: commissionPercent,
                ),
              ],
            ),
          ),
        ),
      ],
    );
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

  Widget _buildCostCalculationSection(
    double finalPrice,
    double netProfit,
    double breakEvenPrice,
    double totalReturnCost,
    double logistics,
    double commissionPercent,
    double commissionAmount,
    double taxCost,
    double totalCosts,
  ) {
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
        CalculationRow("Налог (${_taxRateController.text}% от цены):",
            "${taxCost.toStringAsFixed(2)} ₽"),
        CalculationRow("Все затраты (без учета рентабельности):",
            "${totalCosts.toStringAsFixed(2)} ₽"),
        const Divider(),
        CalculationRow("Цена:", "${finalPrice.toStringAsFixed(2)} ₽",
            isBold: true),
        CalculationRow("Чистая прибыль:", "${netProfit.toStringAsFixed(2)} ₽",
            isBold: true),
        CalculationRow(
            "Точка безубыточности:", "${breakEvenPrice.toStringAsFixed(2)} ₽",
            isBold: true),
      ],
    );
  }

  Widget _buildProfitabilitySection({
    required double costPrice,
    required double delivery,
    required double packaging,
    required double paidAcceptance,
    required double totalReturnCost,
    required double logistics,
    required double storage,
    required double commissionPercent,
  }) {
    double margin1 = double.tryParse(_desiredMarginController1.text) ?? 30;
    double margin2 = double.tryParse(_desiredMarginController2.text) ?? 35;
    double margin3 = double.tryParse(_desiredMarginController3.text) ?? 40;

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
      {String suffix = ""}) {
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
                suffixText: suffix,
                border: const OutlineInputBorder(),
                hintText: "0",
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
