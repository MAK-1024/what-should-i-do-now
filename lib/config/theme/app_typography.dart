import 'package:flutter/material.dart';

/// Brand typography tokens mirroring the Figma text styles (Tajawal).
class ThemeTypography {
  const ThemeTypography();

  static const String fontFamily = 'Tajawal';

  /// Figma "H3 bold": 26 / Bold / line-height 100%.
  TextStyle get h3Bold => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1,
      );

  /// Figma "title2": 18 / Medium / line-height 100%.
  TextStyle get title2 => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 1,
      );

  /// Figma "title1 bold": 16 / Bold / line-height 100%.
  TextStyle get title1Bold => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1,
      );

  /// Figma "H1 bold": 20 / Bold / line-height 150%.
  TextStyle get h1Bold => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.5,
      );

  /// Figma "title1": 16 / Medium / line-height 100%.
  TextStyle get title1 => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1,
      );

  /// Figma "body": 14 / Medium / line-height 100%.
  TextStyle get body => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1,
      );

  /// Figma "body bold": 14 / Bold / line-height 100%.
  TextStyle get bodyBold => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1,
      );

  /// Figma "caption": 13 / Medium / line-height 100%.
  TextStyle get caption => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1,
      );

  /// Figma "caption bold": 13 / Bold.
  TextStyle get captionBold => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        height: 1,
      );

  /// Figma "title2 bold": 18 / Bold / line-height 100%.
  TextStyle get title2Bold => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1,
      );

  /// Material [TextTheme] wired to Tajawal + Figma scale for [ThemeData].
  static TextTheme materialTextTheme(Color onSurface) {
    const ThemeTypography typo = ThemeTypography();
    TextStyle colored(TextStyle style) => style.copyWith(color: onSurface);

    return TextTheme(
      displayLarge: colored(typo.h3Bold),
      displayMedium: colored(typo.h3Bold),
      displaySmall: colored(typo.h1Bold),
      headlineLarge: colored(typo.h3Bold),
      headlineMedium: colored(typo.h1Bold),
      headlineSmall: colored(typo.h1Bold),
      titleLarge: colored(typo.title2Bold),
      titleMedium: colored(typo.title1Bold),
      titleSmall: colored(typo.bodyBold),
      bodyLarge: colored(typo.bodyBold),
      bodyMedium: colored(typo.bodyBold),
      bodySmall: colored(typo.captionBold),
      labelLarge: colored(typo.bodyBold),
      labelMedium: colored(typo.captionBold),
      labelSmall: colored(typo.caption),
    );
  }
}
