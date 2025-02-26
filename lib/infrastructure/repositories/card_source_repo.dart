import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mc_dashboard/.env.dart';
import 'package:mc_dashboard/domain/entities/product.dart';
import 'package:mc_dashboard/domain/services/product_service.dart';
import 'package:universal_io/io.dart';

class CardSourceRepo implements ProductSource {
  final String sourceDirectoryPath; // Можно задать путь

  const CardSourceRepo({this.sourceDirectoryPath = Env.inputPath});

  @override
  Future<List<Product>> getProducts() async {
    if (kIsWeb) {
      return _getProductsFromWebFilePicker(); // Выбираем файл через браузер
    } else {
      return _getProductsFromFileSystem(); // Берем ZIP с диска
    }
  }

  // 📌 Выбор ZIP-файла в Web
  Future<List<Product>> _getProductsFromWebFilePicker() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (result == null || result.files.isEmpty) {
      throw Exception("❌ Файл не выбран!");
    }

    final fileBytes = result.files.first.bytes;
    if (fileBytes == null) {
      throw Exception("❌ Ошибка загрузки файла!");
    }

    return _extractProductsFromZip(fileBytes);
  }

  // 📌 Читаем ZIP-файлы с диска (ПК, Android, iOS)
  Future<List<Product>> _getProductsFromFileSystem() async {
    final products = <Product>[];

    final directory = Directory(sourceDirectoryPath);

    if (!await directory.exists()) {
      throw Exception("❌ Папка не найдена: $sourceDirectoryPath");
    }

    final zipFiles = directory
        .listSync()
        .where((entity) => entity is File && entity.path.endsWith('.zip'))
        .cast<File>();

    if (zipFiles.isEmpty) {
      throw Exception("⚠️ В папке нет ZIP-файлов: $sourceDirectoryPath");
    }

    for (final zipFile in zipFiles) {
      final bytes = await zipFile.readAsBytes();
      final productsFromZip = await _extractProductsFromZip(bytes);
      products.addAll(productsFromZip);
    }

    return products;
  }

  // 📌 Извлекаем JSON из ZIP
  Future<List<Product>> _extractProductsFromZip(List<int> zipBytes) async {
    final products = <Product>[];

    try {
      final archive = ZipDecoder().decodeBytes(zipBytes);

      for (final file in archive) {
        if (file.isFile && file.name == 'product.json') {
          final content = utf8.decode(file.content as List<int>);
          final Map<String, dynamic> decoded = json.decode(content);
          final product = Product.fromJson(file.name, decoded);
          products.add(product);
        }
      }
    } catch (e) {
      throw Exception("❌ Ошибка при разархивировании: $e");
    }

    return products;
  }
}
