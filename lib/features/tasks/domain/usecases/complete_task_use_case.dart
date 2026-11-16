import 'package:fpdart/fpdart.dart' hide Task;
import 'package:injectable/injectable.dart';
import 'package:wsidappp/core/errors/failure.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';
import 'package:wsidappp/features/tasks/domain/repositories/task_repository.dart';

/// Transitions the task to [TaskStatus.completed] and records [Task.completedAt].
@injectable
class CompleteTaskUseCase {
  const CompleteTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<Either<Failure, Task>> call(String taskId) =>
      _repository.completeTask(taskId);
}
