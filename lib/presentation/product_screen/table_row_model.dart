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

    // Определяем секцию
    final List<double> similarities = [
      row.titleSimilarity,
      row.characteristicsSimilarity,
      row.descriptionSimilarity
    ];

    final maxSimilarity = similarities.reduce((a, b) => a > b ? a : b);

    // Условие выбора секции
    if (row.titleSimilarity == maxSimilarity && row.titleSimilarity > 0.70) {
      sections["title"]!.add(row);
    } else if (row.characteristicsSimilarity == maxSimilarity &&
        row.characteristicsSimilarity > 0.10) {
      sections["characteristics"]!.add(row);
    } else if (row.descriptionSimilarity == maxSimilarity &&
        row.descriptionSimilarity > 0.10) {
      sections["description"]!.add(row);
    } else {
      sections["nowhere"]!.add(row);
    }
  }

  return sections;
}
