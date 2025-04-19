import 'dart:io' show File; // Используем только для Desktop/Mobile
import 'dart:typed_data'; // Для хранения байт в web
import 'package:mc_dashboard/domain/entities/ozon_product.dart';
import 'package:mc_dashboard/domain/entities/product_card.dart';
import 'package:universal_html/html.dart' as html;

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';
import 'package:mc_dashboard/domain/entities/product_cost_data.dart';

import 'package:collection/collection.dart';

abstract class ProductCostImportProductCostService {
  Future<void> saveProductCost(ProductCostData costData);
  Future<ProductCostData?> getWbProductCost(int nmID);
  Future<List<ProductCostData>> getAllCostWbData();

  Future<List<ProductCostData>> getAllCostOzonData();
  Future<ProductCostData?> getOzonProductCost(int nmID);
}

abstract class ProductCostImportProductCardsService {
  Future<List<ProductCard>> fetchAllProductCards();
}

abstract class ProductCostImportOzonProductsService {
  Future<OzonProductsResponse> fetchProducts({
    List<String>? offerIds,
    List<int>? productIds,
    String? visibility,
    String? lastId,
    int? limit,
  });
}

class ProductCostImportViewModel extends ViewModelBase {
  final ProductCostImportProductCostService productCostService;
  final ProductCostImportProductCardsService productCardsService;
  final ProductCostImportOzonProductsService ozonProductsService;
  String? selectedFilePath;

  String? errorMessage;
  int updatedCount = 0;
  bool _wbDataLoaded = false;
  bool _ozonDataLoaded = false;

  bool get wbDataLoaded => _wbDataLoaded;
  bool get ozonDataLoaded => _ozonDataLoaded;
  bool get allDataLoaded => _wbDataLoaded && _ozonDataLoaded;

  ProductCostImportViewModel({
    required this.productCostService,
    required this.productCardsService,
    required this.ozonProductsService,
    required super.context,
  });

