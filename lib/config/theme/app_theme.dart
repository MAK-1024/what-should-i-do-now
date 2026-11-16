import 'package:flutter/material.dart';
import 'package:wsidappp/config/theme/app_colors.dart';

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
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      elevation: 2,
      indicatorColor: AppColors.primaryContainer,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
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
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      elevation: 2,
      indicatorColor: AppColors.primaryContainerDark,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
  );
}

// ── Shared base builder ───────────────────────────────────────────────────────

ThemeData _buildBase(ColorScheme colorScheme) {
  final outlineColor = colorScheme.outlineVariant;
  final surfaceColor = colorScheme.surface;

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
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
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
        padding: _buttonPadding,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: const StadiumBorder(),
        padding: _buttonPadding,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: const StadiumBorder(),
        padding: _buttonPadding,
      ),
    ),
    chipTheme: ChipThemeData(
      shape: const StadiumBorder(),
      side: BorderSide(color: outlineColor),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurface),
    ),
  );
}
