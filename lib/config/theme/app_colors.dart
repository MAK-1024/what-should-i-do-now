import 'package:flutter/material.dart';

/// Color tokens for the "What Should I Do?" app.
///
/// Single source of truth:
///  1. Foundation palette  – raw values copied from the Figma design system.
///  2. Light semantic tokens – aliases of the foundation palette.
///  3. Dark tokens – unchanged.
///
/// Widgets must never hardcode colors; they read them from the theme.
abstract final class AppColors {
  // ── 1. Foundation palette (Figma: Foundation / Green · grey) ──────────────
  static const Color green50 = Color(0xFFEFF3F1);
  static const Color green100 = Color(0xFFCCDAD2);
  static const Color green200 = Color(0xFFB4C9BD);
  static const Color green300 = Color(0xFF91B09F);
  static const Color green400 = Color(0xFF7CA18C);
  static const Color green500 = Color(0xFF5B896F);
  static const Color green600 = Color(0xFF537D65);
  static const Color green700 = Color(0xFF41614F);
  static const Color green800 = Color(0xFF324B3D);
  static const Color green900 = Color(0xFF263A2F);

  static const Color grey50 = Color(0xFFF0F1F2);
  static const Color grey100 = Color(0xFFD1D3D8);
  static const Color grey200 = Color(0xFFBBBEC5);
  static const Color grey300 = Color(0xFF9CA1AA);
  static const Color grey400 = Color(0xFF898E99);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF616874);
  static const Color grey700 = Color(0xFF4C515B);
  static const Color grey800 = Color(0xFF3B3F46);
  static const Color grey900 = Color(0xFF2D3036);

  // Status (Figma: Foundation / error · warning)
  static const Color error50 = Color(0xFFFFEFED);
  static const Color error500 = Color(0xFFFF614C);
  static const Color error700 = Color(0xFFB54536);
  static const Color error800 = Color(0xFF8C352A);
  static const Color warning50 = Color(0xFFFBF8EA);
  static const Color warning700 = Color(0xFF98801F);

  // Other
  static const Color greyNeutral = Color(0xFF616161);
  static const Color inputOutline = Color(0xFFEAECF0);

  /// Teal-blue end stop of the blurred background glows.
  static const Color glowBlue = Color(0xFF5085A4);

  // ── 2. Light semantic tokens (aliases of the foundation palette) ──────────
  static const Color primary = green500;
  static const Color primaryLight = green400;
  static const Color primaryContainer = green50;
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = green800;

  static const Color secondary = green600;
  static const Color secondaryContainer = green100;
  static const Color onSecondary = Color(0xFFFFFFFF);

  /// Warm amber — used for duration/time tags (also used by the dark theme).
  static const Color accent = Color(0xFFD97706);
  static const Color accentContainer = Color(0xFFFEF3C7);

  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = green50;

  /// Dividers and hairline borders (app bar, nav bar, task rows).
  static const Color outline = grey50;

  static const Color textPrimary = grey900;
  static const Color textSecondary = grey500;
  static const Color textMuted = grey300;

  static const Color errorContainer = error50;

  // ── 3. Dark mode (unchanged) ──────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF121816);
  static const Color darkSurface = Color(0xFF1C2522);
  static const Color darkSurfaceVariant = Color(0xFF243028);
  static const Color darkOutline = Color(0xFF2D3B36);
  static const Color primaryDark = Color(0xFF6B9E78);
  static const Color primaryContainerDark = Color(0xFF1E3D35);
  static const Color onPrimaryDark = Color(0xFF0D1F1A);
  static const Color darkAccentContainer = Color(0xFF3D2800);
  static const Color darkErrorContainer = Color(0xFF4A1515);

  static const Color darkTextPrimary = Color(0xFFE8F0ED);
  static const Color darkTextSecondary = Color(0xFF8FA89E);

  // ── Status & feedback (shared) ────────────────────────────────────────────
  static const Color error = Color(0xFFEF4444);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF10B981);

  // ── Category preset palette ───────────────────────────────────────────────
  static const Color categoryGreen = primary;
  static const Color categoryTeal = Color(0xFF0D9488);
  static const Color categoryAmber = accent;
  static const Color categoryRose = Color(0xFFE11D48);
  static const Color categoryEmerald = success;
  static const Color categorySky = Color(0xFF0284C7);
  static const Color categoryViolet = Color(0xFF7C3AED);
  static const Color categoryOrange = Color(0xFFEA580C);

  // Kept so existing code doesn't break
  static const Color categoryIndigo = Color(0xFF4F46E5);

  static const List<Color> categoryPalette = <Color>[
    categoryGreen,
    categoryTeal,
    categoryAmber,
    categoryRose,
    categoryEmerald,
    categorySky,
    categoryViolet,
    categoryOrange,
  ];

  // ── Utilities ─────────────────────────────────────────────────────────────

  /// Parses a hex string (e.g. `"#52796F"` or `"52796F"`) to [Color].
  static Color? parseHexColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return null;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    final value = int.tryParse(buffer.toString(), radix: 16);
    return value != null ? Color(value) : null;
  }

  /// Converts a [Color] to a hex string with leading hash (e.g. `"#52796F"`).
  static String toHexString(Color color) =>
      '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
}
