import 'package:flutter/material.dart';
import 'package:wsidappp/config/theme/app_colors.dart';
import 'package:wsidappp/config/theme/app_typography.dart';

// ── Shared component shapes & styles ─────────────────────────────────────────

const _cardShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(16)),
);

const _buttonPadding = EdgeInsets.symmetric(horizontal: 24, vertical: 14);

const _inputRadius = BorderRadius.all(Radius.circular(12));

// ── Light Theme ───────────────────────────────────────────────────────────────

/// Builds the Sage Green **light** [ThemeData].
ThemeData buildLightTheme() {
  const colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.textPrimary,
    tertiary: AppColors.accent,
    onTertiary: AppColors.onPrimary,
    tertiaryContainer: AppColors.accentContainer,
    onTertiaryContainer: AppColors.textPrimary,
    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.textPrimary,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.surfaceVariant,
    outline: AppColors.outline,
    outlineVariant: AppColors.outline,
  );

  return _buildBase(colorScheme).copyWith(
    scaffoldBackgroundColor: AppColors.background,
  );
}

// ── Dark Theme ────────────────────────────────────────────────────────────────

/// Builds the Sage Green **dark** [ThemeData].
ThemeData buildDarkTheme() {
  const colorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primaryDark,
    onPrimary: AppColors.onPrimaryDark,
    primaryContainer: AppColors.primaryContainerDark,
    onPrimaryContainer: AppColors.darkTextPrimary,
    secondary: AppColors.primaryDark,
    onSecondary: AppColors.onPrimaryDark,
    secondaryContainer: AppColors.darkSurfaceVariant,
    onSecondaryContainer: AppColors.darkTextPrimary,
    tertiary: AppColors.accent,
    onTertiary: AppColors.onPrimary,
    tertiaryContainer: AppColors.darkAccentContainer,
    onTertiaryContainer: AppColors.darkTextPrimary,
    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: AppColors.darkErrorContainer,
    onErrorContainer: AppColors.darkTextPrimary,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkTextPrimary,
    surfaceContainerHighest: AppColors.darkSurfaceVariant,
    outline: AppColors.darkOutline,
    outlineVariant: AppColors.darkOutline,
  );

  return _buildBase(colorScheme).copyWith(
    scaffoldBackgroundColor: AppColors.darkBackground,
  );
}

// ── Shared base builder ───────────────────────────────────────────────────────

ThemeData _buildBase(ColorScheme colorScheme) {
  final outlineColor = colorScheme.outlineVariant;
  final surfaceColor = colorScheme.surface;
  final onSurface = colorScheme.onSurface;
  final textTheme = ThemeTypography.materialTextTheme(onSurface);
  const typo = ThemeTypography();
  final buttonLabel = typo.bodyBold.copyWith(color: colorScheme.onPrimary);

  return ThemeData(
    useMaterial3: true,
    fontFamily: ThemeTypography.fontFamily,
    colorScheme: colorScheme,
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    cardTheme: CardThemeData(
      elevation: 0,
      color: surfaceColor,
      surfaceTintColor: Colors.transparent,
      shape: _cardShape.copyWith(
        side: BorderSide(color: outlineColor),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      hintStyle: typo.body.copyWith(color: colorScheme.outline),
      labelStyle: typo.captionBold.copyWith(color: onSurface),
      floatingLabelStyle: typo.captionBold.copyWith(color: colorScheme.primary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: _inputRadius,
        borderSide: BorderSide(color: outlineColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: _inputRadius,
        borderSide: BorderSide(color: outlineColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: _inputRadius,
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: _inputRadius,
        borderSide: BorderSide(color: colorScheme.error),
      ),
    ),
    // Pill-shaped filled & elevated buttons
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: const StadiumBorder(),
        padding: _buttonPadding,
        textStyle: buttonLabel,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
        padding: _buttonPadding,
        textStyle: buttonLabel,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: const StadiumBorder(),
        padding: _buttonPadding,
        textStyle: typo.bodyBold,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: const StadiumBorder(),
        padding: _buttonPadding,
        textStyle: typo.bodyBold,
      ),
    ),
    chipTheme: ChipThemeData(
      shape: const StadiumBorder(),
      side: BorderSide(color: outlineColor),
      labelStyle: typo.bodyBold.copyWith(color: onSurface),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surfaceColor,
      elevation: 2,
      indicatorColor: colorScheme.primaryContainer,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final base = typo.caption.copyWith(color: onSurface);
        if (states.contains(WidgetState.selected)) {
          return typo.captionBold.copyWith(color: colorScheme.primary);
        }
        return base;
      }),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedLabelStyle: typo.captionBold,
      unselectedLabelStyle: typo.caption,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: typo.h1Bold.copyWith(color: onSurface),
      toolbarTextStyle: typo.title1Bold.copyWith(color: onSurface),
      iconTheme: IconThemeData(color: colorScheme.onSurface),
    ),
  );
}
