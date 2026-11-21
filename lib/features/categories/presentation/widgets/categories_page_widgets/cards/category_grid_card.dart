import 'package:flutter/material.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/constants/category_appearance.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/features/categories/domain/entities/category.dart';
import 'package:wsidappp/shared/widgets/brand_surface_card.dart';

/// Category tile in the Figma 2-column grid (`332:1566`).
class CategoryGridCard extends StatelessWidget {
  const CategoryGridCard({
    super.key,
    required this.category,
    required this.taskCount,
    this.onLongPress,
  });

  final Category category;
  final int taskCount;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final brand = context.brand;
    final CategoryColorOption color =
        CategoryAppearance.colorForHex(category.color);
    final CategoryIconOption icon =
        CategoryAppearance.iconForKey(category.icon);

    return BrandSurfaceCard(
      onLongPress: onLongPress,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: brand.categoryIconCircle(color.iconCircleColor),
              borderRadius: context.radius.md,
            ),
            child: Icon(icon.icon, size: 24, color: brand.iconOnTint),
          ),
          const SizedBox(height: 12),
          Text(
            category.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.isLightTheme
                ? context.cardTitleStyle
                : context.txt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.taskCount(taskCount),
            style: context.isLightTheme
                ? context.metaTextStyle
                : context.txt.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
          ),
        ],
      ),
    );
  }
}