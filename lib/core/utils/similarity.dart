import 'dart:math';

double calculateCosineSimilarity(String text1, String text2) {
  final normalizedText1 = text1.toLowerCase();
  final normalizedText2 = text2.toLowerCase();

  if (normalizedText1.contains(normalizedText2) ||
      normalizedText2.contains(normalizedText1)) {
    return 1.0;
  }

  final words1 = normalizedText1.split(RegExp(r'\s+')).toSet();
  final words2 = normalizedText2.split(RegExp(r'\s+')).toSet();

  if (words1.containsAll(words2) || words2.containsAll(words1)) {
    return 1.0;
  }

  final vector1 = _getWordFrequencyVector(normalizedText1);
  final vector2 = _getWordFrequencyVector(normalizedText2);

  final dotProduct = _calculateDotProduct(vector1, vector2);
  final magnitude1 = _calculateMagnitude(vector1);
  final magnitude2 = _calculateMagnitude(vector2);

  if (magnitude1 == 0 || magnitude2 == 0) {
    return 0.0;
  }

  return dotProduct / (magnitude1 * magnitude2);
}

Map<String, int> _getWordFrequencyVector(String text) {
  String cleanedText = text
      .toLowerCase()
      .replaceAll(RegExp(r'[^\p{L}\p{N}\s]+', unicode: true), ' ');

  final words = cleanedText.split(RegExp(r'\s+'));

  final frequency = <String, int>{};

  for (final word in words) {
    if (word.isNotEmpty) {
      frequency[word] = (frequency[word] ?? 0) + 1;
    }
  }

  return frequency;
}

double _calculateDotProduct(
    Map<String, int> vector1, Map<String, int> vector2) {
  double dotProduct = 0.0;
  for (final key in vector1.keys) {
    if (vector2.containsKey(key)) {
      dotProduct += vector1[key]! * vector2[key]!;
    }
  }

  return dotProduct;
}

double _calculateMagnitude(Map<String, int> vector) {
  return sqrt(vector.values.fold(0.0, (sum, freq) => sum + freq * freq));
}
