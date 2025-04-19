import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:mc_dashboard/core/utils/open_url.dart';

import 'package:mc_dashboard/domain/entities/ozon_product.dart';
import 'package:mc_dashboard/domain/entities/ozon_product_info.dart';
import 'package:mc_dashboard/domain/entities/product_cost_data_details.dart';

import 'package:mc_dashboard/presentation/ozon_product_card_screen/ozon_product_card_view_model.dart';
import 'package:mc_dashboard/presentation/widgets/progress_bar.dart';
import 'package:provider/provider.dart';

// TODO Add current quantity and Inventory Threshold (quantity that triggers the notification (some kind of alarm -> AGENT ))
class OzonProductCardScreen extends StatefulWidget {
  const OzonProductCardScreen({super.key});

  @override
  State<OzonProductCardScreen> createState() => _OzonProductCardScreenState();
}

class _OzonProductCardScreenState extends State<OzonProductCardScreen> {
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

  int _selectedVariant = 1;

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
    final model = context.read<OzonProductCardViewModel>();
    _updateProductCostData(model);
    if (model.productCostData != null) {
      model.saveProductCost(model.productCostData!);
    }
  }

  void _onMarginChanged() {
    final model = context.read<OzonProductCardViewModel>();
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
    final model = context.read<OzonProductCardViewModel>();
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
    });
  }

  void _safeFillController(TextEditingController controller, String text) {
    if (controller.text.isEmpty) {
      controller.text = text;
    }
  }

  void _updateProductCostData(OzonProductCardViewModel model) {
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
    final model = context.watch<OzonProductCardViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(model.productInfo?.offerId ?? ""),
            Text(
              'Ozon',
              style: TextStyle(
                color: Color(0xFF005bff),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
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
        backgroundColor: Color(0xFF005bff),
        foregroundColor: Theme.of(context).colorScheme.surface,
        visible: true,
        curve: Curves.bounceIn,
        children: [
          SpeedDialChild(
            label: 'Товары',
            labelStyle: const TextStyle(fontSize: 16.0),
            onTap: () => openUrl(
                'https://seller.ozon.ru/app/products?search=${model.sku}'),
          ),
          SpeedDialChild(
            label: 'Цены',
            labelStyle: const TextStyle(fontSize: 16.0),
            onTap: () => openUrl(
                'https://seller.ozon.ru/app/prices/control?search=${model.sku}'),
          ),
          SpeedDialChild(
            label: 'Карточка',
            labelStyle: const TextStyle(fontSize: 16.0),
            onTap: () {
              openUrl('https://ozon.ru/product/${model.sku}');
            },
          ),
        ],
        // onOpen: () => debugPrint('OPENING DIAL'),
        // onClose: () => debugPrint('DIAL CLOSED'),
      ),
      body: model.isLoading
          ? const Center(child: McProgressBar())
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

  Widget _buildProductCardDetails(OzonProductCardViewModel model) {
    if (model.product == null) {
      return const Center(child: Text("Карточка не найдена"));
    }
    final OzonProduct productCard = model.product!;

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

    final commissionValues = model.getCurrentCommissionValues();
    final double totalReturnCost = commissionValues["returnCost"] ?? 0;
    final double commissionPercent = commissionValues["commissionPercent"] ?? 0;
    final double logistics = commissionValues["deliveryCost"] ?? 0;

    double selectedMargin;
    if (_selectedVariant == 1) {
      selectedMargin = double.tryParse(_desiredMarginController1.text) ?? 30;
    } else if (_selectedVariant == 2) {
      selectedMargin = double.tryParse(_desiredMarginController2.text) ?? 35;
    } else {
      selectedMargin = double.tryParse(_desiredMarginController3.text) ?? 40;
    }

    final selectedResults = model.calculateForMargin(
      desiredMargin: selectedMargin,
      costPrice: costPrice,
      delivery: delivery,
      packaging: packaging,
      paidAcceptance: paidAcceptance,
      totalReturnCost: totalReturnCost,
      logistics: logistics,
      storage: storage,
      commissionPercent: commissionPercent,
      taxRate: taxRate,
    );

    return _buildResponsiveLayout(
      model: model,
      productCard: productCard,
      costPrice: costPrice,
      delivery: delivery,
      packaging: packaging,
      paidAcceptance: paidAcceptance,
      returnRate: returnRate,
      storage: storage,
      totalReturnCost: totalReturnCost,
      commissionPercent: commissionPercent,
      finalPrice: selectedResults["finalPrice"]!,
      netProfit: selectedResults["netProfit"]!,
      breakEvenPrice: selectedResults["breakEvenPrice"]!,
      warehouses: [],
      logistics: logistics,
    );
  }

  Widget _buildResponsiveLayout({
    required OzonProductCardViewModel model,
    required OzonProduct productCard,
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
    final commissionValues = model.getCurrentCommissionValues();
    final double currentCommissionPercent =
        commissionValues["commissionPercent"] ?? 0;
    final double commissionAmount =
        finalPrice * (currentCommissionPercent / 100);
    final double taxRate = double.tryParse(_taxRateController.text) ?? 7.0;
    final double taxCost = finalPrice * (taxRate / 100);
    final double totalCosts = costPrice +
        delivery +
        packaging +
        paidAcceptance +
        totalReturnCost +
        logistics;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
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
                      _buildInfoSection(
                        productCard: model.productInfo!,
                        price:
                            model.price != null ? model.price!.price.price : 0,
                        productId: model.productId,
                        sku: model.sku,
                      ),
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

              // Добавляем новую карточку с детализацией расходов
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
                      SectionTitle("Детализация расходов"),
                      const SizedBox(height: 8),

                      // Себестоимость
                      _ProductCostItemCard(
                        title: 'Себестоимость',
                        value: '₽ ${costPrice.toStringAsFixed(2)}',
                        details: model.costDetails['costPrice'],
                        costType: 'costPrice',
                        currentAmount: costPrice,
                        onSyncPressed: _updateCostAmount,
                        onAddDetail: model.saveDetailItem,
                        onDeleteDetail: model.deleteDetailItem,
                      ),

                      // Доставка
                      _ProductCostItemCard(
                        title: 'Доставка',
                        value: '₽ ${delivery.toStringAsFixed(2)}',
                        details: model.costDetails['delivery'],
                        costType: 'delivery',
                        currentAmount: delivery,
                        onSyncPressed: _updateCostAmount,
                        onAddDetail: model.saveDetailItem,
                        onDeleteDetail: model.deleteDetailItem,
                      ),

                      // Упаковка
                      _ProductCostItemCard(
                        title: 'Упаковка',
                        value: '₽ ${packaging.toStringAsFixed(2)}',
                        details: model.costDetails['packaging'],
                        costType: 'packaging',
                        currentAmount: packaging,
                        onSyncPressed: _updateCostAmount,
                        onAddDetail: model.saveDetailItem,
                        onDeleteDetail: model.deleteDetailItem,
                      ),

                      // Платный прием
                      _ProductCostItemCard(
                        title: 'Платная приемка',
                        value: '₽ ${paidAcceptance.toStringAsFixed(2)}',
                        details: model.costDetails['paidAcceptance'],
                        costType: 'paidAcceptance',
                        currentAmount: paidAcceptance,
                        onSyncPressed: _updateCostAmount,
                        onAddDetail: model.saveDetailItem,
                        onDeleteDetail: model.deleteDetailItem,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Commissions Card
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
                      SectionTitle("Комиссии и логистика"),
                      _buildCommissionSection(model),
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
                        finalPrice,
                        netProfit,
                        breakEvenPrice,
                        totalReturnCost,
                        logistics,
                        commissionAmount,
                        taxCost,
                        totalCosts + commissionAmount + taxCost,
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
                        commissionPercent: currentCommissionPercent,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryTypeSection(OzonProductCardViewModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle("Тип доставки"),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("FBS",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Switch(
                value: model.isFBO,
                onChanged: (bool value) {
                  model.setDeliveryType(value);
                },
              ),
              const Text("FBO",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommissionSection(OzonProductCardViewModel model) {
    final price = model.price;
    if (price == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (model.isFBO) ...[
          _buildCommissionRow("Последняя миля (FBO):",
              price.commissions.fboDelivToCustomerAmount),
          _buildCommissionRow("Магистраль до (FBO):",
              price.commissions.fboDirectFlowTransMaxAmount),
          _buildCommissionRow("Магистраль от (FBO):",
              price.commissions.fboDirectFlowTransMinAmount),
          _buildCommissionRow("Комиссия за возврат и отмену (FBO):",
              price.commissions.fboReturnFlowAmount),
          _buildCommissionRow("Процент комиссии за продажу (FBO):",
              price.commissions.salesPercentFbo,
              isPercent: true),
        ] else ...[
          _buildCommissionRow("Последняя миля (FBS):",
              price.commissions.fbsDelivToCustomerAmount),
          _buildCommissionRow("Магистраль до (FBS):",
              price.commissions.fbsDirectFlowTransMaxAmount),
          _buildCommissionRow("Магистраль от (FBS):",
              price.commissions.fbsDirectFlowTransMinAmount),
          _buildCommissionRow(
              "Максимальная комиссия за обработку отправления (FBS):",
              price.commissions.fbsFirstMileMaxAmount),
          _buildCommissionRow(
              "Минимальная комиссия за обработку отправления (FBS):",
              price.commissions.fbsFirstMileMinAmount),
          _buildCommissionRow(
              "Комиссия за возврат и отмену, обработка отправления (FBS):",
              price.commissions.fbsReturnFlowAmount),
          _buildCommissionRow("Процент комиссии за продажу (FBS):",
              price.commissions.salesPercentFbs,
              isPercent: true),
        ],
      ],
    );
  }

  Widget _buildCommissionRow(String label, double? value,
      {bool isPercent = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Text(label),
          ),
          Expanded(
            flex: 2,
            child: Text(
              isPercent
                  ? "${value?.toStringAsFixed(2)}%"
                  : "${value?.toStringAsFixed(2)} ₽",
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required OzonProductInfo productCard,
    required double price,
    required int productId,
    required int sku,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content:
                        Image.network(productCard.image, fit: BoxFit.contain),
                  );
                },
              );
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(51),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Image.network(
                productCard.image,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
                key: ValueKey(productCard.productId),
                cacheWidth: 200,
                cacheHeight: 200,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoRow("Цена", price.toString()),
        _buildInfoRow("SKU", sku.toString()),
        _buildInfoRow("productID", productId.toString()),
        _buildInfoRow("Код продавца", productCard.offerId),
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
    final model = context.watch<OzonProductCardViewModel>();
    final commissionValues = model.getCurrentCommissionValues();
    final String deliveryType = model.isFBO ? "FBO" : "FBS";
    final double commissionPercent = commissionValues["commissionPercent"] ?? 0;
    final double returnCost = model.isFBO
        ? model.calculateFboReturnCost()
        : model.calculateFbsReturnCost();
    final double deliveryCost = commissionValues["deliveryCost"] ?? 0;

    final double totalOzonFees =
        model.calculateTotalOzonFees(commissionAmount, deliveryCost);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle("Расчёт затрат ($deliveryType)"),
        _buildCalculationRow("Затраты на возвраты:", returnCost),
        _buildCalculationRow("Логистика:", deliveryCost),
        _buildCalculationRow(
            "Комиссия Ozon ($commissionPercent%):", commissionAmount),
        _buildCalculationRow(
            "Налог (${_taxRateController.text}% от цены):", taxCost),
        _buildCalculationRow("Все сборы Ozon:", totalOzonFees),
        _buildCalculationRow(
            "Все затраты (без учета рентабельности):", totalCosts),
        const Divider(height: 32),
        _buildCalculationRow("Цена:", finalPrice, isBold: true),
        _buildCalculationRow("Чистая прибыль:", netProfit, isBold: true),
        _buildCalculationRow("Точка безубыточности:", breakEvenPrice,
            isBold: true),
      ],
    );
  }

  Widget _buildCalculationRow(String label, double value,
      {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "${value.toStringAsFixed(2)} ₽",
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
            ),
          ),
        ],
      ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle("Варианты рентабельности"),
        const SizedBox(height: 16),
        _buildMarginCard("Вариант 1", _desiredMarginController1, margin1, 1),
        const SizedBox(height: 16),
        _buildMarginCard("Вариант 2", _desiredMarginController2, margin2, 2),
        const SizedBox(height: 16),
        _buildMarginCard("Вариант 3", _desiredMarginController3, margin3, 3),
      ],
    );
  }

  Widget _buildMarginCard(String title, TextEditingController controller,
      double margin, int variantIndex) {
    bool isSelected = (_selectedVariant == variantIndex);
    return InkWell(
      onTap: () {
        setState(() {
          _selectedVariant = variantIndex;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isSelected ? 51 : 25),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.blue : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    flex: 3,
                    child: Text("Желаемая рентабельность:"),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      _updateMargin(controller, margin, -1);
                    },
                  ),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: controller,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                      ),
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
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      _uploadPrices(controller);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
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
    final model = context.read<OzonProductCardViewModel>();
    final double costPrice = double.tryParse(_costController.text) ?? 0;
    final double delivery = double.tryParse(_deliveryController.text) ?? 0;
    final double packaging = double.tryParse(_packageController.text) ?? 0;
    final int taxRate = int.tryParse(_taxRateController.text) ?? 7;
    final double paidAcceptance =
        double.tryParse(_paidAcceptanceController.text) ?? 0;
    final double storage = double.tryParse(_storageController.text) ?? 0;

    final commissionValues = model.getCurrentCommissionValues();
    final double totalReturnCost = commissionValues["returnCost"] ?? 0;
    final double commissionPercent = commissionValues["commissionPercent"] ?? 0;
    final double logistics = commissionValues["deliveryCost"] ?? 0;

    double selectedMargin;
    if (_selectedVariant == 1) {
      selectedMargin = double.tryParse(_desiredMarginController1.text) ?? 30;
    } else if (_selectedVariant == 2) {
      selectedMargin = double.tryParse(_desiredMarginController2.text) ?? 35;
    } else {
      selectedMargin = double.tryParse(_desiredMarginController3.text) ?? 40;
    }

    final selectedResults = model.calculateForMargin(
      desiredMargin: selectedMargin,
      costPrice: costPrice,
      delivery: delivery,
      packaging: packaging,
      paidAcceptance: paidAcceptance,
      totalReturnCost: totalReturnCost,
      logistics: logistics,
      storage: storage,
      commissionPercent: commissionPercent,
      taxRate: taxRate,
    );
    final price = selectedResults["finalPrice"]!;
    print(price);

    model.updatePrice(price);
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('"$value" скопировано в буфер обмена')),
                );
              },
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                textAlign: TextAlign.right,
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
            flex: 3,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                suffixText: suffix,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: "0",
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Обновление суммы расходов при синхронизации с деталями
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

    // Вызываем метод для обновления данных в модели и сохранения изменений
    _onInputChanged();
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
  bool _isExpanded = false;

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
    if (oldWidget.details != widget.details ||
        oldWidget.currentAmount != widget.currentAmount) {
      _calculateDetailsSum();
    }
  }

  void _calculateDetailsSum() {
    double sum = 0;
    if (widget.details != null && widget.details!.isNotEmpty) {
      for (var detail in widget.details!) {
        sum += detail.amount;
      }
    }

    setState(() {
      _detailsSum = sum;
    });
  }

  bool get _hasDifference {
    // Сравниваем с точностью до 2 знаков после запятой
    final roundedCurrent = (widget.currentAmount * 100).round() / 100;
    final roundedSum = (_detailsSum * 100).round() / 100;
    return roundedCurrent != roundedSum;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        size: 20,
                      ),
                    ],
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _hasDifference ? Colors.orange : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 16),
                if (widget.details != null && widget.details!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Детали:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                                  icon: const Icon(Icons.delete_outline,
                                      size: 20),
                                  onPressed: () {
                                    widget.onDeleteDetail(detail);
                                    // Также пересчитываем сумму после удаления
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      if (mounted) {
                                        _calculateDetailsSum();
                                      }
                                    });
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          )),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
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
                                color: _hasDifference
                                    ? Colors.orange
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Добавить'),
                      onPressed: _showAddDetailDialog,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                    if (_hasDifference)
                      TextButton.icon(
                        icon: const Icon(Icons.sync, size: 16),
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
            ],
          ),
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

              // Важно: вызываем пересчет суммы и обновляем UI после добавления детали
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _calculateDetailsSum();
                }
              });
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
