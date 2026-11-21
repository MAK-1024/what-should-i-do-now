import 'package:flutter/material.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/constants/category_appearance.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/shared/widgets/brand_surface_card.dart';

/// Live preview card on the add-category form (`337:1958`).
class CategoryPreviewCard extends StatelessWidget {
  const CategoryPreviewCard({
    super.key,
    required this.name,
    required this.color,
    required this.iconKey,
    this.taskCount = 0,
  });

  final String name;
  final CategoryColorOption color;
  final String iconKey;
  final int taskCount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final brand = context.brand;
    final CategoryIconOption icon = CategoryAppearance.iconForKey(iconKey);
    final String displayName = name.trim().isEmpty ? l10n.addCategory : name.trim();

    final Widget previewTile = BrandSurfaceCard(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: context.isLightTheme ? 187 : double.infinity,
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
              displayName,
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
      ),
    );

    if (!context.isLightTheme) {
      return previewTile;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: brand.previewWellFill,
        borderRadius: context.radius.xl,
      ),
      child: Align(child: previewTile),
    );
  }
}