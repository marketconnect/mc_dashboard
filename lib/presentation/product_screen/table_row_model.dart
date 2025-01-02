import 'dart:math';

import 'package:mc_dashboard/domain/entities/kw_lemmas.dart';
import 'package:mc_dashboard/domain/entities/normquery_product.dart';

class SEOTableRowModel {
  final String normquery;
  final int freq;
  final double titleSimilarity;
  final double descriptionSimilarity;
  final double characteristicsSimilarity;

  SEOTableRowModel({
    required this.normquery,
    required this.freq,
    required this.titleSimilarity,
    required this.descriptionSimilarity,
    required this.characteristicsSimilarity,
  });

  factory SEOTableRowModel.fromNormqueryProduct(
    String normquery,
    String lemma,
    int freq,
    String lemmatizedTitle,
    String lemmatizedDescription,
    String lemmatizedCharacteristics,
    double Function(String, String) calculateCosineSimilarity,
  ) {
    return SEOTableRowModel(
      normquery: normquery,
      freq: freq,
      titleSimilarity: calculateCosineSimilarity(lemmatizedTitle, lemma),
      descriptionSimilarity:
          calculateCosineSimilarity(lemmatizedDescription, lemma),
      characteristicsSimilarity:
          calculateCosineSimilarity(lemmatizedCharacteristics, lemma),
    );
  }
}

Future<Map<String, List<SEOTableRowModel>>> generateSEOTableSections(
  List<NormqueryProduct> normqueryProducts,
  List<KwLemmaItem> kwLemmas,
  String lemmatizedTitle,
  String lemmatizedDescription,
  String lemmatizedCharacteristics,
  double Function(String, String) calculateCosineSimilarity,
) async {
  final Map<String, List<SEOTableRowModel>> sections = {
    "title": [],
    "characteristics": [],
    "description": [],
    "nowhere": [],
  };

  for (var normqueryProduct in normqueryProducts) {
    final lemmas = kwLemmas
        .where((kwLemma) => kwLemma.kwId == normqueryProduct.normqueryId);
    String lemma = '';
    if (lemmas.isNotEmpty) {
      lemma = lemmas.expand((kwLemma) => kwLemma.lemmas).join(' ');
    }

    final row = SEOTableRowModel.fromNormqueryProduct(
      normqueryProduct.normquery,
      lemma,
      normqueryProduct.freq,
      lemmatizedTitle,
      lemmatizedDescription,
      lemmatizedCharacteristics,
      calculateCosineSimilarity,
    );
    if (lemmatizedCharacteristics.contains("палаццо") &&
        lemma.contains("палаццо")) {}

    // Условие выбора секции
    if (row.titleSimilarity > 0.10) {
      sections["title"]!.add(row);
    }
    if (row.characteristicsSimilarity > 0.10) {
      sections["characteristics"]!.add(row);
    }
    if (row.descriptionSimilarity > 0.10) {
      sections["description"]!.add(row);
    }
  }

  return sections;
}

Map<String, List<SEOTableRowModel>> generateRandomSEOTableRows(
  int n,
) {
  final random = Random();

  // Примерные данные для генерации
  final exampleNormqueries = [
    "женская обувь",
    "летние платья",
    "мужские кроссовки",
    "аксессуары для авто",
    "косметика и парфюмерия",
    "спортивный инвентарь",
    "детские игрушки",
  ];

  final lemmatizedTitle = "пример лемматизированного заголовка";
  final lemmatizedDescription = "пример лемматизированного описания";
  final lemmatizedCharacteristics = "пример лемматизированных характеристик";

  final generated = List.generate(n, (_) {
    final normquery =
        exampleNormqueries[random.nextInt(exampleNormqueries.length)];
    final freq = random.nextInt(1000) + 1; // Случайная частота от 1 до 1000

    final lemma = "${normquery.split(' ').join(' ')} лемма"; // Пример леммы

    return SEOTableRowModel.fromNormqueryProduct(
      normquery,
      lemma,
      freq,
      lemmatizedTitle,
      lemmatizedDescription,
      lemmatizedCharacteristics,
      mockCosineSimilarity,
    );
  });
  final Map<String, List<SEOTableRowModel>> sections = {
    "title": generated,
    "characteristics": generated,
    "description": generated
  };
  return sections;
}

// Пример реализации функции calculateCosineSimilarity
// Используется для генерации случайных значений
double mockCosineSimilarity(String a, String b) {
  final random = Random();
  return random.nextDouble(); // Случайное значение от 0.0 до 1.0
}
