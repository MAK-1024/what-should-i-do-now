import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/core/utils/app_motion.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_cubit.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_state.dart';
import 'package:wsidappp/features/tasks/presentation/widgets/tasks_page_widgets/shared/task_status_badge.dart';

/// Three-segment pill control switching between task statuses.
class TaskStatusSegmentedControl extends StatelessWidget {
  const TaskStatusSegmentedControl({super.key});

  static const List<TaskStatus> _segments = <TaskStatus>[
    TaskStatus.pending,
    TaskStatus.inProgress,
    TaskStatus.completed,
  ];

  static const List<AlignmentDirectional> _alignments = <AlignmentDirectional>[
    AlignmentDirectional.centerStart,
    AlignmentDirectional.center,
    AlignmentDirectional.centerEnd,
  ];

  @override
  Widget build(BuildContext context) {
    final TaskStatus? selected = context.select<TaskListCubit, TaskStatus?>(
      (TaskListCubit cubit) => cubit.state.mapOrNull(
        loaded: (l) => l.filterStatus,
      ) ?? TaskStatus.pending,
    );
    final int selectedIndex =
        _segments.indexOf(selected ?? TaskStatus.pending).clamp(0, 2);

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: context.radius.full,
      ),
      child: Stack(
        children: <Widget>[
          AnimatedAlign(
            alignment: _alignments[selectedIndex],
            duration: AppMotion.of(context, AppMotion.medium),
            curve: AppMotion.standard,
            child: FractionallySizedBox(
              widthFactor: 1 / _segments.length,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: context.radius.full,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: context.colors.shadow.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: <Widget>[
              for (int i = 0; i < _segments.length; i++)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: i == selectedIndex,
                    child: InkWell(
                      borderRadius: context.radius.full,
                      onTap: () => context
                          .read<TaskListCubit>()
                          .setStatusFilter(_segments[i]),
                      child: Center(
                        child: Text(
                          _segments[i].label(context.l10n),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.txt.labelLarge?.copyWith(
                            fontWeight: i == selectedIndex
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: i == selectedIndex
                                ? context.colors.onSurface
                                : context.colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
