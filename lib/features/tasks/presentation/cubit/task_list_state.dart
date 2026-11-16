import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';

part 'task_list_state.freezed.dart';

/// Failure raised by a mutating task action (create/update/delete/status).
@freezed
sealed class TaskActionFailure with _$TaskActionFailure {
  const factory TaskActionFailure.activeTaskExists() = _ActiveTaskExists;
  const factory TaskActionFailure.server({required String message}) =
      _ServerActionFailure;
}

@freezed
sealed class TaskListState with _$TaskListState {
  const TaskListState._();

  const factory TaskListState.initial() = _Initial;
  const factory TaskListState.loading() = _Loading;

  /// [tasks] is the full, unfiltered backlog; use [visibleTasks] for the
  /// list filtered by [searchQuery], [filterStatus] and [filterCategoryId].
  /// [actionErrorMessage] is a transient mutation error message for listeners.
  /// [actionFailure] is preserved for typed failure matching.
  const factory TaskListState.loaded({
    required List<Task> tasks,
    @Default('') String searchQuery,
    @Default(TaskStatus.pending) TaskStatus? filterStatus,
    String? filterCategoryId,
    String? actionErrorMessage,
    TaskActionFailure? actionFailure,
  }) = _Loaded;

  const factory TaskListState.error({required String message}) = _Error;

  List<Task> get visibleTasks {
    final loaded = mapOrNull(loaded: (s) => s);
    if (loaded == null) return const <Task>[];
    final String query = loaded.searchQuery.trim().toLowerCase();
    return loaded.tasks.where((Task task) {
      if (loaded.filterStatus != null && task.status != loaded.filterStatus) {
        return false;
      }
      if (loaded.filterCategoryId != null &&
          task.categoryId != loaded.filterCategoryId) {
        return false;
      }
      if (query.isEmpty) return true;
      return task.title.toLowerCase().contains(query) ||
          (task.description?.toLowerCase().contains(query) ?? false);
    }).toList(growable: false);
  }

  Task? taskById(String id) {
    final loaded = mapOrNull(loaded: (s) => s);
    if (loaded == null) return null;
    for (final Task task in loaded.tasks) {
      if (task.id == id) return task;
    }
    return null;
  }
}
