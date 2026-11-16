import 'package:fpdart/fpdart.dart' hide Task;
import 'package:wsidappp/core/errors/failure.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';

/// Contract for all task lifecycle operations.
///
/// Implementations live in `features/tasks/data/repositories/`.
/// No Supabase or UI imports are permitted in this file.
abstract interface class TaskRepository {
  /// Returns tasks for the authenticated user.
  ///
  /// Pass [categoryId] to scope results to a single category.
  /// Pass [status] to filter by lifecycle stage.
  Future<Either<Failure, List<Task>>> getTasks({
    String? categoryId,
    TaskStatus? status,
  });

  /// Creates a new task in [categoryId] and returns the persisted [Task].
  Future<Either<Failure, Task>> createTask({
    required String categoryId,
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.medium,
    int? estimatedDuration,
    String? link,
  });

  /// Persists all mutable fields on [task] and returns the updated [Task].
  Future<Either<Failure, Task>> updateTask(Task task);

  /// Permanently deletes the task identified by [taskId].
  Future<Either<Failure, void>> deleteTask(String taskId);

  /// Returns the single task currently in progress, or `null` if none exists.
  Future<Either<Failure, Task?>> getActiveTask();

  /// Transitions the task to [TaskStatus.inProgress].
  ///
  /// Only one task may be in progress at a time; implementations should
  /// enforce this constraint.
  Future<Either<Failure, Task>> takeTask(String taskId);

  /// Transitions the task to [TaskStatus.completed] and records [Task.completedAt].
  Future<Either<Failure, Task>> completeTask(String taskId);

  /// Transitions the task back to [TaskStatus.pending], clearing [Task.completedAt].
  Future<Either<Failure, Task>> returnToPool(String taskId);
}
