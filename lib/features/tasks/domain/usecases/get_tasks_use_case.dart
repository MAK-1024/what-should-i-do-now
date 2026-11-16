import 'package:fpdart/fpdart.dart' hide Task;
import 'package:injectable/injectable.dart';
import 'package:wsidappp/core/errors/failure.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';
import 'package:wsidappp/features/tasks/domain/repositories/task_repository.dart';

/// Returns all tasks, optionally filtered by [categoryId] and/or [status].
@injectable
class GetTasksUseCase {
  const GetTasksUseCase(this._repository);

  final TaskRepository _repository;

  Future<Either<Failure, List<Task>>> call({
    String? categoryId,
    TaskStatus? status,
  }) =>
      _repository.getTasks(categoryId: categoryId, status: status);
}
