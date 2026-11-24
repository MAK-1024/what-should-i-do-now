import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/constants/app_assets.dart';
import 'package:wsidappp/core/constants/category_appearance.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/core/utils/app_motion.dart';
import 'package:wsidappp/features/categories/domain/entities/category.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_cubit.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_state.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_cubit.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_state.dart';
import 'package:wsidappp/features/tasks/presentation/task_flow_navigation.dart';
import 'package:wsidappp/shared/widgets/mascot_state_view.dart';
import 'package:wsidappp/shared/widgets/shimmer/wsid_shimmer.dart';
import 'package:wsidappp/shared/widgets/wsid_task_row.dart';

/// Section header (status + count) and the grouped card of filtered tasks.
class TaskGroupListSection extends StatelessWidget {
  const TaskGroupListSection({
    super.key,
    this.targetStatus = TaskStatus.pending,
    this.priorityFilter,
    this.durationRange,
    this.onResetFilters,
  });

  final TaskStatus targetStatus;
  final TaskPriority? priorityFilter;
  final RangeValues? durationRange;
  final VoidCallback? onResetFilters;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final Map<String, Category> categoriesById =
        context.select<CategoryCubit, Map<String, Category>>(
      (CategoryCubit cubit) => cubit.state.maybeWhen(
        loaded: (List<Category> categories, _) => <String, Category>{
          for (final Category category in categories) category.id: category,
        },
        orElse: () => const <String, Category>{},
      ),
    );

    return BlocBuilder<TaskListCubit, TaskListState>(
      builder: (BuildContext context, TaskListState state) {
        return state.maybeWhen(
          loaded: (tasks, searchQuery, filterStatus, filterCategoryId, _, _) {
            final List<Task> visible = state.visibleTasks.where((Task task) {
              if (task.status != targetStatus) return false;
              if (priorityFilter != null && task.priority != priorityFilter) {
                return false;
              }
              if (durationRange != null &&
                  (task.estimatedDuration == null ||
                      task.estimatedDuration! < durationRange!.start ||
                      task.estimatedDuration! > durationRange!.end)) {
                return false;
              }
              return true;
            }).toList(growable: false);

            final bool isFiltered = searchQuery.trim().isNotEmpty ||
                filterCategoryId != null ||
                priorityFilter != null ||
                durationRange != null;

            void clearFilters() {
              if (onResetFilters != null) {
                onResetFilters!();
              } else {
                context.read<TaskListCubit>().setSearchQuery('');
                context.read<TaskListCubit>().setCategoryFilter(null);
              }
            }

            if (visible.isEmpty) {
              if (targetStatus == TaskStatus.completed) {
                return MascotStateView(
                  imagePath: AppAssets.star,
                  title: isFiltered ? l10n.noTasksMatch : l10n.noCompletedTasks,
                  subtitle: isFiltered
                      ? l10n.clearSearch
                      : l10n.noCompletedTasksSubtitle,
                  actionLabel: isFiltered ? l10n.clearSearch : null,
                  actionIcon: isFiltered ? Icons.clear : null,
                  onAction: isFiltered ? clearFilters : null,
                );
              }

              return _EmptyTasksView(
                isFiltered: isFiltered,
                onAddTask: () => TaskFlowNavigation.openAddTask(context),
                onClearFilters: clearFilters,
              );
            }

            final isCompleted = targetStatus == TaskStatus.completed;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  l10n.taskCount(visible.length),
                  style: context.txt.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: <Widget>[
                      for (int i = 0; i < visible.length; i++) ...<Widget>[
                        if (i > 0) const Divider(height: 1, indent: 40),
                        WsidTaskRow(
                          key: ValueKey<String>(visible[i].id),
                          title: visible[i].title,
                          categoryName: categoriesById[visible[i].categoryId]
                                  ?.name ??
                              l10n.uncategorized,
                          categoryColor: CategoryAppearance.colorForHex(
                            categoriesById[visible[i].categoryId]?.color,
                          ).iconCircleColor,
                          categoryIcon: CategoryAppearance.iconForKey(
                            categoriesById[visible[i].categoryId]?.icon,
                          ).icon,
                          variant: isCompleted
                              ? WsidTaskRowVariant.completed
                              : WsidTaskRowVariant.defaultRow,
                          onTap: () => TaskFlowNavigation.openTaskDetails(
                            context,
                            task: visible[i],
                          ),
                        ).animate().fadeIn(
                              delay: AppMotion.of(
                                context,
                                AppMotion.staggerStep * i.clamp(0, 8),
                              ),
                              duration:
                                  AppMotion.of(context, AppMotion.medium),
                            ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
          error: (String message) => _MessageCard(
            message: message,
            actionLabel: l10n.retry,
            onAction: () => context.read<TaskListCubit>().loadTasks(),
          ),
          orElse: () => const WsidShimmerPageLoader(),
        );
      },
    );
  }
}

class _EmptyTasksView extends StatelessWidget {
  const _EmptyTasksView({
    required this.isFiltered,
    required this.onAddTask,
    required this.onClearFilters,
  });

  final bool isFiltered;
  final VoidCallback onAddTask;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return MascotStateView.empty(
      title: isFiltered ? l10n.noTasksMatch : l10n.noTasksYet,
      subtitle: isFiltered ? l10n.clearSearch : l10n.noTasksYetSubtitle,
      actionLabel: isFiltered ? l10n.clearSearch : l10n.addATask,
      actionIcon: isFiltered ? Icons.clear : Icons.add,
      onAction: isFiltered ? onClearFilters : onAddTask,
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Text(message, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: 8),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
