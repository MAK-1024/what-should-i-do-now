import 'package:flutter/material.dart';

/// Semantic context extension for clean theme and token consumption.
extension ThemeContextX on BuildContext {
  /// Quick access to the active [TextTheme].
  TextTheme get txt => Theme.of(this).textTheme;

  /// Semantic border radius tokens (sm: 8, md: 12, lg: 16).
  ThemeRadius get radius => const ThemeRadius();

  /// Quick access to the active [ColorScheme].
  ColorScheme get colors => Theme.of(this).colorScheme;
}

/// Standardized border radius tokens across the design system.
class ThemeRadius {
  const ThemeRadius();

  BorderRadius get sm => BorderRadius.circular(8.0);
  BorderRadius get md => BorderRadius.circular(12.0);
  BorderRadius get lg => BorderRadius.circular(16.0);
  BorderRadius get full => BorderRadius.circular(9999.0);
}
