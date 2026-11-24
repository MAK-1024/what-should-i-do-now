import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/constants/category_appearance.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/features/categories/domain/entities/category.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_cubit.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_state.dart';
import 'package:wsidappp/features/suggestion/presentation/cubit/suggestion_cubit.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_cubit.dart';
import 'package:wsidappp/features/tasks/presentation/task_flow_navigation.dart';
import 'package:wsidappp/shared/widgets/task_meta_row.dart';
import 'package:wsidappp/shared/widgets/wsid_button.dart';
import 'package:wsidappp/shared/widgets/wsid_card_container.dart';
import 'package:wsidappp/shared/widgets/wsid_status_badge.dart';

/// Card displayed under the decider picker when a task is in progress.
class ActiveTaskCard extends StatelessWidget {
  const ActiveTaskCard({
    super.key,
    required this.task,
  });

  final Task task;

  Future<void> _markCompleted(BuildContext context) async {
    final cubit = context.read<TaskListCubit>();
    await cubit.changeTaskStatus(task, TaskStatus.completed);
    if (context.mounted) {
      await context.read<SuggestionCubit>().checkActiveTask();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final Category? category = context.select<CategoryCubit, Category?>((c) {
      return c.state.maybeWhen(
        loaded: (categories, _) {
          for (final cat in categories) {
            if (cat.id == task.categoryId) return cat;
          }
          return null;
        },
        orElse: () => null,
      );
    });

    final categoryName = category?.name ?? l10n.uncategorized;
    final categoryColor = CategoryAppearance.colorForHex(category?.color).iconCircleColor;
    final categoryIcon = CategoryAppearance.iconForKey(category?.icon).icon;

    return WsidCardContainer(
      onTap: () => TaskFlowNavigation.openTaskDetails(context, task: task),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header: Status Badge + tap hint
          Row(
            children: <Widget>[
              WsidStatusBadge(
                label: l10n.inProgress,
                color: context.colors.primary,
                icon: Icons.play_arrow_rounded,
                variant: WsidStatusBadgeVariant.inProgress,
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right_rounded,
                color: context.brand.mutedText,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Task Title
          Text(
            task.title,
            style: context.typo.h3Bold.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: context.isLightTheme
                  ? context.colors.primary
                  : context.brand.headlineText,
            ),
          ),

          if (task.description != null && task.description!.isNotEmpty) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              task.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.screenSubtitleStyle.copyWith(
                fontSize: 14,
                color: context.brand.bodyText,
              ),
            ),
          ],
          const SizedBox(height: 14),

          // Metadata + Done button Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: TaskMetaRow(
                  categoryName: categoryName,
                  categoryColor: categoryColor,
                  categoryIcon: categoryIcon,
                  estimatedMinutes: task.estimatedDuration,
                ),
              ),
              const SizedBox(width: 12),
              WsidButton(
                onPressed: () => _markCompleted(context),
                label: l10n.done,
                icon: Icons.check_rounded,
                variant: WsidButtonVariant.primary,
                size: WsidButtonSize.small,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.08, end: 0);
  }
}
