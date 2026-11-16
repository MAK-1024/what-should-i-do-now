import 'package:fpdart/fpdart.dart' hide Task;
import 'package:injectable/injectable.dart';
import 'package:wsidappp/core/errors/failure.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';
import 'package:wsidappp/features/tasks/domain/repositories/task_repository.dart';

/// Transitions the task to [TaskStatus.inProgress].
@injectable
class TakeTaskUseCase {
  const TakeTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<Either<Failure, Task>> call(String taskId) =>
      _repository.takeTask(taskId);
}
