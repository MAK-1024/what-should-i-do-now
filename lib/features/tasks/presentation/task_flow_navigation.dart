import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_cubit.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_cubit.dart';
import 'package:wsidappp/features/tasks/presentation/pages/add_task_page.dart';
import 'package:wsidappp/features/tasks/presentation/pages/task_details_page.dart';

/// Opens full-screen task flows with shell-scoped cubits.
abstract final class TaskFlowNavigation {
  static void openAddTask(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => MultiBlocProvider(
          providers: <BlocProvider<dynamic>>[
            BlocProvider<TaskListCubit>.value(
              value: context.read<TaskListCubit>(),
            ),
            BlocProvider<CategoryCubit>.value(
              value: context.read<CategoryCubit>(),
            ),
          ],
          child: const AddTaskPage(),
        ),
      ),
    );
  }

  static Future<void> openTaskDetails(
    BuildContext context, {
    required Task task,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => MultiBlocProvider(
          providers: <BlocProvider<dynamic>>[
            BlocProvider<TaskListCubit>.value(
              value: context.read<TaskListCubit>(),
            ),
            BlocProvider<CategoryCubit>.value(
              value: context.read<CategoryCubit>(),
            ),
          ],
          child: TaskDetailsPage(task: task),
        ),
      ),
    );
  }
}