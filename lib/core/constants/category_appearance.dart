import 'package:flutter/material.dart';
import 'package:wsidappp/config/theme/app_colors.dart';

/// Figma color swatch + icon presets for categories (`332:1566`, `337:1912`).
class CategoryColorOption {
  const CategoryColorOption({
    required this.storageHex,
    required this.swatchColor,
    required this.iconCircleColor,
    this.selectedRingColor,
  });

  final String storageHex;
  final Color swatchColor;
  final Color iconCircleColor;
  final Color? selectedRingColor;
}

class CategoryIconOption {
  const CategoryIconOption({required this.key, required this.icon});

  final String key;
  final IconData icon;
}

abstract final class CategoryAppearance {
  static const List<CategoryColorOption> colors = <CategoryColorOption>[
    CategoryColorOption(
      storageHex: '#FFB6AD',
      swatchColor: Color(0xFFFFB6AD),
      iconCircleColor: Color(0xFFFFCEC8),
    ),
    CategoryColorOption(
      storageHex: '#ECDD9E',
      swatchColor: Color(0xFFECDD9E),
      iconCircleColor: Color(0xFFF2E8BE),
    ),
    CategoryColorOption(
      storageHex: '#A6E8BB',
      swatchColor: Color(0xFFA6E8BB),
      iconCircleColor: Color(0xFFC3EFD1),
    ),
    CategoryColorOption(
      storageHex: '#B4C9BD',
      swatchColor: Color(0xFFB4C9BD),
      iconCircleColor: Color(0xFFCCDAD2),
    ),
    CategoryColorOption(
      storageHex: '#B4D0FB',
      swatchColor: Color(0xFFB4D0FB),
      iconCircleColor: Color(0xFFCCDFFD),
    ),
    CategoryColorOption(
      storageHex: '#AFC7D5',
      swatchColor: Color(0xFFAFC7D5),
      iconCircleColor: Color(0xFFC9D9E3),
      selectedRingColor: Color(0xFF395E74),
    ),
  ];

  static const List<CategoryIconOption> icons = <CategoryIconOption>[
    CategoryIconOption(key: 'heart', icon: Icons.favorite_border),
    CategoryIconOption(key: 'work', icon: Icons.work_outline),
    CategoryIconOption(key: 'study', icon: Icons.bookmark_border),
    CategoryIconOption(key: 'home', icon: Icons.home_outlined),
    CategoryIconOption(key: 'fitness', icon: Icons.show_chart),
    CategoryIconOption(key: 'social', icon: Icons.groups_outlined),
    CategoryIconOption(key: 'finance', icon: Icons.account_balance_wallet_outlined),
    CategoryIconOption(key: 'hobbies', icon: Icons.palette_outlined),
    CategoryIconOption(key: 'music', icon: Icons.music_note_outlined),
    CategoryIconOption(key: 'photo', icon: Icons.photo_camera_outlined),
    CategoryIconOption(key: 'daytime', icon: Icons.light_mode_outlined),
    CategoryIconOption(key: 'coffee', icon: Icons.coffee_outlined),
  ];

  static CategoryColorOption colorForHex(String? hex) {
    if (hex == null || hex.isEmpty) return colors.first;
    final normalized = hex.toUpperCase();
    for (final CategoryColorOption option in colors) {
      if (option.storageHex.toUpperCase() == normalized) return option;
    }
    return CategoryColorOption(
      storageHex: hex,
      swatchColor: AppColors.parseHexColor(hex) ?? colors.first.swatchColor,
      iconCircleColor:
          AppColors.parseHexColor(hex)?.withValues(alpha: 0.35) ??
              colors.first.iconCircleColor,
    );
  }

  static CategoryIconOption iconForKey(String? key) {
    if (key == null || key.isEmpty) return icons[7];
    for (final CategoryIconOption option in icons) {
      if (option.key == key) return option;
    }
    return icons.first;
  }
}