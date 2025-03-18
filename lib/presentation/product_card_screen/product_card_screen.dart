import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mc_dashboard/domain/entities/product_card.dart';
import 'package:mc_dashboard/domain/entities/wb_box_tariff.dart';
import 'package:mc_dashboard/domain/entities/wb_pallet_tariff.dart';
import 'package:mc_dashboard/domain/entities/wb_tariff.dart';
import 'package:mc_dashboard/presentation/product_card_screen/product_card_view_model.dart';
import 'package:mc_dashboard/presentation/widgets/progress_bar.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

class ProductCardScreen extends StatefulWidget {
  const ProductCardScreen({Key? key}) : super(key: key);

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
    final nmID = productCard?.nmID;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            productCard?.title != null ? "${productCard?.title}" : "$nmID"),
        leading: IconButton(
          // Добавлена кнопка "Назад"
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: model.isLoading
          ? Center(child: McProgressBar())
          : model.errorMessage != null
              ? Center(
                  child: Text(
                    model.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : _buildProductCardDetails(model),
    );
  }

  Widget _buildProductCardDetails(ProductCardViewModel model) {
    if (model.productCard == null) {
      return const Center(child: Text("Карточка не найдена"));
    }
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
      );
      logistics = _calculateLogistics(selectedBoxTariff, model.volumeLiters);
    } else {
      WbPalletTariff selectedPalletTariff = model.palletTariffs.firstWhere(
        (tariff) => tariff.warehouseName == _selectedWarehouse,
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

    // Считываем введённые данные
    final double costPrice = double.tryParse(_costController.text) ?? 0;
    final double delivery = double.tryParse(_deliveryController.text) ?? 0;
    final double packaging = double.tryParse(_packageController.text) ?? 0;
    final int taxRate = int.tryParse(_taxRateController.text) ?? 7;
    final double paidAcceptance =
        double.tryParse(_paidAcceptanceController.text) ?? 0;
    final double returnRate =
        double.tryParse(_returnRateController.text) ?? 10.0;
    final double storage = double.tryParse(_storageController.text) ?? 0;

    // Расчёт логистики и затрат на возвраты
    // final double logistics =
    //     _calculateLogistics(selectedBoxTariff, model.volumeLiters);
    final double totalReturnCost = _calculateReturnCost(logistics, returnRate);
    final double commissionPercent =
        (wbTariff?.kgvpMarketplace.ceil() ?? 0).toDouble();

    // Определяем выбранную желаемую рентабельность по варианту
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
    final double finalPriceSelected = selectedResults["finalPrice"]!;
    final double netProfitSelected = selectedResults["netProfit"]!;
    final double breakEvenPriceSelected = selectedResults["breakEvenPrice"]!;

    return _buildResponsiveLayout(
      model: model,
      productCard: productCard,
      warehouses: warehouses,
      costPrice: costPrice,
      delivery: delivery,
      packaging: packaging,
      paidAcceptance: paidAcceptance,
      returnRate: returnRate,
      storage: storage,
      logistics: logistics,
      totalReturnCost: totalReturnCost,
      commissionPercent: commissionPercent,
      finalPrice: finalPriceSelected,
      netProfit: netProfitSelected,
      breakEvenPrice: breakEvenPriceSelected,
    );
  }

  // Обновлённый вызов функции _buildCostCalculationSection в адаптивном макете:
  Widget _buildResponsiveLayout({
    required ProductCardViewModel model,
    required ProductCard productCard,
    required List<String> warehouses,
    required double costPrice,
    required double delivery,
    required double packaging,
    required double paidAcceptance,
    required double returnRate,
    required double storage,
    required double logistics,
    required double totalReturnCost,
    required double commissionPercent,
    required double finalPrice,
    required double netProfit,
    required double breakEvenPrice,
  }) {
    // Читаем ставку налога из контроллера
    double taxRate = double.tryParse(_taxRateController.text) ?? 7.0;

    // Пересчитываем налог
    double taxCost = finalPrice * (taxRate / 100);

    // Все затраты (доп. затраты + логистика + комиссия + налог)
    double totalCosts = costPrice +
        delivery +
        packaging +
        paidAcceptance +
        totalReturnCost +
        logistics;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    // Added SingleChildScrollView
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoSection(productCard, model.volumeLiters),
                        const SizedBox(height: 16),
                        _buildCostsSection(warehouses),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SingleChildScrollView(
                    // Added SingleChildScrollView
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCostCalculationSection(
                          finalPrice,
                          netProfit,
                          breakEvenPrice,
                          totalReturnCost,
                          logistics,
                          finalPrice * (commissionPercent / 100),
                          taxCost, // Теперь налог динамический
                          totalCosts +
                              finalPrice * (commissionPercent / 100) +
                              taxCost,
                        ),
                        const SizedBox(height: 16),
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
            ),
          );
        } else {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection(productCard, model.volumeLiters),
                const SizedBox(height: 16),
                _buildCostsSection(warehouses),
                const SizedBox(height: 16),
                _buildCostCalculationSection(
                  finalPrice,
                  netProfit,
                  breakEvenPrice,
                  totalReturnCost,
                  logistics,
                  finalPrice * (commissionPercent / 100),
                  taxCost, // Теперь налог динамический
                  totalCosts + finalPrice * (commissionPercent / 100) + taxCost,
                ),
                const SizedBox(height: 16),
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
          );
        }
      },
    );
  }

  /// Секция "Фото и общая информация"
  Widget _buildInfoSection(ProductCard productCard, double volumeLiters) {
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
        _buildInfoRow("nmID", productCard.nmID.toString()),
        _buildInfoRow("Название", productCard.subjectName),
        _buildInfoRow("Код продавца", productCard.vendorCode),
        _buildInfoRow("Объем (л)", volumeLiters.toStringAsFixed(2)),
      ],
    );
  }

