import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';
import 'package:mc_dashboard/domain/entities/card_info.dart';
import 'package:mc_dashboard/domain/entities/charc.dart';
import 'package:mc_dashboard/domain/entities/product.dart';
import 'package:mc_dashboard/domain/entities/product_item.dart';

abstract class ProductDetailWbContentApi {
  Future<List<Charc>> fetchCharcs(int subjectId);
  Future<Map<String, dynamic>> uploadProductCards(
      List<Map<String, dynamic>> productData);
  Future<Map<String, dynamic>> uploadMediaFile({
    required String nmId,
    required int photoNumber,
    required Uint8List mediaFile,
  });
}

abstract class ProductDetailApiProductsService {
  Future<List<ProductItem>> getProducts({required int subjectId});
}

abstract class ProductDetailCardInfoService {
  Future<CardInfo> fetchCardInfo(String productId);
}

class ProductDetailViewModel extends ViewModelBase {
  final ProductDetailWbContentApi wbApiContentService;
  final ProductDetailApiProductsService productSource;
  final ProductDetailCardInfoService cardInfoService;
  final ProductData product;

  List<Charc> charcs = [];
  List<ProductItem> products = [];
  Map<int, CardInfo> productCardInfo = {}; // Карточки товаров
  String? errorMessage;
  int? _subjectId;

  ProductDetailViewModel({
    required this.wbApiContentService,
    required this.product,
    required this.productSource,
    required this.cardInfoService,
    required super.context,
  });

  Future<void> fetchData(int subjectId) async {
    _subjectId = subjectId;
    setLoading();
    await Future.wait([
      fetchCharcs(subjectId),
      fetchProductCharacteristics(subjectId),
    ]);
    setLoaded();
  }

  Future<void> fetchCharcs(int subjectId) async {
    try {
      errorMessage = null;
      List<Charc> fetchedCharcs =
          await wbApiContentService.fetchCharcs(subjectId);

      // Обновляем charcs, если они не дублируются с характеристиками из карточек
      for (var charc in fetchedCharcs) {
        if (!charcs.any((c) => c.name == charc.name)) {
          charcs.add(charc);
        }
      }
    } catch (e) {
      errorMessage = 'Ошибка: ${e.toString()}';
    }
  }

  Future<void> fetchCardInfoAndMergeCharacteristics(
      String productId, List<TextEditingController> charControllers) async {
    try {
      errorMessage = null;
      final cardInfo = await cardInfoService.fetchCardInfo(productId);
      productCardInfo[int.parse(productId)] = cardInfo;

      final characteristics = _extractCharacteristics(cardInfo);

      // Заполняем характеристики
      for (var entry in characteristics.entries) {
        final charIndex = charcs.indexWhere((c) => c.name == entry.key);
        if (charIndex == -1) {
          // Если характеристики ещё нет в charcs, добавляем её
          charcs.add(Charc(
            id: entry.key.hashCode,
            subjectName: '',
            name: entry.key,
            dataType: 'string',
            unit: '',
          ));
          charControllers.add(TextEditingController(text: entry.value));
        } else {
          // Если характеристика уже есть — заполняем поле ввода
          charControllers[charIndex].text = entry.value;
        }
      }

      notifyListeners();
    } catch (e) {
      errorMessage = 'Ошибка загрузки карточки товара: ${e.toString()}';
    }
  }

  Future<void> fetchProductCharacteristics(int subjectId) async {
    try {
      errorMessage = null;
      products = await productSource.getProducts(subjectId: subjectId);

      for (var product in products) {
        try {
          final cardInfo =
              await cardInfoService.fetchCardInfo(product.id.toString());

          productCardInfo[product.id] = cardInfo;
        } catch (e) {
          continue;
        }
      }

      // Собираем характеристики с возможными значениями (options) из всех карточек
      Map<String, Set<String>> uniqueCharacteristics = {};
      for (var card in productCardInfo.values) {
        final characteristics = _extractCharacteristics(card);
        characteristics.forEach((key, value) {
          uniqueCharacteristics.putIfAbsent(key, () => {}).add(value);
        });
      }

      // Добавляем в charcs, если таких характеристик ещё нет
      for (var entry in uniqueCharacteristics.entries) {
        if (!charcs.any((c) => c.name == entry.key)) {
          charcs.add(Charc(
            id: entry.key.hashCode,
            subjectName: '',
            name: entry.key,
            dataType: 'string',
            unit: '',
          ));
        }
      }
      errorMessage = 'Done ${charcs.length} charcs';
    } catch (e) {
      errorMessage = 'Ошибка загрузки характеристик: ${e.toString()}';
    }
  }

