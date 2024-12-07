import 'package:flutter/material.dart';

TextTheme buildAdaptiveTextTheme(BuildContext context,
    {required TextTheme baseTextTheme}) {
  final screenWidth = MediaQuery.sizeOf(context).width;

  double headlineFontSize;
  double bodyFontSize;

  if (screenWidth < 360) {
    // Small Mobile
    headlineFontSize = 8.0;
    bodyFontSize = 6.0;
  } else if (screenWidth < 480) {
    // Mobile (Portrait)
    headlineFontSize = 10.0;
    bodyFontSize = 7.0;
  } else if (screenWidth < 600) {
    // Mobile (Landscape)
    headlineFontSize = 10.0;
    bodyFontSize = 8.0;
  } else if (screenWidth < 768) {
    // Small Tablet
    headlineFontSize = 10.0;
    bodyFontSize = 9.0;
  } else if (screenWidth < 1050) {
    // Large Tablet
    headlineFontSize = 12.0;
    bodyFontSize = 10.0;
  } else if (screenWidth < 1310) {
    // Small Desktop
    headlineFontSize = 12.0;
    bodyFontSize = 11.0;
  } else if (screenWidth < 1440) {
    // Desktop (Default)
    headlineFontSize = 14.0;
    bodyFontSize = 12.0;
  } else {
    // Large Desktop
    headlineFontSize = 16.0;
    bodyFontSize = 14.0;
  }

  // Копируем текущую тему и добавляем адаптивные стили
  return baseTextTheme.copyWith(
    titleLarge: baseTextTheme.titleLarge?.copyWith(fontSize: headlineFontSize),
    bodyMedium: baseTextTheme.bodyMedium?.copyWith(fontSize: bodyFontSize),
  );
}
