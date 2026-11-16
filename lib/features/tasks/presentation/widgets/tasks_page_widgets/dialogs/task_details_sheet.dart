import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/core/services/external_link_launcher.dart';
import 'package:wsidappp/features/categories/domain/entities/category.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_cubit.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_state.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_cubit.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_state.dart';
import 'package:wsidappp/features/tasks/presentation/widgets/tasks_page_widgets/dialogs/edit_task_sheet.dart';
import 'package:wsidappp/features/tasks/presentation/widgets/tasks_page_widgets/shared/task_status_badge.dart';

/// Interactive task details: metadata, saved link, notes, status transitions,
/// edit and delete. Reflects live updates from [taskListCubit].
class TaskDetailsSheet extends StatelessWidget {
  const TaskDetailsSheet({
    super.key,
    required this.task,
    required this.taskListCubit,
    required this.categoryCubit,
    this.onTaskChanged,
  });

  final Task task;
  final TaskListCubit taskListCubit;
  final CategoryCubit categoryCubit;

  /// Invoked after a status change or deletion succeeds.
  final VoidCallback? onTaskChanged;

  static Future<void> show(
    BuildContext context, {
    required Task task,
    required TaskListCubit taskListCubit,
    required CategoryCubit categoryCubit,
    VoidCallback? onTaskChanged,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      constraints: const BoxConstraints(maxWidth: 600),
      isScrollControlled: true,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: context.radius.lg.topLeft),
      ),
      builder: (_) => TaskDetailsSheet(
        task: task,
        taskListCubit: taskListCubit,
        categoryCubit: categoryCubit,
        onTaskChanged: onTaskChanged,
      ),
    );
  }

  String? _categoryName(String categoryId) => categoryCubit.state.maybeWhen(
        loaded: (List<Category> categories, _) {
          for (final Category category in categories) {
            if (category.id == categoryId) return category.name;
          }
          return null;
        },
        orElse: () => null,
      );

  Future<void> _changeStatus(
    BuildContext context,
    Task current,
    TaskStatus newStatus,
  ) async {
    Navigator.of(context).pop();
    final bool succeeded =
        await taskListCubit.changeTaskStatus(current, newStatus);
    if (succeeded) onTaskChanged?.call();
  }

  Future<void> _confirmDelete(BuildContext context, Task current) async {
    final l10n = context.l10n;
    final NavigatorState navigator = Navigator.of(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(l10n.deleteTask),
        content: Text(l10n.deleteTaskConfirm(current.title)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: dialogContext.colors.error,
              foregroundColor: dialogContext.colors.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    navigator.pop();
    final bool succeeded = await taskListCubit.deleteTask(current.id);
    if (succeeded) onTaskChanged?.call();
  }

  Future<void> _openLink(BuildContext context, String url) async {
    final messenger = ScaffoldMessenger.of(context);
    final errorText = context.l10n.couldNotOpenLink;
    final errorColor = context.colors.error;
    if (!await openExternalLink(url)) {
      messenger.showSnackBar(
        SnackBar(content: Text(errorText), backgroundColor: errorColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskListCubit, TaskListState>(
      bloc: taskListCubit,
      builder: (BuildContext context, TaskListState state) {
        final Task current = state.taskById(task.id) ?? task;
        return _buildContent(context, current);
      },
    );
  }

  Widget _buildContent(BuildContext context, Task current) {
    final l10n = context.l10n;
    final String? link = current.link;
    final String? notes = current.description;
    final int? minutes = current.estimatedDuration;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          0,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _categoryName(current.categoryId) ?? l10n.uncategorized,
                        style: context.txt.labelLarge?.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        current.title,
                        style: context.txt.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filledTonal(
                  tooltip: l10n.close,
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _MetaPill(
                  icon: Icons.flag_outlined,
                  label: current.priority.label(l10n),
                  color: current.priority.color(context),
                ),
                if (minutes != null)
                  _MetaPill(
                    icon: Icons.schedule_outlined,
                    label: l10n.minutesShort(minutes),
                    color: context.colors.tertiary,
                  ),
              ],
            ),
            if (link != null && link.isNotEmpty) ...<Widget>[
              const SizedBox(height: 20),
              _InfoBox(
                label: l10n.savedLink,
                onTap: () => _openLink(context, link),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.link, color: context.colors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        link,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.txt.bodyMedium?.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.open_in_new,
                      size: 18,
                      color: context.colors.primary,
                    ),
                  ],
                ),
              ),
            ],
            if (notes != null && notes.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              _InfoBox(
                label: l10n.notes,
                child: Text(notes, style: context.txt.bodyMedium),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: <Widget>[
                Text(
                  l10n.status,
                  style: context.txt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 10),
                TaskStatusBadge(status: current.status),
              ],
            ),
            const SizedBox(height: 8),
            ..._buildStatusActions(context, current),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(l10n.editTask),
                    onPressed: () => EditTaskSheet.show(
                      context,
                      task: current,
                      taskListCubit: taskListCubit,
                      categoryCubit: categoryCubit,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: context.colors.error,
                    minimumSize: const Size(44, 48),
                  ),
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l10n.delete),
                  onPressed: () => _confirmDelete(context, current),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStatusActions(BuildContext context, Task current) {
    final l10n = context.l10n;
    const Size fullWidth = Size.fromHeight(48);

    Widget helper(String text) => Text(
          text,
          style: context.txt.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        );

    switch (current.status) {
      case TaskStatus.pending:
      case TaskStatus.archived:
        return <Widget>[
          helper(l10n.statusHelperPending),
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(minimumSize: fullWidth),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(l10n.startTask),
            onPressed: () =>
                _changeStatus(context, current, TaskStatus.inProgress),
          ),
        ];
      case TaskStatus.inProgress:
        return <Widget>[
          helper(l10n.statusHelperInProgress),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(minimumSize: fullWidth),
                  onPressed: () =>
                      _changeStatus(context, current, TaskStatus.pending),
                  child: Text(l10n.returnToPending, textAlign: TextAlign.center),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(minimumSize: fullWidth),
                  icon: const Icon(Icons.check),
                  label: Text(l10n.markCompleted, textAlign: TextAlign.center),
                  onPressed: () =>
                      _changeStatus(context, current, TaskStatus.completed),
                ),
              ),
            ],
          ),
        ];
      case TaskStatus.completed:
        return <Widget>[
          helper(l10n.statusHelperCompleted),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(minimumSize: fullWidth),
            icon: const Icon(Icons.replay),
            label: Text(l10n.reopenTask),
            onPressed: () => _changeStatus(context, current, TaskStatus.pending),
          ),
        ];
    }
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: context.radius.full,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: context.txt.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.label, required this.child, this.onTap});

  final String label;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surfaceContainerHighest,
      borderRadius: context.radius.md,
      child: InkWell(
        borderRadius: context.radius.md,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: context.txt.labelSmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
