import 'dart:math';

import 'package:mc_dashboard/.env.dart';
import 'package:mc_dashboard/domain/entities/kw_lemmas.dart';
import 'package:mc_dashboard/domain/entities/normquery_product.dart';

enum GreatestSimilarityEnum { title, description, characteristics }

class SEOTableRowModel {
  final String normquery;
  final int freq;
  final int pos;
  final double titleSimilarity;
  final double descriptionSimilarity;
  final double characteristicsSimilarity;
  GreatestSimilarityEnum greatestSimilarity =
      GreatestSimilarityEnum.description;

  void setGreatestSimilarity(GreatestSimilarityEnum greatestSimilarity) {
    this.greatestSimilarity = greatestSimilarity;
  }

  SEOTableRowModel({
    required this.normquery,
    required this.freq,
    required this.pos,
    required this.titleSimilarity,
    required this.descriptionSimilarity,
    required this.characteristicsSimilarity,
  });

  factory SEOTableRowModel.fromNormqueryProduct(
    String normquery,
    String lemma,
    int freq,
    int pos,
    String lemmatizedTitle,
    String lemmatizedDescription,
    String lemmatizedCharacteristics,
    double Function(String, String) calculateCosineSimilarity,
  ) {
    return SEOTableRowModel(
      normquery: normquery,
      freq: freq,
      pos: pos,
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
      (normqueryProduct.pageNumber - 1) * 100 + normqueryProduct.pagePos,
      lemmatizedTitle,
      lemmatizedDescription,
      lemmatizedCharacteristics,
      calculateCosineSimilarity,
    );

    final titleSimilarity = row.titleSimilarity;
    final descriptionSimilarity = row.descriptionSimilarity;
    final characteristicsSimilarity = row.characteristicsSimilarity;

    if (titleSimilarity >= (descriptionSimilarity * 0.7) &&
        titleSimilarity >= (characteristicsSimilarity * 0.8)) {
      row.setGreatestSimilarity(GreatestSimilarityEnum.title);
    } else if (characteristicsSimilarity > titleSimilarity &&
        characteristicsSimilarity >= (descriptionSimilarity * 0.8)) {
      row.setGreatestSimilarity(GreatestSimilarityEnum.characteristics);
    }

    // Условие выбора секции
    if (titleSimilarity > NormquerySettings.minSimilarity) {
      sections["title"]!.add(row);
    }
    if (characteristicsSimilarity > NormquerySettings.minSimilarity) {
      sections["characteristics"]!.add(row);
    }
    if (descriptionSimilarity > NormquerySettings.minSimilarity) {
      sections["description"]!.add(row);
    }
  }

  return sections;
}

// Map<String, List<SEOTableRowModel>> generateRandomSEOTableRows(
//   int n,
// ) {
//   final random = Random();

//   // Примерные данные для генерации
//   final exampleNormqueries = [
//     "женская обувь",
//     "летние платья",
//     "мужские кроссовки",
//     "аксессуары для авто",
//     "косметика и парфюмерия",
//     "спортивный инвентарь",
//     "детские игрушки",
//   ];

//   final lemmatizedTitle = "пример лемматизированного заголовка";
//   final lemmatizedDescription = "пример лемматизированного описания";
//   final lemmatizedCharacteristics = "пример лемматизированных характеристик";

//   final generated = List.generate(n, (_) {
//     final normquery =
//         exampleNormqueries[random.nextInt(exampleNormqueries.length)];
//     final freq = random.nextInt(1000) + 1; // Случайная частота от 1 до 1000

//     final lemma = "${normquery.split(' ').join(' ')} лемма"; // Пример леммы

//     return SEOTableRowModel.fromNormqueryProduct(
//       normquery,
//       lemma,
//       freq,
//       random.nextInt(100) + 1,
//       lemmatizedTitle,
//       lemmatizedDescription,
//       lemmatizedCharacteristics,
//       mockCosineSimilarity,
//     );
//   });
//   final Map<String, List<SEOTableRowModel>> sections = {
//     "title": generated,
//     "characteristics": generated,
//     "description": generated
//   };
//   return sections;
// }

// Пример реализации функции calculateCosineSimilarity
// Используется для генерации случайных значений
double mockCosineSimilarity(String a, String b) {
  final random = Random();
  return random.nextDouble(); // Случайное значение от 0.0 до 1.0
}
