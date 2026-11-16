import 'package:flutter/material.dart';
import 'package:wsidappp/config/theme/app_colors.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_cubit.dart';

/// Modal bottom sheet for creating a new task category.
class CreateCategorySheet extends StatefulWidget {
  const CreateCategorySheet({
    super.key,
    required this.categoryCubit,
  });

  final CategoryCubit categoryCubit;

  static Future<void> show(BuildContext context, CategoryCubit categoryCubit) {
    final topRadius = context.radius.lg.topLeft;
    return showModalBottomSheet<void>(
      context: context,
      constraints: const BoxConstraints(maxWidth: 600),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: topRadius),
      ),
      builder: (_) => CreateCategorySheet(categoryCubit: categoryCubit),
    );
  }

  @override
  State<CreateCategorySheet> createState() => _CreateCategorySheetState();
}

class _CreateCategorySheetState extends State<CreateCategorySheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  Color _selectedColor = AppColors.categoryPalette.first;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameController.text.trim();
    final hexColor = AppColors.toHexString(_selectedColor);
    widget.categoryCubit.createCategory(name: name, color: hexColor);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 20.0,
        bottom: mediaQuery.viewInsets.bottom + 24.0,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: context.radius.full,
                ),
              ),
            ),
            Text(
              l10n.newCategory,
              style: context.txt.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),

            // Category Name Field
            TextFormField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l10n.categoryName,
                hintText: l10n.categoryHint,
              ),
              validator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.categoryNameRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Color Picker Row
            Text(
              l10n.colorTag,
              style: context.txt.labelLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: AppColors.categoryPalette.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(width: 10),
                itemBuilder: (BuildContext context, int index) {
                  final color = AppColors.categoryPalette[index];
                  final isSelected = color == _selectedColor;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: context.colors.primary,
                                width: 3,
                              )
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 20,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),

            // Submit Button
            FilledButton(
              onPressed: _submit,
              child: Text(l10n.createCategory),
            ),
          ],
        ),
      ),
    );
  }
}
