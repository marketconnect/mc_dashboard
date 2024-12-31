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
      titleSimilarity: calculateCosineSimilarity(lemma, lemmatizedTitle),
      descriptionSimilarity:
          calculateCosineSimilarity(lemma, lemmatizedDescription),
      characteristicsSimilarity:
          calculateCosineSimilarity(lemma, lemmatizedCharacteristics),
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
    "description": []
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

    // Определяем секцию
    final List<double> similarities = [
      row.titleSimilarity,
      row.characteristicsSimilarity,
      row.descriptionSimilarity
    ];

    final maxSimilarity = similarities.reduce((a, b) => a > b ? a : b);
    final similarityDiff =
        similarities.map((s) => (maxSimilarity - s).abs()).toList();

    // Условие выбора секции
    if (row.titleSimilarity == maxSimilarity || similarityDiff[0] <= 0.05) {
      sections["title"]!.add(row);
    } else if (row.characteristicsSimilarity == maxSimilarity ||
        similarityDiff[1] <= 0.05) {
      sections["characteristics"]!.add(row);
    } else {
      sections["description"]!.add(row);
    }
  }

  return sections;
}
