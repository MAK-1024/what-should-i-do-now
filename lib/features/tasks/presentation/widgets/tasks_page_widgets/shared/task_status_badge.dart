import 'package:flutter/material.dart';
import 'package:wsidappp/config/theme/app_colors.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';
import 'package:wsidappp/shared/widgets/wsid_status_badge.dart';

extension TaskStatusPresentation on TaskStatus {
  String label(AppLocalizations l10n) => switch (this) {
        TaskStatus.pending || TaskStatus.archived => l10n.pending,
        TaskStatus.inProgress => l10n.inProgress,
        TaskStatus.completed => l10n.completed,
      };

  Color color(BuildContext context) => switch (this) {
        TaskStatus.pending || TaskStatus.archived => context.colors.primary,
        TaskStatus.inProgress => context.colors.tertiary,
        TaskStatus.completed => AppColors.success,
      };
}

extension TaskPriorityPresentation on TaskPriority {
  String label(AppLocalizations l10n) => switch (this) {
        TaskPriority.high => l10n.priorityHigh,
        TaskPriority.medium => l10n.priorityMedium,
        TaskPriority.low => l10n.priorityLow,
      };

  Color color(BuildContext context) => switch (this) {
        TaskPriority.high => context.colors.error,
        TaskPriority.medium => context.colors.tertiary,
        TaskPriority.low => context.colors.primary,
      };

  String chipLabel(AppLocalizations l10n) => switch (this) {
        TaskPriority.high => l10n.chipPriorityHigh,
        TaskPriority.medium => l10n.chipPriorityMedium,
        TaskPriority.low => l10n.chipPriorityLow,
      };

  Color detailTint(BuildContext context) {
    final brand = context.brand;
    return switch (this) {
      TaskPriority.high => brand.priorityHighTint,
      TaskPriority.medium => brand.priorityMediumTint,
      TaskPriority.low => brand.priorityLowTint,
    };
  }
}

/// Small colored dot reflecting a task's [status].
class TaskStatusDot extends StatelessWidget {
  const TaskStatusDot({super.key, required this.status});

  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: status.color(context),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Tinted pill showing a localized task [status].
class TaskStatusBadge extends StatelessWidget {
  const TaskStatusBadge({super.key, required this.status});

  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    return WsidStatusBadge(
      label: status.label(context.l10n),
      color: status.color(context),
      variant: switch (status) {
        TaskStatus.pending => WsidStatusBadgeVariant.pending,
        TaskStatus.inProgress => WsidStatusBadgeVariant.inProgress,
        TaskStatus.completed => WsidStatusBadgeVariant.completed,
        TaskStatus.archived => WsidStatusBadgeVariant.archived,
      },
    );
  }
}
