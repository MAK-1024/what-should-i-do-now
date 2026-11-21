import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wsidappp/config/routes/route_list.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/features/categories/domain/entities/category.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_cubit.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_state.dart';
import 'package:wsidappp/features/categories/presentation/pages/add_category_page.dart';
import 'package:wsidappp/features/categories/presentation/widgets/categories_page_widgets/cards/category_add_grid_card.dart';
import 'package:wsidappp/features/categories/presentation/widgets/categories_page_widgets/cards/category_grid_card.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_cubit.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_state.dart';
import 'package:wsidappp/shared/widgets/custom_app_bar.dart';

/// Categories grid (`332:1566`) with add-category flow (`337:1912`).
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
    context.read<TaskListCubit>().loadTasks();
  }

  void _openAddCategory(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider<CategoryCubit>.value(
          value: context.read<CategoryCubit>(),
          child: const AddCategoryPage(),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Category category,
    CategoryCubit cubit,
  ) async {
    final l10n = context.l10n;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: dialogContext.radius.lg),
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
    if (confirmed == true) await cubit.deleteCategory(category.id);
  }

  int _taskCountForCategory(String categoryId, List<Task> tasks) =>
      tasks.where((Task t) => t.categoryId == categoryId).length;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<CategoryCubit>();

    return Scaffold(
      backgroundColor: context.brand.pageBackground,
      appBar: WsidAppBar.main(
        title: l10n.categories,
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
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: (List<Category> categories, _) {
              return BlocBuilder<TaskListCubit, TaskListState>(
                builder: (BuildContext context, TaskListState taskState) {
                  final List<Task> tasks = taskState.maybeWhen(
                    loaded: (List<Task> items, _, _, _, _, _) => items,
                    orElse: () => const <Task>[],
                  );
                  final int totalTasks = tasks.length;

                  return RefreshIndicator(
                    onRefresh: () async {
                      final TaskListCubit taskListCubit =
                          context.read<TaskListCubit>();
                      await cubit.loadCategories();
                      await taskListCubit.loadTasks();
                    },
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: <Widget>[
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                          sliver: SliverToBoxAdapter(
                            child: Text(
                              l10n.categoriesSummary(
                                categories.length,
                                totalTasks,
                              ),
                              style: context.metaTextStyle.copyWith(
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.92,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                                if (index < categories.length) {
                                  final Category category = categories[index];
                                  return CategoryGridCard(
                                    category: category,
                                    taskCount: _taskCountForCategory(
                                      category.id,
                                      tasks,
                                    ),
                                    onLongPress: () => _confirmDelete(
                                      context,
                                      category,
                                      cubit,
                                    ),
                                  );
                                }
                                return CategoryAddGridCard(
                                  onTap: () => _openAddCategory(context),
                                );
                              },
                              childCount: categories.length + 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            error: (String message) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.error_outline, size: 48, color: context.colors.error),
                  const SizedBox(height: 12),
                  Text(message, style: context.txt.titleMedium),
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