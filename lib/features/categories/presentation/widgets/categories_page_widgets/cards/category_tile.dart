import 'package:flutter/material.dart';
import 'package:wsidappp/config/theme/app_colors.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/features/categories/domain/entities/category.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_cubit.dart';

/// Card tile representing a single category with deletion confirmation action.
class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.category,
    required this.categoryCubit,
  });

  final Category category;
  final CategoryCubit categoryCubit;

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = context.l10n;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: dialogContext.radius.lg,
          ),
          title: Text(l10n.deleteCategory),
          content: Text(l10n.deleteCategoryConfirm(category.name)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: dialogContext.colors.error,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await categoryCubit.deleteCategory(category.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = AppColors.parseHexColor(category.color) ?? AppColors.primary;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: context.radius.md,
        side: const BorderSide(color: AppColors.outline),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 4.0,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.folder,
            color: color,
            size: 20,
          ),
        ),
        title: Text(
          category.name,
          style: context.txt.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.delete_outline,
            color: context.colors.error,
          ),
          tooltip: l10n.deleteCategoryTooltip,
          onPressed: () => _confirmDelete(context),
        ),
      ),
    );
  }
}
