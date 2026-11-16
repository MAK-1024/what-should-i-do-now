import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wsidappp/config/theme/app_colors.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_cubit.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_state.dart';
import 'package:wsidappp/features/suggestion/presentation/cubit/suggestion_cubit.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';
import 'package:wsidappp/features/tasks/presentation/widgets/tasks_page_widgets/shared/task_status_badge.dart';

/// Card displayed when the user is actively working on a committed task.
class ActiveTaskCard extends StatelessWidget {
  const ActiveTaskCard({
    super.key,
    required this.task,
  });

  final Task task;

  Future<void> _openLink(BuildContext context, String urlString) async {
    final Uri? uri = Uri.tryParse(urlString);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${context.l10n.couldNotOpenLink}: $urlString'),
          backgroundColor: context.colors.error,
        ),
      );
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return AppColors.error;
      case TaskPriority.medium:
        return AppColors.accent;
      case TaskPriority.low:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<SuggestionCubit>();

    final String? categoryName = context.select<CategoryCubit, String?>((c) {
      return c.state.maybeWhen(
        loaded: (categories, _) {
          for (final cat in categories) {
            if (cat.id == task.categoryId) return cat.name;
          }
          return null;
        },
        orElse: () => null,
      );
    });

    final priorityColor = _getPriorityColor(task.priority);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: context.radius.lg,
        side: BorderSide(
          color: context.colors.primary.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header Row: IN PROGRESS badge + priority
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: context.radius.full,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(
                        Icons.play_arrow,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.inProgress.toUpperCase(),
                        style: context.txt.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 3.0,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.15),
                    borderRadius: context.radius.sm,
                  ),
                  child: Text(
                    task.priority.label(l10n).toUpperCase(),
                    style: context.txt.labelSmall?.copyWith(
                      color: priorityColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Task Title
            Text(
              task.title,
              style: context.txt.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            if (task.description != null && task.description!.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                task.description!,
                style: context.txt.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Metadata Row: Category & Duration
            Wrap(
              spacing: 12.0,
              runSpacing: 8.0,
              children: <Widget>[
                if (categoryName != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(
                        Icons.folder_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        categoryName,
                        style: context.txt.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                if (task.estimatedDuration != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(
                        Icons.schedule_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.minutesShort(task.estimatedDuration!),
                        style: context.txt.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                if (task.link != null && task.link!.isNotEmpty)
                  InkWell(
                    onTap: () => _openLink(context, task.link!),
                    borderRadius: context.radius.sm,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.open_in_new,
                          size: 16,
                          color: context.colors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.openLink,
                          style: context.txt.bodySmall?.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(l10n.markCompleted),
                    onPressed: () => cubit.completeTask(task.id),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.undo),
                  label: Text(l10n.returnToPending),
                  onPressed: () => cubit.returnToPool(task.id),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.1, end: 0);
  }
}
