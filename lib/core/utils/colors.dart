import 'package:flutter/material.dart';

List<Color> generateColorList(int count) {
  final List<Color> baseColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.cyan,
    Colors.amber,
    Colors.indigo,
    Colors.teal,
    Colors.pink,
    Colors.lime,
    Colors.brown,
    Colors.black
  ];

  // Если сегментов больше, чем базовых цветов, генерируем дополнительные
  if (count > baseColors.length) {
    final List<Color> generatedColors = [];
    for (int i = 0; i < count; i++) {
      final hue = (i * 360 / count) % 360; // Распределяем цвета по кругу
      generatedColors.add(HSVColor.fromAHSV(1.0, hue, 0.7, 0.9).toColor());
    }
    return generatedColors;
  }

  return baseColors.take(count).toList();
}