// В методе _buildCostsSection, например:
  Widget _buildCostsSection(List<String> warehouses) {
    final model = context.watch<ProductCardViewModel>();
    final bool isBox = model.productCostData?.isBox ?? true;
    final sel;
    // Проверяем наличие тарифов для выбранного склада
    final bool tariffNotFound = isBox
        ? !model.boxTariffs
            .any((tariff) => tariff.warehouseName == _selectedWarehouse)
        : !model.palletTariffs
            .any((tariff) => tariff.warehouseName == _selectedWarehouse);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNumberInputField("Себестоимость", _costController, suffix: "₽"),
        _buildNumberInputField("Доставка", _deliveryController, suffix: "₽"),
        _buildNumberInputField("Упаковка", _packageController, suffix: "₽"),
        _buildNumberInputField("Платная приемка", _paidAcceptanceController,
            suffix: "₽"),
        _buildNumberInputField("Возвраты", _returnRateController, suffix: "%"),
        _buildNumberInputField("Хранение", _storageController, suffix: "₽"),
        _buildNumberInputField("Налог", _taxRateController, suffix: "%"),
        const SizedBox(height: 10),
        SectionTitle("Выбор склада"),
        _buildWarehouseDropdown(warehouses),
        const SizedBox(height: 10),
        if (tariffNotFound)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              "Внимание! Для выбранного склада отсутствуют тарифы для ${isBox ? "коробов" : "паллет"}. Логистика рассчитана неверно.",
              style: TextStyle(color: Colors.white),
            ),
          ),
        const SizedBox(height: 10),
        SectionTitle("Тип поставки"),
        Row(
          children: [
            ToggleSwitch(
              minWidth: 80.0,
              cornerRadius: 10.0,
              activeBgColors: [
                [Theme.of(context).colorScheme.onPrimary],
                [Theme.of(context).colorScheme.onPrimary],
              ],
              initialLabelIndex: isBox ? 0 : 1,
              activeFgColor: Colors.white,
              inactiveBgColor: Theme.of(context).colorScheme.secondaryContainer,
              inactiveFgColor: Colors.white,
              totalSwitches: 2,
              labels: ['Короб', 'Паллета'],
              fontSize: 14,
              onToggle: (index) {
                final model = context.read<ProductCardViewModel>();
                model.updateProductCostData(isBox: index == 0);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCostCalculationSection(
    double finalPrice,
    double netProfit,
    double breakEvenPrice,
    double totalReturnCost,
    double logistics,
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
            "Комиссия WB:", "${commissionAmount.toStringAsFixed(2)} ₽"),
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

  Widget _buildWarehouseDropdown(List<String> warehouses) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Склад",
      ),
      value: _selectedWarehouse,
      isExpanded: true,
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedWarehouse = newValue;
          });
          final model = context.read<ProductCardViewModel>();
          model.updateProductCostData(warehouseName: newValue);
        }
      },
      items: warehouses.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
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

  const SectionTitle(this.title, {Key? key}) : super(key: key);

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

  const CalculationRow(this.label, this.value, {Key? key, this.isBold = false})
      : super(key: key);

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
