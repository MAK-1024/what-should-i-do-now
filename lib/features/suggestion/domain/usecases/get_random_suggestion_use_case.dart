import 'package:fpdart/fpdart.dart' hide Task;
import 'package:injectable/injectable.dart';
import 'package:wsidappp/core/errors/failure.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';
import 'package:wsidappp/features/suggestion/domain/repositories/suggestion_repository.dart';

/// Returns a randomly selected pending [Task], or `null` when the pool is empty.
///
/// [categoryId] — optional scope; omit to draw from all categories.
/// [excludeTaskIds] — IDs of tasks to exclude from the draw (e.g. recently dismissed).
@injectable
class GetRandomSuggestionUseCase {
  const GetRandomSuggestionUseCase(this._repository);

  final SuggestionRepository _repository;

  Future<Either<Failure, Task?>> call({
    String? categoryId,
    List<String> excludeTaskIds = const [],
  }) =>
      _repository.getRandomSuggestion(
        categoryId: categoryId,
        excludeTaskIds: excludeTaskIds,
      );
}
