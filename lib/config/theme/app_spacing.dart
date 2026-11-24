import 'package:flutter/material.dart';

/// Centralized spacing tokens and directional insets matching Figma layout standards.
abstract final class AppSpacing {
  // Dimension values
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 48.0;

  // Directional padding insets (RTL-aware)
  static const EdgeInsetsDirectional pagePadding =
      EdgeInsetsDirectional.symmetric(horizontal: 20.0, vertical: 16.0);
  static const EdgeInsetsDirectional horizontalPage =
      EdgeInsetsDirectional.symmetric(horizontal: 20.0);
  static const EdgeInsetsDirectional cardPadding =
      EdgeInsetsDirectional.all(16.0);
  static const EdgeInsetsDirectional cardPaddingLg =
      EdgeInsetsDirectional.all(20.0);

  // Common SizedBox gaps
  static const SizedBox gapW4 = SizedBox(width: xs);
  static const SizedBox gapW8 = SizedBox(width: sm);
  static const SizedBox gapW12 = SizedBox(width: md);
  static const SizedBox gapW16 = SizedBox(width: lg);
  static const SizedBox gapW20 = SizedBox(width: xl);
  static const SizedBox gapW24 = SizedBox(width: xxl);

  static const SizedBox gapH4 = SizedBox(height: xs);
  static const SizedBox gapH8 = SizedBox(height: sm);
  static const SizedBox gapH12 = SizedBox(height: md);
  static const SizedBox gapH16 = SizedBox(height: lg);
  static const SizedBox gapH20 = SizedBox(height: xl);
  static const SizedBox gapH24 = SizedBox(height: xxl);
  static const SizedBox gapH32 = SizedBox(height: xxxl);
  static const SizedBox gapH48 = SizedBox(height: huge);
}
