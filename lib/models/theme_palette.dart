import 'package:flutter/material.dart';
import 'dart:math' as math;

class ThemePalette {
  final Color primary;
  final Color background;
  final Color surface;
  final Color textDark;
  final Color textLight;

  ThemePalette({
    required this.primary,
    required this.background,
    required this.surface,
    required this.textDark,
    required this.textLight,
  });

  // Smart contrast helper
  Color getContrastText(Color backgroundColor) {
    // Use Flutter's built-in computeLuminance which correctly handles sRGB colorspace
    double luminance = backgroundColor.computeLuminance();
    // 0.5 is a standard midpoint. If the background is light, return dark text.
    return luminance > 0.5 ? textDark : textLight;
  }

  // Generate a random harmonious palette
  factory ThemePalette.random() {
    final random = math.Random();
    
    // Generate a random hue
    double h = random.nextDouble() * 360;
    
    // Helper to generate color from HSL
    Color fromHSL(double h, double s, double l) {
      return HSLColor.fromAHSL(1.0, h, s, l).toColor();
    }

    bool isDarkTheme = random.nextBool();

    // Primary: Vibrant
    Color primary = fromHSL(h, 0.7 + random.nextDouble() * 0.3, 0.4 + random.nextDouble() * 0.2);
    
    Color surface;
    Color background;
    
    if (isDarkTheme) {
      background = fromHSL(h, 0.15, 0.10); // Very dark
      surface = fromHSL(h, 0.2, 0.16);     // Slightly lighter dark
    } else {
      background = fromHSL(h, 0.1, 0.98);  // Very light
      surface = fromHSL(h, 0.15, 0.95);    // Slightly darker light
    }

    return ThemePalette(
      primary: primary,
      background: background,
      surface: surface,
      textDark: const Color(0xFF1A1A1A), // Off-black
      textLight: Colors.white,
    );
  }

  // Default Boxy Theme
  factory ThemePalette.boxy() {
    return ThemePalette(
      primary: const Color(0xFF8B3DFF), // Boxy Purple
      background: Colors.grey[50]!,
      surface: Colors.white,
      textDark: Colors.black,
      textLight: Colors.white,
    );
  }
}
