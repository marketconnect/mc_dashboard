import 'dart:math';

double calculateCosineSimilarity(String text1, String text2) {
  // Преобразуем тексты в нижний регистр для корректного сравнения
  final normalizedText1 = text1.toLowerCase();
  final normalizedText2 = text2.toLowerCase();

  // Если один текст полностью входит в другой, возвращаем 100% релевантность
  if (normalizedText1.contains(normalizedText2) ||
      normalizedText2.contains(normalizedText1)) {
    return 1.0;
  }

  // В противном случае используем стандартный расчет Cosine Similarity
  final vector1 = _getWordFrequencyVector(normalizedText1);
  final vector2 = _getWordFrequencyVector(normalizedText2);

  final dotProduct = _calculateDotProduct(vector1, vector2);
  final magnitude1 = _calculateMagnitude(vector1);
  final magnitude2 = _calculateMagnitude(vector2);

  if (magnitude1 == 0 || magnitude2 == 0) {
    return 0.0; // Избегаем деления на 0
  }

  return dotProduct / (magnitude1 * magnitude2);
}

Map<String, int> _getWordFrequencyVector(String text) {
  final words = text.split(RegExp(r'\\s+'));
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
