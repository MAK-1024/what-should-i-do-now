import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/constants/task_duration_presets.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_state.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_cubit.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_cubit.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_state.dart';
import 'package:wsidappp/features/tasks/presentation/task_flow_navigation.dart';
import 'package:wsidappp/features/tasks/presentation/widgets/tasks_page_widgets/sections/task_category_filter_chips.dart';
import 'package:wsidappp/features/tasks/presentation/widgets/tasks_page_widgets/sections/task_group_list_section.dart';
import 'package:wsidappp/features/tasks/presentation/widgets/tasks_page_widgets/sections/task_search_bar.dart';
import 'package:wsidappp/features/tasks/presentation/widgets/tasks_page_widgets/shared/task_status_badge.dart';
import 'package:wsidappp/shared/widgets/wsid_icon_button.dart';
import 'package:wsidappp/shared/widgets/wsid_tab_bar.dart';
import 'package:wsidappp/shared/widgets/wsid_task_banner.dart';
import 'package:wsidappp/shared/widgets/custom_app_bar.dart';

/// Tasks backlog divided into 'to do' (pending) and 'done' (completed) tabs.
class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TaskFilters extends StatelessWidget {
  const _TaskFilters({
    required this.priority,
    required this.durationRange,
    required this.onPriorityChanged,
    required this.onDurationChanged,
  });

  final TaskPriority? priority;
  final RangeValues? durationRange;
  final ValueChanged<TaskPriority?> onPriorityChanged;
  final ValueChanged<RangeValues?> onDurationChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l10n.priority, style: context.txt.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            ChoiceChip(
              label: Text(l10n.all),
              selected: priority == null,
              onSelected: (_) => onPriorityChanged(null),
            ),
            for (final TaskPriority value in TaskPriority.values)
              ChoiceChip(
                label: Text(value.label(l10n)),
                selected: priority == value,
                onSelected: (_) => onPriorityChanged(value),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(l10n.timeNeeded, style: context.txt.titleSmall),
        const SizedBox(height: 8),
        RangeSlider(
          values:
              durationRange ??
              RangeValues(
                TaskDurationPresets.minutes.first.toDouble(),
                TaskDurationPresets.minutes.last.toDouble(),
              ),
          min: TaskDurationPresets.minutes.first.toDouble(),
          max: TaskDurationPresets.minutes.last.toDouble(),
          divisions: 11,
          labels: RangeLabels(
            '${durationRange?.start.round() ?? 5} min',
            '${durationRange?.end.round() ?? 60} min',
          ),
          onChanged: (RangeValues value) => onDurationChanged(value),
        ),
        Text(
          durationRange == null
              ? l10n.all
              : '${durationRange!.start.round()}-${durationRange!.end.round()} min',
          style: context.txt.bodySmall,
        ),
      ],
    );
  }
}

class _TasksPageState extends State<TasksPage> {
  static const EdgeInsets _hPadding = EdgeInsets.symmetric(horizontal: 20);
  int _selectedTabIndex = 0;
  bool _showFilters = false;
  TaskPriority? _priorityFilter;
  RangeValues? _durationRange;

  @override
  void initState() {
    super.initState();
    _resetFilters();
    _refresh();
  }

  void _resetFilters() {
    _priorityFilter = null;
    _durationRange = null;
    _showFilters = false;
    final TaskListCubit cubit = context.read<TaskListCubit>();
    cubit.setStatusFilter(null);
    cubit.setCategoryFilter(null);
    cubit.setSearchQuery('');
  }

  Future<void> _refresh() => Future.wait(<Future<void>>[
    context.read<TaskListCubit>().loadTasks(),
    context.read<CategoryCubit>().loadCategories(),
  ]);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final Task? activeTask = context.select<TaskListCubit, Task?>((
      TaskListCubit cubit,
    ) {
      return cubit.state.mapOrNull(
        loaded: (l) {
          for (final Task task in l.tasks) {
            if (task.status == TaskStatus.inProgress) return task;
          }
          return null;
        },
      );
    });

    final Map<String, String> categoryNames = context
        .select<CategoryCubit, Map<String, String>>((CategoryCubit cubit) {
          return cubit.state.maybeWhen(
            loaded: (categories, _) => <String, String>{
              for (final category in categories) category.id: category.name,
            },
            orElse: () => const <String, String>{},
          );
        });

    final isToDoTab = _selectedTabIndex == 0;

    return Scaffold(
      appBar: WsidAppBar.main(title: l10n.myTasks),
      body: BlocListener<TaskListCubit, TaskListState>(
        listenWhen: (_, TaskListState current) =>
            current.mapOrNull(loaded: (l) => l.actionErrorMessage) != null,
        listener: (BuildContext context, TaskListState state) {
          final String? message = state.mapOrNull(
            loaded: (l) => l.actionErrorMessage,
          );
          if (message == null) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: context.colors.error,
            ),
          );
          context.read<TaskListCubit>().clearActionError();
        },
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 16, bottom: 32),
              children: <Widget>[
                // Top Tab Bar: "to do" | "done"
                Padding(
                  padding: _hPadding,
                  child: WsidTabBar(
                    labels: <String>[l10n.toDo, l10n.done],
                    selectedIndex: _selectedTabIndex,
                    onChanged: (int index) {
                      setState(() => _selectedTabIndex = index);
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Search Bar & Filters
                Padding(
                  padding: _hPadding,
                  child: Row(
                    children: <Widget>[
                      const Expanded(child: TaskSearchBar()),
                      const SizedBox(width: 12),
                      WsidIconButton(
                        icon: Icons.filter_alt_outlined,
                        tooltip: 'Filter',
                        variant: WsidIconButtonVariant.outlined,
                        size: WsidIconButtonSize.large,
                        onPressed: () =>
                            setState(() => _showFilters = !_showFilters),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                if (_showFilters) ...<Widget>[
                  Padding(
                    padding: _hPadding,
                    child: _TaskFilters(
                      priority: _priorityFilter,
                      durationRange: _durationRange,
                      onPriorityChanged: (TaskPriority? value) =>
                          setState(() => _priorityFilter = value),
                      onDurationChanged: (RangeValues? value) => setState(() {
                        if (value != null &&
                            value.start ==
                                TaskDurationPresets.minutes.first.toDouble() &&
                            value.end ==
                                TaskDurationPresets.minutes.last.toDouble()) {
                          _durationRange = null;
                        } else {
                          _durationRange = value;
                        }
                      }),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const TaskCategoryFilterChips(padding: _hPadding),
                  const SizedBox(height: 16),
                ],

                // In "to do" tab: In-progress banner if user has an active task
                if (isToDoTab && activeTask != null) ...<Widget>[
                  Padding(
                    padding: _hPadding,
                    child: WsidTaskBanner(
                      label: l10n.inProgress,
                      title: activeTask.title,
                      subtitle: categoryNames[activeTask.categoryId] ??
                          l10n.uncategorized,
                      actionLabel: l10n.startTask,
                      onAction: () => TaskFlowNavigation.openTaskDetails(
                        context,
                        task: activeTask,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Tab Content: Either 'to do' (pending) or 'done' (completed)
                Padding(
                  padding: _hPadding,
                  child: TaskGroupListSection(
                    targetStatus: isToDoTab
                        ? TaskStatus.pending
                        : TaskStatus.completed,
                    priorityFilter: _priorityFilter,
                    durationRange: _durationRange,
                    onResetFilters: _resetFilters,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
