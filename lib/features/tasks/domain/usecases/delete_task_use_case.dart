import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:wsidappp/core/errors/failure.dart';
import 'package:wsidappp/features/tasks/domain/repositories/task_repository.dart';

/// Permanently deletes the task identified by [taskId].
@injectable
class DeleteTaskUseCase {
  const DeleteTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<Either<Failure, void>> call(String taskId) =>
      _repository.deleteTask(taskId);
}
