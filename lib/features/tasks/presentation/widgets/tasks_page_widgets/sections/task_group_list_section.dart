import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/core/utils/app_motion.dart';
import 'package:wsidappp/features/categories/domain/entities/category.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_cubit.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_state.dart';
import 'package:wsidappp/core/constants/category_appearance.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_cubit.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_state.dart';
import 'package:wsidappp/shared/widgets/wsid_task_row.dart';
import 'package:wsidappp/features/tasks/presentation/task_flow_navigation.dart';

/// Section header (status + count) and the grouped card of filtered tasks.
class TaskGroupListSection extends StatelessWidget {
  const TaskGroupListSection({
    super.key,
    this.priorityFilter,
    this.durationRange,
  });

  final TaskPriority? priorityFilter;
  final RangeValues? durationRange;

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
          loaded: (_, _, _, _, _, _) {
            final List<Task> visible = state.visibleTasks.where((Task task) {
              if (task.status != TaskStatus.pending) return false;
              if (priorityFilter != null &&
                  task.priority != priorityFilter) {
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
                if (visible.isEmpty)
                  _MessageCard(message: l10n.noTasksMatch)
                else
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
                            categoryColor:
                                CategoryAppearance.colorForHex(
                              categoriesById[visible[i].categoryId]?.color,
                            ).iconCircleColor,
                            categoryIcon:
                                CategoryAppearance.iconForKey(
                              categoriesById[visible[i].categoryId]?.icon,
                            ).icon,
                            variant: WsidTaskRowVariant.defaultRow,
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
          orElse: () => const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      },
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
    final String? label = actionLabel;
    final VoidCallback? action = onAction;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.txt.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            if (label != null && action != null) ...<Widget>[
              const SizedBox(height: 12),
              OutlinedButton(onPressed: action, child: Text(label)),
            ],
          ],
        ),
      ),
    );
  }
}
