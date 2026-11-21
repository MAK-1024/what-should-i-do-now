import 'package:flutter/material.dart';
import 'package:wsidappp/config/theme/app_typography.dart';
import 'package:wsidappp/config/theme/semantic_colors.dart';

/// Semantic context extension for clean theme and token consumption.
extension ThemeContextX on BuildContext {
  /// Quick access to the active [TextTheme].
  TextTheme get txt => Theme.of(this).textTheme;

  /// Brand (Figma) typography tokens.
  ThemeTypography get typo => const ThemeTypography();

  /// Semantic border radius tokens (sm: 8, md: 12, lg: 16).
  ThemeRadius get radius => const ThemeRadius();

  /// Quick access to the active [ColorScheme].
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// Figma light palette; dark mode uses [colors] semantics.
  BrandPalette get brand => BrandPalette(this);

  bool get isLightTheme => Theme.of(this).brightness == Brightness.light;

  /// Figma caption labels (light) vs uppercase settings-style headers (dark).
  TextStyle sectionHeaderStyle({Color? lightColor}) {
    if (isLightTheme) {
      return typo.bodyBold.copyWith(
        color: lightColor ?? brand.sectionLabel,
      );
    }
    return txt.labelMedium!.copyWith(
      color: colors.primary,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.1,
    );
  }

  String sectionHeaderLabel(String label) =>
      isLightTheme ? label : label.toUpperCase();

  /// Primary title under mascots / in cards (matches Home boldness).
  TextStyle get screenTitleStyle => typo.h1Bold.copyWith(
        color: isLightTheme ? colors.primary : colors.onSurface,
        height: 1.2,
      );

  /// Secondary line directly under [screenTitleStyle].
  TextStyle get screenSubtitleStyle => typo.bodyBold.copyWith(
        color: brand.bodyText,
        height: 1.35,
      );

  /// Figma flow screen titles (categories, tasks, forms).
  TextStyle get pageTitleStyle => typo.h1Bold.copyWith(
        color: isLightTheme ? colors.primary : colors.onSurface,
      );

  /// Card / list item titles.
  TextStyle get cardTitleStyle => typo.title2Bold.copyWith(
        color: brand.headlineText,
      );

  /// Secondary card copy — readable, not washed out.
  TextStyle get cardSubtitleStyle => typo.bodyBold.copyWith(
        color: brand.bodyText,
      );

  /// Timestamps, counts, tertiary hints.
  TextStyle get metaTextStyle => typo.captionBold.copyWith(
        color: brand.mutedText,
      );
}

/// Standardized border radius tokens across the design system.
class ThemeRadius {
  const ThemeRadius();

  BorderRadius get sm => BorderRadius.circular(8.0);
  BorderRadius get md => BorderRadius.circular(12.0);
  BorderRadius get lg => BorderRadius.circular(16.0);
  BorderRadius get xl => BorderRadius.circular(24.0);
  BorderRadius get card => BorderRadius.circular(20.0);
  BorderRadius get full => BorderRadius.circular(9999.0);
}
