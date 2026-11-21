import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/constants/category_appearance.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/features/auth/presentation/widgets/auth_page_widgets/shared/auth_text_field.dart';
import 'package:wsidappp/features/categories/domain/entities/category.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_cubit.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_state.dart';
import 'package:wsidappp/features/categories/presentation/widgets/categories_page_widgets/cards/category_preview_card.dart';
import 'package:wsidappp/shared/widgets/custom_app_bar.dart';

/// Full-screen create category form (`337:1912`).
class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  CategoryColorOption _selectedColor = CategoryAppearance.colors[5];
  String _selectedIcon = CategoryAppearance.icons[7].key;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final cubit = context.read<CategoryCubit>();
    await cubit.createCategory(
      name: _nameController.text.trim(),
      color: _selectedColor.storageHex,
      icon: _selectedIcon,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    cubit.state.maybeWhen(
      loaded: (List<Category> categories, Category? selected) =>
          Navigator.of(context).pop(),
      error: (String message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: context.colors.error,
          ),
        );
      },
      orElse: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final brand = context.brand;

    return Scaffold(
      backgroundColor: brand.pageBackground,
      appBar: CustomAppBar(
        title: l10n.addCategory,
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: SizedBox(
            height: 48,
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSaving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: brand.primaryAction,
                foregroundColor: brand.onPrimaryAction,
                shape: RoundedRectangleBorder(borderRadius: context.radius.lg),
                textStyle: context.typo.title1Bold,
              ),
              child: _isSaving
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: brand.onPrimaryAction,
                      ),
                    )
                  : Text(l10n.saveCategory),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: <Widget>[
            AuthTextField(
              controller: _nameController,
              label: l10n.categoryNameLabel,
              hintText: l10n.categoryNamePlaceholder,
              prefixIcon: Icons.dashboard_customize_outlined,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _save(),
              validator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.categoryNameRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Text(
              l10n.chooseAColor,
              style: context.typo.bodyBold.copyWith(color: brand.sectionLabel),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: CategoryAppearance.colors.map((CategoryColorOption color) {
                final bool selected = color.storageHex == _selectedColor.storageHex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(
                              color: color.selectedRingColor ?? brand.primaryAction,
                              width: 2,
                            )
                          : null,
                    ),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.swatchColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.chooseAnIcon,
              style: context.typo.bodyBold.copyWith(color: brand.sectionLabel),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: CategoryAppearance.icons.map((CategoryIconOption option) {
                final bool selected = option.key == _selectedIcon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = option.key),
                  child: Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? brand.iconPickerSelectedFill
                          : brand.iconPickerUnselectedFill,
                      borderRadius: BorderRadius.circular(14),
                      border: selected
                          ? Border.all(color: brand.primaryAction, width: 1.5)
                          : null,
                    ),
                    child: Icon(option.icon, size: 26, color: brand.iconOnTint),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.preview,
              style: context.typo.bodyBold.copyWith(color: brand.sectionLabel),
            ),
            const SizedBox(height: 10),
            AnimatedBuilder(
              animation: _nameController,
              builder: (BuildContext context, Widget? child) {
                return CategoryPreviewCard(
                  name: _nameController.text,
                  color: _selectedColor,
                  iconKey: _selectedIcon,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}