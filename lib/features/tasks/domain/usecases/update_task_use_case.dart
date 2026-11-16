import 'package:fpdart/fpdart.dart' hide Task;
import 'package:injectable/injectable.dart';
import 'package:wsidappp/core/errors/failure.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';
import 'package:wsidappp/features/tasks/domain/repositories/task_repository.dart';

/// Persists all mutable fields on [task] and returns the updated [Task].
@injectable
class UpdateTaskUseCase {
  const UpdateTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<Either<Failure, Task>> call(Task task) =>
      _repository.updateTask(task);
}
