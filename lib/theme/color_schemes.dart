import 'package:flutter/material.dart';

const lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF1c1c1c),
    onPrimary: Color(0xFF07cf79),
    primaryContainer: Color(0xFFD0E1FF),
    onPrimaryContainer: Color(0xFF001E3C),
    secondary: Color(0xFFb981ff),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFD0E1FF),
    onSecondaryContainer: Color(0xFF001E3C),
    tertiary: Color(0xFF0062B2),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFD0E1FF),
    onTertiaryContainer: Color(0xFF001E3C),
    error: Color(0xFFBA1A1A),
    errorContainer: Color(0xFFFFDAD6),
    onError: Color(0xFFFFFFFF),
    onErrorContainer: Color(0xFF410002),
    // body background
    surface: Color(0xFFfafafa),
    surfaceBright: Color(0xFFf1f2f4),
    onSurface: Color(0xFF4c647f),
    onSurfaceVariant: Color(0xFF4c647f),
    // side menu background
    surfaceContainerHighest: Colors.white);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Colors.white,
  onPrimary: Color(0xFF07cf79),
  primaryContainer: Color(0xFF004A8A),
  onPrimaryContainer: Color(0xFFD0E1FF),
  secondary: Color(0xFFb981ff),
  onSecondary: Color(0xFF1c1c1c),
  secondaryContainer: Color(0xFF004A8A),
  onSecondaryContainer: Color(0xFFD0E1FF),
  tertiary: Color(0xFFAECBFF),
  onTertiary: Color(0xFF003263),
  tertiaryContainer: Color(0xFF004A8A),
  onTertiaryContainer: Color(0xFFD0E1FF),
  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93000A),
  onError: Color(0xFF690005),
  onErrorContainer: Color(0xFFFFDAD6),
  // body background
  // surface: Color(0xFF1c1c1c),
  surface: Color(0xFF101115),
  surfaceBright: Color(0xFF101115),
  onSurface: Color(0xFFb5b1b2),
  onSurfaceVariant: Color(0xFFb5b1b2),
  // side menu background
  surfaceContainerHighest: Color(0xFF212121),
);

extension ShimmerGradientScheme on ColorScheme {
  LinearGradient get shimmerGradient {
    return brightness == Brightness.dark
        ? LinearGradient(
            colors: [
              const Color(0xFF333333), // Тёмный базовый цвет
              const Color(0xFF4F4F4F), // Немного светлее
              const Color(0xFF333333), // Повторяем базовый
            ],
            stops: [
              0.1,
              0.5,
              0.9,
            ],
            begin: const Alignment(-1.0, -0.3),
            end: const Alignment(1.0, 0.3),
            tileMode: TileMode.clamp,
          )
        : LinearGradient(
            colors: [
              Color(0xFFEBEBF4),
              Color(0xFFF4F4F4),
              Color(0xFFEBEBF4),
            ],
            stops: [
              0.1,
              0.3,
              0.4,
            ],
            begin: Alignment(-1.0, -0.3),
            end: Alignment(1.0, 0.3),
            tileMode: TileMode.clamp,
          );
  }
}
