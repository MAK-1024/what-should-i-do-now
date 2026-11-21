import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wsidappp/config/routes/route_list.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/core/utils/app_motion.dart';
import 'package:wsidappp/features/categories/domain/entities/category.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_cubit.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_state.dart';
import 'package:wsidappp/features/suggestion/presentation/cubit/suggestion_cubit.dart';
import 'package:wsidappp/features/suggestion/presentation/widgets/home_suggestion_page_widgets/cards/pending_task_row.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_cubit.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_state.dart';
import 'package:wsidappp/features/tasks/presentation/task_flow_navigation.dart';

/// "Pending" preview listing the next few pending tasks with a link to the
/// full backlog.
class PendingTasksSection extends StatelessWidget {
  const PendingTasksSection({super.key});

  static const int _maxVisible = 5;

  Future<void> _openDetails(BuildContext context, Task task) async {
    final SuggestionCubit suggestionCubit = context.read<SuggestionCubit>();
    await TaskFlowNavigation.openTaskDetails(context, task: task);
    if (context.mounted) suggestionCubit.checkActiveTask();
  }

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                l10n.pendingTasks,
                style: context.txt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: () => context.go(RouteList.tasks),
              child: Text(l10n.viewAll),
            ),
          ],
        ),
        const SizedBox(height: 8),
        BlocBuilder<TaskListCubit, TaskListState>(
          builder: (BuildContext context, TaskListState state) {
            return state.when(
              initial: () => const _PendingPlaceholder(),
              loading: () => const _PendingPlaceholder(),
              error: (String message) => _PendingMessage(
                message: message,
                actionLabel: l10n.retry,
                onAction: () => context.read<TaskListCubit>().loadTasks(),
              ),
              loaded: (List<Task> tasks, _, _, _, _, _) {
                final List<Task> pending = tasks
                    .where((Task task) => task.status == TaskStatus.pending)
                    .take(_maxVisible)
                    .toList(growable: false);
                if (pending.isEmpty) {
                  return _PendingMessage(message: l10n.noPendingTasksShort);
                }
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: <Widget>[
                      for (int i = 0; i < pending.length; i++) ...<Widget>[
                        if (i > 0) const Divider(height: 1, indent: 40),
                        PendingTaskRow(
                          task: pending[i],
                          categoryName: categoryNames[pending[i].categoryId],
                          onTap: () => _openDetails(context, pending[i]),
                        )
                            .animate()
                            .fadeIn(
                              delay: AppMotion.of(
                                context,
                                AppMotion.staggerStep * i,
                              ),
                              duration: AppMotion.of(context, AppMotion.medium),
                            )
                            .slideY(
                              begin: 0.15,
                              end: 0,
                              duration: AppMotion.of(context, AppMotion.medium),
                              curve: AppMotion.standard,
                            ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _PendingPlaceholder extends StatelessWidget {
  const _PendingPlaceholder();

  @override
  Widget build(BuildContext context) {
    final Widget card = Card(
      child: SizedBox(
        height: 64 * 3,
        width: double.infinity,
        child: ColoredBox(color: context.colors.surfaceContainerHighest),
      ),
    );
    if (!AppMotion.isEnabled(context)) return card;
    return card
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: AppMotion.slow * 3,
          color: context.colors.surface,
        );
  }
}

class _PendingMessage extends StatelessWidget {
  const _PendingMessage({
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
        padding: const EdgeInsets.all(20),
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
