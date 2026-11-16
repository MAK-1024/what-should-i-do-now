import 'package:flutter/material.dart';

/// Sage Green design-system color tokens for the "What Should I Do?" app.
/// Light and dark variants are grouped for clarity.
abstract final class AppColors {
  // ── Light Brand / Palette ──────────────────────────────────────────────────
  static const Color primary = Color(0xFF52796F);
  static const Color primaryLight = Color(0xFF4A7C59);
  static const Color primaryContainer = Color(0xFFEAF2EF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF1A3A32);

  static const Color secondary = Color(0xFF4A7C59);
  static const Color secondaryContainer = Color(0xFFD6EAD9);
  static const Color onSecondary = Color(0xFFFFFFFF);

  /// Warm amber — used for duration/time tags.
  static const Color accent = Color(0xFFD97706);
  static const Color accentContainer = Color(0xFFFEF3C7);

  // ── Light Backgrounds & Surfaces ──────────────────────────────────────────
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEFF3F1);
  static const Color outline = Color(0xFFE5E7EB);

  // ── Dark Mode equivalents ─────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF121816);
  static const Color darkSurface = Color(0xFF1C2522);
  static const Color darkSurfaceVariant = Color(0xFF243028);
  static const Color darkOutline = Color(0xFF2D3B36);
  static const Color primaryDark = Color(0xFF6B9E78);
  static const Color primaryContainerDark = Color(0xFF1E3D35);
  static const Color onPrimaryDark = Color(0xFF0D1F1A);
  static const Color darkAccentContainer = Color(0xFF3D2800);
  static const Color darkErrorContainer = Color(0xFF4A1515);

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  // Dark text
  static const Color darkTextPrimary = Color(0xFFE8F0ED);
  static const Color darkTextSecondary = Color(0xFF8FA89E);

  // ── Status & Feedback ─────────────────────────────────────────────────────
  static const Color error = Color(0xFFEF4444);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF10B981);

  // ── Category Preset Palette ───────────────────────────────────────────────
  static const Color categoryGreen = primary;
  static const Color categoryTeal = Color(0xFF0D9488);
  static const Color categoryAmber = accent;
  static const Color categoryRose = Color(0xFFE11D48);
  static const Color categoryEmerald = success;
  static const Color categorySky = Color(0xFF0284C7);
  static const Color categoryViolet = Color(0xFF7C3AED);
  static const Color categoryOrange = Color(0xFFEA580C);

  // Keep old aliases alive so existing code doesn't break
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
