import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:mc_dashboard/core/env.dart';
import 'package:mc_dashboard/domain/entities/product.dart';

import 'package:excel/excel.dart';
import 'package:mc_dashboard/domain/services/product_service.dart';

class CardSourceRepo implements ProductSource {
  final String sourceDirectoryPath;

  const CardSourceRepo({this.sourceDirectoryPath = Env.inputPath});

  @override
  Future<List<ProductData>> getProducts() async {
    if (kIsWeb) {
      return _getProductsFromWebFilePicker();
    } else {
      return _getProductsFromFileSystem();
    }
  }

  // Выбор Excel файла в Web
  Future<List<ProductData>> _getProductsFromWebFilePicker() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result == null || result.files.isEmpty) {
      throw Exception("❌ Файл не выбран!");
    }

    final fileBytes = result.files.first.bytes;
    if (fileBytes == null) {
      throw Exception("❌ Ошибка загрузки файла!");
    }

    return _extractProductsFromExcel(fileBytes);
  }

  // Читаем Excel файлы с диска (ПК, Android, iOS)
  Future<List<ProductData>> _getProductsFromFileSystem() async {
    final products = <ProductData>[];

    final directory = Directory(sourceDirectoryPath);

    if (!await directory.exists()) {
      throw Exception("❌ Папка не найдена: $sourceDirectoryPath");
    }

    final excelFiles = directory
        .listSync()
        .where((entity) =>
            entity is File &&
            (entity.path.endsWith('.xlsx') || entity.path.endsWith('.xls')))
        .cast<File>();

    if (excelFiles.isEmpty) {
      throw Exception("⚠️ В папке нет Excel файлов: $sourceDirectoryPath");
    }

    for (final excelFile in excelFiles) {
      final bytes = await excelFile.readAsBytes();
      final productsFromExcel = await _extractProductsFromExcel(bytes);
      products.addAll(productsFromExcel);
    }

    return products;
  }

  // Извлекаем данные из Excel
  Future<List<ProductData>> _extractProductsFromExcel(
      List<int> excelBytes) async {
    final products = <ProductData>[];

    try {
      final excel = Excel.decodeBytes(excelBytes);
      final sheet = excel.tables.keys.first; // Берем первый лист
      final table = excel.tables[sheet]!;

      // Пропускаем заголовки и обрабатываем каждую строку
      for (var i = 1; i < table.maxRows; i++) {
        final row = table.row(i);
        if (row.length >= 8) {
          // Проверяем, что есть все необходимые колонки
          final rowData =
              row.map((cell) => cell?.value.toString() ?? '').toList();
          final product = ProductData.fromCsv(rowData);
          products.add(product);
        }
      }
    } catch (e) {
      throw Exception("❌ Ошибка при чтении Excel: $e");
    }

    return products;
  }
}
