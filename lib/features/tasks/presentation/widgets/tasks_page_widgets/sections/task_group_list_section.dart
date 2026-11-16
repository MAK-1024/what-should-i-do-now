import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/core/utils/app_motion.dart';
import 'package:wsidappp/features/categories/domain/entities/category.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_cubit.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_state.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_cubit.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_state.dart';
import 'package:wsidappp/features/tasks/presentation/widgets/tasks_page_widgets/cards/task_list_tile.dart';
import 'package:wsidappp/features/tasks/presentation/widgets/tasks_page_widgets/dialogs/task_details_sheet.dart';
import 'package:wsidappp/features/tasks/presentation/widgets/tasks_page_widgets/shared/task_status_badge.dart';

/// Section header (status + count) and the grouped card of filtered tasks.
class TaskGroupListSection extends StatelessWidget {
  const TaskGroupListSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final Map<String, String> categoryNames =
        context.select<CategoryCubit, Map<String, String>>(
      (CategoryCubit cubit) => cubit.state.maybeWhen(
        loaded: (List<Category> categories, _) => <String, String>{
          for (final Category category in categories) category.id: category.name,
        },
        orElse: () => const <String, String>{},
      ),
    );

    return BlocBuilder<TaskListCubit, TaskListState>(
      builder: (BuildContext context, TaskListState state) {
        return state.maybeWhen(
          loaded: (_, _, TaskStatus? filterStatus, _, _, _) {
            final List<Task> visible = state.visibleTasks;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        filterStatus?.label(l10n) ?? l10n.all,
                        style: context.txt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      l10n.taskCount(visible.length),
                      style: context.txt.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
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
                          TaskListTile(
                            key: ValueKey<String>(visible[i].id),
                            task: visible[i],
                            categoryName: categoryNames[visible[i].categoryId],
                            onTap: () => TaskDetailsSheet.show(
                              context,
                              task: visible[i],
                              taskListCubit: context.read<TaskListCubit>(),
                              categoryCubit: context.read<CategoryCubit>(),
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
