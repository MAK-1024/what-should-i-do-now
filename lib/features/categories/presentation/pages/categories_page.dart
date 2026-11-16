import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wsidappp/config/theme/app_colors.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/features/categories/domain/entities/category.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_cubit.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_state.dart';
import 'package:wsidappp/features/categories/presentation/widgets/categories_page_widgets/cards/category_tile.dart';
import 'package:wsidappp/features/categories/presentation/widgets/categories_page_widgets/dialogs/create_category_sheet.dart';
import 'package:wsidappp/shared/widgets/custom_app_bar.dart';

/// Categories management page providing category creation, listing, and deletion.
class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  @override
  void initState() {
    super.initState();
    context.read<CategoryCubit>().loadCategories();
  }

  @override
  Widget build(BuildContext context) => const _CategoriesView();
}

class _CategoriesView extends StatelessWidget {
  const _CategoriesView();

  void _openCreateSheet(BuildContext context) {
    final cubit = context.read<CategoryCubit>();
    CreateCategorySheet.show(context, cubit);
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.folder_open_outlined,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noCategoriesTitle,
              style: context.txt.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noCategoriesBody,
              textAlign: TextAlign.center,
              style: context.txt.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.add),
              label: Text(l10n.addCategory),
              onPressed: () => _openCreateSheet(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<CategoryCubit>();

    return Scaffold(
      appBar: CustomAppBar(
        title: l10n.categories,
        showBackButton: false,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.addCategory,
            onPressed: () => _openCreateSheet(context),
          ),
        ],
      ),
      body: BlocConsumer<CategoryCubit, CategoryState>(
        listener: (BuildContext context, CategoryState state) {
          state.whenOrNull(
            error: (String message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: context.colors.error,
                ),
              );
            },
          );
        },
        builder: (BuildContext context, CategoryState state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            loaded: (List<Category> categories, _) {
              if (categories.isEmpty) {
                return _buildEmptyState(context);
              }
              return RefreshIndicator(
                onRefresh: () => cubit.loadCategories(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  itemCount: categories.length,
                  itemBuilder: (BuildContext context, int index) {
                    return CategoryTile(
                      category: categories[index],
                      categoryCubit: cubit,
                    );
                  },
                ),
              );
            },
            error: (String message) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: context.colors.error,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    style: context.txt.titleMedium?.copyWith(
                      color: context.colors.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => cubit.loadCategories(),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
