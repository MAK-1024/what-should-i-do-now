import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart' hide Task;
import 'package:injectable/injectable.dart';
import 'package:wsidappp/core/errors/failure.dart';
import 'package:wsidappp/core/services/notification_service.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';
import 'package:wsidappp/features/tasks/domain/usecases/complete_task_use_case.dart';
import 'package:wsidappp/features/tasks/domain/usecases/create_task_use_case.dart';
import 'package:wsidappp/features/tasks/domain/usecases/delete_task_use_case.dart';
import 'package:wsidappp/features/tasks/domain/usecases/get_tasks_use_case.dart';
import 'package:wsidappp/features/tasks/domain/usecases/return_task_to_pool_use_case.dart';
import 'package:wsidappp/features/tasks/domain/usecases/take_task_use_case.dart';
import 'package:wsidappp/features/tasks/domain/usecases/update_task_use_case.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_state.dart';

@injectable
class TaskListCubit extends Cubit<TaskListState> {
  TaskListCubit(
    this._getTasksUseCase,
    this._createTaskUseCase,
    this._updateTaskUseCase,
    this._deleteTaskUseCase,
    this._takeTaskUseCase,
    this._completeTaskUseCase,
    this._returnTaskToPoolUseCase,
    this._notificationService,
  ) : super(const TaskListState.initial());

  final GetTasksUseCase _getTasksUseCase;
  final CreateTaskUseCase _createTaskUseCase;
  final UpdateTaskUseCase _updateTaskUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;
  final TakeTaskUseCase _takeTaskUseCase;
  final CompleteTaskUseCase _completeTaskUseCase;
  final ReturnTaskToPoolUseCase _returnTaskToPoolUseCase;
  final NotificationService _notificationService;

  String _searchQuery = '';
  TaskStatus? _filterStatus = TaskStatus.pending;
  String? _filterCategoryId;

  /// Fetches the full backlog. Active filters are preserved and applied
  /// client-side via [TaskListState.visibleTasks].
  Future<void> loadTasks() async {
    final bool hasData = state.mapOrNull(loaded: (_) => true) ?? false;
    if (!hasData) emit(const TaskListState.loading());

    final Either<Failure, List<Task>> result = await _getTasksUseCase();
    result.fold(
      (Failure failure) {
        if (hasData) {
          _emitActionError(failure.message);
        } else {
          emit(TaskListState.error(message: failure.message));
        }
      },
      (List<Task> tasks) => emit(_loaded(tasks)),
    );
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _emitFilters();
  }

  void setStatusFilter(TaskStatus? status) {
    _filterStatus = status;
    _emitFilters();
  }

  void setCategoryFilter(String? categoryId) {
    _filterCategoryId = categoryId;
    _emitFilters();
  }

  Future<bool> createTask({
    required String categoryId,
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.medium,
    int? estimatedDuration,
    String? link,
  }) async {
    final Either<Failure, Task> result = await _createTaskUseCase(
      categoryId: categoryId,
      title: title,
      description: description,
      priority: priority,
      estimatedDuration: estimatedDuration,
      link: link,
    );
    return _handleMutationResult(result);
  }

  Future<bool> updateTask(Task task) async =>
      _handleMutationResult(await _updateTaskUseCase(task));

  Future<bool> deleteTask(String taskId) async =>
      _handleMutationResult(await _deleteTaskUseCase(taskId));

  /// Moves [task] to [newStatus] using the lifecycle use case that matches the
  /// transition. Only one task may be in progress at a time.
  Future<bool> changeTaskStatus(Task task, TaskStatus newStatus) async {
    if (task.status == newStatus) return true;

    if (newStatus == TaskStatus.inProgress && _hasOtherActiveTask(task.id)) {
      _emitActionError(
        'Another task is already in progress.',
        failure: const TaskActionFailure.activeTaskExists(),
      );
      return false;
    }

    final Either<Failure, Task> result = switch (newStatus) {
      TaskStatus.inProgress => await _takeTaskUseCase(task.id),
      TaskStatus.completed => await _completeTaskUseCase(task.id),
      TaskStatus.pending => await _returnTaskToPoolUseCase(task.id),
      TaskStatus.archived =>
        await _updateTaskUseCase(task.copyWith(status: TaskStatus.archived)),
    };

    return result.fold(
      (Failure failure) {
        _emitActionError(failure.message);
        return false;
      },
      (Task updatedTask) async {
        switch (newStatus) {
          case TaskStatus.inProgress:
            if (updatedTask.estimatedDuration != null &&
                updatedTask.estimatedDuration! > 0) {
              await _notificationService.scheduleTaskTimer(updatedTask);
            }
          case TaskStatus.completed:
            await _notificationService.cancelTaskTimer();
            await _notificationService.showTaskCompletedCelebration(updatedTask);
          case TaskStatus.pending:
          case TaskStatus.archived:
            await _notificationService.cancelTaskTimer();
        }
        await loadTasks();
        return true;
      },
    );
  }

  bool _hasOtherActiveTask(String taskId) => state.maybeWhen(
        loaded: (List<Task> tasks, _, _, _, _, _) => tasks.any(
          (Task t) => t.status == TaskStatus.inProgress && t.id != taskId,
        ),
        orElse: () => false,
      );

  Future<bool> _handleMutationResult<T>(Either<Failure, T> result) async {
    return result.fold(
      (Failure failure) {
        _emitActionError(failure.message);
        return false;
      },
      (_) async {
        await loadTasks();
        return true;
      },
    );
  }

  /// Emits transient mutation error while keeping existing tasks intact.
  void _emitActionError(String message, {TaskActionFailure? failure}) {
    final List<Task>? tasks = state.mapOrNull(loaded: (l) => l.tasks);
    if (tasks == null) {
      emit(TaskListState.error(message: message));
      return;
    }
    emit(_loaded(
      tasks,
      actionErrorMessage: message,
      actionFailure: failure ?? TaskActionFailure.server(message: message),
    ));
  }

  /// Clears the transient action error once presented to the user.
  void clearActionError() {
    state.mapOrNull(
      loaded: (loaded) {
        if (loaded.actionErrorMessage != null || loaded.actionFailure != null) {
          emit(loaded.copyWith(
            actionErrorMessage: null,
            actionFailure: null,
          ));
        }
      },
    );
  }

  void _emitFilters() {
    state.mapOrNull(
      loaded: (loaded) => emit(_loaded(loaded.tasks)),
    );
  }

  TaskListState _loaded(
    List<Task> tasks, {
    String? actionErrorMessage,
    TaskActionFailure? actionFailure,
  }) =>
      TaskListState.loaded(
        tasks: tasks,
        searchQuery: _searchQuery,
        filterStatus: _filterStatus,
        filterCategoryId: _filterCategoryId,
        actionErrorMessage: actionErrorMessage,
        actionFailure: actionFailure,
      );
}
