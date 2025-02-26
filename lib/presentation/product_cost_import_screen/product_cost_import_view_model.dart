import 'dart:io' show File; // Используем только для Desktop/Mobile
import 'dart:typed_data'; // Для хранения байт в web
import 'package:universal_html/html.dart' as html;

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';
import 'package:mc_dashboard/domain/entities/product_cost_data.dart';

abstract class ProductCostImportProductCostService {
  Future<void> saveProductCost(ProductCostData costData);
  Future<ProductCostData?> getProductCost(int nmID);
  Future<List<ProductCostData>> getAllCostData();
}

class ProductCostImportViewModel extends ViewModelBase {
  final ProductCostImportProductCostService productCostService;

  /// Путь к файлу (для Desktop/Mobile), или имя файла (для Web)
  String? selectedFilePath;

  /// Временное поле для хранения байт файла (нужно только для Web)
  Uint8List? _excelBytesForWeb;

  String? errorMessage;
  int updatedCount = 0;

  ProductCostImportViewModel({
    required this.productCostService,
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
          // В Web нет реального пути – используем имя файла для отображения
          selectedFilePath = result.files.single.name;
          _excelBytesForWeb = result.files.single.bytes;
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

  Future<void> importData() async {
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
            sheet.rows.first.length < 5) {
          throw Exception(
              "Ошибка: Неверный формат таблицы. ${sheet == null} ${sheet == null || sheet.rows.isEmpty} ${sheet == null || sheet.rows.first.length < 5}");
        }

        for (var i = 1; i < sheet.rows.length; i++) {
          final row = sheet.rows[i];

          if (row.length < 5 ||
              row[0] == null ||
              row[1] == null ||
              row[2] == null ||
              row[3] == null ||
              row[4] == null) {
            continue;
          }

          final nmID = int.tryParse(row[0]?.value.toString() ?? "");
          final costPrice = double.tryParse(row[1]?.value.toString() ?? "");
          final delivery = double.tryParse(row[2]?.value.toString() ?? "");
          final packaging = double.tryParse(row[3]?.value.toString() ?? "");
          final paidAcceptance =
              double.tryParse(row[4]?.value.toString() ?? "");
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
                await productCostService.getProductCost(nmID);

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
              returnRate: returnRate,
            );

            await productCostService.saveProductCost(costData);
            count++;
          }
        }
      }

      updatedCount = count;
    } catch (e) {
      errorMessage = "Ошибка при обработке файла: ${e.toString()}";
    } finally {
      setLoaded();
      notifyListeners();
    }
  }

  Future<void> exportCostDataToExcelWeb() async {
    // 1) Создаём Excel-файл в памяти
    final List<ProductCostData> costDataList =
        await productCostService.getAllCostData();
    var excel = Excel.createExcel();
    print('{ProductCostData} count: ${costDataList.length}');

// "Sheet1" -- это лист, который библиотека создала автоматически
    excel.rename('Sheet1', 'Sheet 1');

// Делаем "Sheet 1" активным листом
    excel.setDefaultSheet('Sheet 1');

// Теперь получаем лист
    Sheet sheet = excel['Sheet 1'];

// Можно вставить строку заголовка
    // sheet.appendRow(<CellValue?>[
    //   TextCellValue("nmID"),
    //   TextCellValue("costPrice"),
    //   TextCellValue("delivery"),
    //   TextCellValue("packaging"),

    // ]);

// Заполняем
    for (var data in costDataList) {
      sheet.appendRow(<CellValue?>[
        IntCellValue(data.nmID),
        DoubleCellValue(data.costPrice),
        DoubleCellValue(data.delivery),
        DoubleCellValue(data.packaging),
        DoubleCellValue(data.paidAcceptance),
      ]);
    }

    List<int>? fileBytes = excel.encode();
    if (fileBytes == null) {
      print("Ошибка при кодировании Excel файла.");
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
}