  /// Выбор файла
  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        withData: true, // Обязательно для Web!
      );

      if (result != null && result.files.isNotEmpty) {
        if (kIsWeb) {
          selectedFilePath = result.files.single.name;
          // _excelBytesForWeb = result.files.single.bytes;
        } else {
          selectedFilePath = result.files.single.path;
        }
        notifyListeners();
      }
    } catch (e) {
      errorMessage = "Ошибка при выборе файла: $e";
      notifyListeners();
    }
  }

  Future<void> importData(String mpType) async {
    try {
      setLoading();
      errorMessage = null;
      updatedCount = 0;
      notifyListeners();

      Uint8List? fileBytes;

      if (kIsWeb) {
        // Открываем диалог выбора файла
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['xlsx'],
        );

        if (result == null || result.files.isEmpty) return;
        fileBytes = result.files.first.bytes;
      } else {
        // Desktop/Mobile
        final file = File(selectedFilePath!);
        fileBytes = await file.readAsBytes();
      }

      if (fileBytes == null) throw Exception("Файл не загружен");

      final excel = Excel.decodeBytes(fileBytes);
      int count = 0;

      for (var table in excel.tables.keys) {
        final sheet = excel.tables[table];
        if (sheet == null ||
            sheet.rows.isEmpty ||
            sheet.rows.first.length < 2) {
          throw Exception(
              "Ошибка: Неверный формат таблицы. ${sheet == null} ${sheet == null || sheet.rows.isEmpty} ${sheet == null || sheet.rows.first.length < 5}");
        }

        for (var i = 1; i < sheet.rows.length; i++) {
          final row = sheet.rows[i];

          if (row.length < 2 || row[0] == null || row[1] == null) {
            continue;
          }

          final nmID = int.tryParse(row[0]?.value.toString() ?? "");
          final costPrice = double.tryParse(row[1]?.value.toString() ?? "");
          final delivery = row.length >= 3
              ? double.tryParse(row[2]?.value.toString() ?? "")
              : 0.0;
          final packaging = row.length >= 4
              ? double.tryParse(row[3]?.value.toString() ?? "")
              : 0.0;
          final paidAcceptance = row.length >= 5
              ? double.tryParse(row[4]?.value.toString() ?? "")
              : 0.0;
          final returnRate = row.length >= 6
              ? double.tryParse(row[5]?.value.toString() ?? "")
              : 15.0;

          if (nmID != null &&
              costPrice != null &&
              delivery != null &&
              packaging != null &&
              paidAcceptance != null &&
              returnRate != null) {
            final existingCostData =
                await productCostService.getWbProductCost(nmID);

            final costData = ProductCostData(
              nmID: nmID,
              costPrice: costPrice,
              delivery: delivery,
              packaging: packaging,
              paidAcceptance: paidAcceptance,
              warehouseName: existingCostData?.warehouseName ?? "Маркетплейс",
              taxRate: existingCostData?.taxRate ?? 7,
              desiredMargin1: existingCostData?.desiredMargin1 ?? 30,
              desiredMargin2: existingCostData?.desiredMargin2 ?? 35,
              desiredMargin3: existingCostData?.desiredMargin3 ?? 40,
              mpType: mpType,
              returnRate: returnRate,
            );

            await productCostService.saveProductCost(costData);
            count++;
          }
        }
      }

      updatedCount = count;
      if (mpType == 'wb') {
        _wbDataLoaded = true;
      } else if (mpType == 'ozon') {
        _ozonDataLoaded = true;
      }
    } catch (e) {
      errorMessage = "Ошибка при обработке файла: ${e.toString()}";
    } finally {
      setLoaded();
      notifyListeners();
    }
  }

  Future<void> exportCostDataToExcelWeb(String mpType) async {
    // 1) Создаём Excel-файл в памяти
    List<ProductCostData> costDataList = [];
    if (mpType == 'wb') {
      costDataList = await productCostService.getAllCostWbData();
    } else if (mpType == 'ozon') {
      costDataList = await productCostService.getAllCostOzonData();
    }

    var excel = Excel.createExcel();

    excel.rename('Sheet1', 'Sheet 1');

    // Делаем "Sheet 1" активным листом
    excel.setDefaultSheet('Sheet 1');

    // Теперь получаем лист
    Sheet sheet = excel['Sheet 1'];

    // Fetch all product cards for filtering
    List<ProductCard> wbProductCards =
        await productCardsService.fetchAllProductCards();
    final OzonProductsResponse ozonProductCardsResponse =
        await ozonProductsService.fetchProducts();

    // Заполняем
    for (var data in costDataList) {
      if (data.mpType != mpType) {
        continue;
      }

      String identifier;
      if (mpType == 'wb') {
        // Find the corresponding ProductCard by nmID
        // final productCard = wbProductCards.where(
        //   (card) => card.nmID == data.nmID,
        // );
        // if (productCard.isEmpty) {
        //   identifier = 'N/A';
        // }
        // identifier = productCard.first.vendorCode;
        final productCard =
            wbProductCards.firstWhereOrNull((card) => card.nmID == data.nmID);
        identifier = productCard?.vendorCode ?? 'N/A';
      } else {
        // Find the corresponding OzonProduct by nmID
        // final ozonProduct = ozonProductCardsResponse.items.where(
        //   (product) => product.productId == data.nmID,
        // );
        // if (ozonProduct.isEmpty) {
        //   identifier = 'N/A';
        // }
        // identifier = ozonProduct.first.offerId;
        final ozonProduct = ozonProductCardsResponse.items
            .firstWhereOrNull((p) => p.productId == data.nmID);
        identifier = ozonProduct?.offerId ?? 'N/A';
      }

      sheet.appendRow(<CellValue?>[
        IntCellValue(data.nmID),
        DoubleCellValue(data.costPrice),
        DoubleCellValue(data.delivery),
        DoubleCellValue(data.packaging),
        DoubleCellValue(data.paidAcceptance),
        TextCellValue(identifier), // Add the identifier as the fifth column
      ]);
    }

    List<int>? fileBytes = excel.encode();
    if (fileBytes == null) {
      return;
    }

    // 2) Делаем "Blob" и ссылку
    final blob = html.Blob([fileBytes], 'application/octet-stream');
    final url = html.Url.createObjectUrlFromBlob(blob);

    // 3) Создаём скрытую <a> для скачивания
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = "export_product_cost_data.xlsx";

    // 4) Добавляем в DOM, кликаем и убираем
    html.document.body!.children.add(anchor);
    anchor.click();
    html.document.body!.children.remove(anchor);

    // 5) Освобождаем URL
    html.Url.revokeObjectUrl(url);
  }

  @override
  Future<void> asyncInit() async {}

  Future<void> repeatForOzonProducts() async {
    try {
      final wbProductCards = await productCardsService.fetchAllProductCards();
      final ozonProductCards = await ozonProductsService.fetchProducts();
      int processedCount = 0;

      // Compare products
      for (var wbProductCard in wbProductCards) {
        try {
          // Find matching Ozon product, skip if not found
          final matchingOzonProducts = ozonProductCards.items.where(
            (ozonProductCard) =>
                ozonProductCard.offerId == wbProductCard.vendorCode,
          );

          if (matchingOzonProducts.isEmpty) {
            continue; // Skip if no matching product found
          }

          final ozonProductCard = matchingOzonProducts.first;
          final wbProductCost =
              await productCostService.getWbProductCost(wbProductCard.nmID);

          if (wbProductCost == null) {
            continue; // Skip if no WB cost data
          }

          final ozonProductCost = wbProductCost.copyWith(
            nmID: ozonProductCard.productId,
            mpType: 'ozon',
          );

          await productCostService.saveProductCost(ozonProductCost);
          processedCount++;
        } catch (e) {
          continue; // Skip problematic products
        }
      }

      if (processedCount > 0) {
        updatedCount = processedCount;
      } else {
        errorMessage =
            "Не найдено соответствующих товаров для копирования данных";
      }
      notifyListeners();
    } catch (e) {
      errorMessage = "Ошибка при сохранении: ${e.toString()}";
      notifyListeners();
    }
  }

  Future<void> repeatForWbProducts() async {
    try {
      final ozonProductCards = await ozonProductsService.fetchProducts();
      final wbProductCards = await productCardsService.fetchAllProductCards();
      int processedCount = 0;

      // Compare products
      for (var ozonProductCard in ozonProductCards.items) {
        try {
          // Find matching WB product, skip if not found
          final matchingWbProducts = wbProductCards.where(
            (wbProductCard) =>
                wbProductCard.vendorCode == ozonProductCard.offerId,
          );

          if (matchingWbProducts.isEmpty) {
            continue; // Skip if no matching product found
          }

          final wbProductCard = matchingWbProducts.first;
          final ozonProductCost = await productCostService
              .getOzonProductCost(ozonProductCard.productId);

          if (ozonProductCost == null) {
            continue; // Skip if no Ozon cost data
          }

          final wbProductCost = ozonProductCost.copyWith(
            nmID: wbProductCard.nmID,
            mpType: 'wb',
          );

          await productCostService.saveProductCost(wbProductCost);
          processedCount++;
        } catch (e) {
          continue; // Skip problematic products
        }
      }

      if (processedCount > 0) {
        updatedCount = processedCount;
      } else {
        errorMessage =
            "Не найдено соответствующих товаров для копирования данных";
      }
      notifyListeners();
    } catch (e) {
      errorMessage = "Ошибка при сохранении: ${e.toString()}";
      notifyListeners();
    }
  }
}
