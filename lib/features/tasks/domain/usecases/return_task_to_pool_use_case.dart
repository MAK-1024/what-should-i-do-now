import 'package:fpdart/fpdart.dart' hide Task;
import 'package:injectable/injectable.dart';
import 'package:wsidappp/core/errors/failure.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';
import 'package:wsidappp/features/tasks/domain/repositories/task_repository.dart';

/// Transitions the task back to [TaskStatus.pending], clearing [Task.completedAt].
@injectable
class ReturnTaskToPoolUseCase {
  const ReturnTaskToPoolUseCase(this._repository);

  final TaskRepository _repository;

  Future<Either<Failure, Task>> call(String taskId) =>
      _repository.returnToPool(taskId);
}