  List<String> getCharacteristicOptions(String characteristicName) {
    final options = <String>{};

    for (var card in productCardInfo.values) {
      final characteristics = _extractCharacteristics(card);
      if (characteristics.containsKey(characteristicName)) {
        options.add(characteristics[characteristicName]!);
      }
    }

    return options.toList();
  }

  Map<String, String> _extractCharacteristics(CardInfo card) {
    return Map.fromEntries(
      card.characteristicFull
          .split('; ')
          .where((e) => e.contains(':'))
          .map((e) {
        final parts = e.split(':');
        return MapEntry(parts[0].trim(), parts[1].trim());
      }),
    );
  }

  Future<void> generateFullProductJson(
      String vendorCode,
      String title,
      String description,
      String length,
      String width,
      String height,
      List<TextEditingController> charControllers) async {
    if (_subjectId == null) {
      errorMessage = 'Ошибка: Subject ID не установлен';
      return;
    }

    // Собираем характеристики из введённых пользователем данных
    List<Map<String, dynamic>> characteristics = [];
    for (int i = 0; i < charcs.length; i++) {
      final rawValue = charControllers[i].text.trim();

      if (rawValue.isNotEmpty) {
        // Проверяем, требует ли характеристика валидации
        final parsedValue =
            _validateSpecificCharacteristics(charcs[i].id, rawValue);
        if (parsedValue == null) {
          errorMessage =
              'Ошибка: Некорректное значение для характеристики "${charcs[i].name}"';
          return;
        }

        characteristics.add({
          "id": charcs[i].id,
          "value": parsedValue,
        });
      }
    }

    // Создаём JSON-объект товара
    final Map<String, dynamic> productJson = {
      "subjectID": _subjectId,
      "variants": [
        {
          if (vendorCode.isNotEmpty) "vendorCode": vendorCode,
          if (title.isNotEmpty) "title": title,
          if (description.isNotEmpty) "description": description,
          "dimensions": {
            "length": int.tryParse(length) ?? 0,
            "width": int.tryParse(width) ?? 0,
            "height": int.tryParse(height) ?? 0
          },
          if (characteristics.isNotEmpty) "characteristics": characteristics,
        }
      ]
    };
    try {
      final resp = await wbApiContentService.uploadProductCards([productJson]);
      if (resp['error']) {
        errorMessage = 'Ошибка создания карточек товаров: ${resp['errorText']}';
      }
    } catch (e) {
      errorMessage = 'Ошибка создания карточек товаров: $e';
    }
  }

  dynamic _validateSpecificCharacteristics(int id, String input) {
    final validationRequiredIds = {
      88953,
      564161466,
      931410073,
      430872901,
      90630,
      90673
    };

    if (validationRequiredIds.contains(id)) {
      final sanitizedInput = input.replaceAll(RegExp(r'[^\d.]'), '').trim();

      if (sanitizedInput.isEmpty) return null;

      return sanitizedInput.contains('.')
          ? double.tryParse(sanitizedInput)
          : int.tryParse(sanitizedInput);
    }

    return input;
  }

  // Внутри класса ProductDetailViewModel
  Future<void> uploadProductImages(
      List<Uint8List> selectedImages, String nmId) async {
    for (int i = 0; i < selectedImages.length; i++) {
      try {
        await wbApiContentService.uploadMediaFile(
          nmId: nmId,
          photoNumber: i + 1,
          mediaFile: selectedImages[i], // теперь Uint8List вместо File
        );
      } catch (e) {
        errorMessage = 'Ошибка загрузки изображения: ${e.toString()}';
      }
    }
  }

  @override
  Future<void> asyncInit() async {}
}
