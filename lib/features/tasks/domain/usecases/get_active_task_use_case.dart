import 'package:fpdart/fpdart.dart' hide Task;
import 'package:injectable/injectable.dart';
import 'package:wsidappp/core/errors/failure.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';
import 'package:wsidappp/features/tasks/domain/repositories/task_repository.dart';

/// Returns the single task currently [TaskStatus.inProgress], or `null`.
@injectable
class GetActiveTaskUseCase {
  const GetActiveTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<Either<Failure, Task?>> call() => _repository.getActiveTask();
}
