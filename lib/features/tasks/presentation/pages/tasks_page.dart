import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_cubit.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_cubit.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_state.dart';
import 'package:wsidappp/features/tasks/presentation/widgets/tasks_page_widgets/dialogs/create_task_sheet.dart';
import 'package:wsidappp/features/tasks/presentation/widgets/tasks_page_widgets/sections/task_category_filter_chips.dart';
import 'package:wsidappp/features/tasks/presentation/widgets/tasks_page_widgets/sections/task_group_list_section.dart';
import 'package:wsidappp/features/tasks/presentation/widgets/tasks_page_widgets/sections/task_search_bar.dart';
import 'package:wsidappp/features/tasks/presentation/widgets/tasks_page_widgets/sections/task_status_segmented_control.dart';
import 'package:wsidappp/features/tasks/presentation/widgets/tasks_page_widgets/sections/tasks_header_section.dart';

/// Tasks backlog: search, status segments, category chips and grouped list.
class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  static const EdgeInsets _hPadding = EdgeInsets.symmetric(horizontal: 20);

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() => Future.wait(<Future<void>>[
        context.read<TaskListCubit>().loadTasks(),
        context.read<CategoryCubit>().loadCategories(),
      ]);

  void _openCreateTaskSheet() {
    CreateTaskSheet.show(
      context,
      taskListCubit: context.read<TaskListCubit>(),
      categoryCubit: context.read<CategoryCubit>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<TaskListCubit, TaskListState>(
        listenWhen: (_, TaskListState current) =>
            current.mapOrNull(loaded: (l) => l.actionErrorMessage) != null,
        listener: (BuildContext context, TaskListState state) {
          final String? message =
              state.mapOrNull(loaded: (l) => l.actionErrorMessage);
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
                Padding(
                  padding: _hPadding,
                  child: TasksHeaderSection(onAddTask: _openCreateTaskSheet),
                ),
                const SizedBox(height: 20),
                const Padding(padding: _hPadding, child: TaskSearchBar()),
                const SizedBox(height: 16),
                const Padding(
                  padding: _hPadding,
                  child: TaskStatusSegmentedControl(),
                ),
                const SizedBox(height: 16),
                const TaskCategoryFilterChips(padding: _hPadding),
                const SizedBox(height: 20),
                const Padding(padding: _hPadding, child: TaskGroupListSection()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
