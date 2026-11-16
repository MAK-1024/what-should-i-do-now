import 'package:fpdart/fpdart.dart' hide Task;
import 'package:injectable/injectable.dart';
import 'package:wsidappp/core/errors/failure.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';
import 'package:wsidappp/features/tasks/domain/repositories/task_repository.dart';

/// Creates a new task in [categoryId] and returns the persisted [Task].
@injectable
class CreateTaskUseCase {
  const CreateTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<Either<Failure, Task>> call({
    required String categoryId,
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.medium,
    int? estimatedDuration,
    String? link,
  }) =>
      _repository.createTask(
        categoryId: categoryId,
        title: title,
        description: description,
        priority: priority,
        estimatedDuration: estimatedDuration,
        link: link,
      );
}
