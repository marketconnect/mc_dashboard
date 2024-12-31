import 'dart:math';

double calculateCosineSimilarity(String text1, String text2) {
  final vector1 = _getWordFrequencyVector(text1);
  final vector2 = _getWordFrequencyVector(text2);

  final dotProduct = _calculateDotProduct(vector1, vector2);
  final magnitude1 = _calculateMagnitude(vector1);
  final magnitude2 = _calculateMagnitude(vector2);

  if (magnitude1 == 0 || magnitude2 == 0) {
    return 0.0; // Avoid division by zero
  }

  return dotProduct / (magnitude1 * magnitude2);
}

Map<String, int> _getWordFrequencyVector(String text) {
  final words = text.toLowerCase().split(RegExp(r'\s+'));
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
