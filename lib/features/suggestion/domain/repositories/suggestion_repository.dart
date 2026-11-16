import 'package:fpdart/fpdart.dart' hide Task;
import 'package:wsidappp/core/errors/failure.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';

/// Contract for fetching a randomly-suggested task via the Supabase RPC layer.
///
/// Implementations live in `features/suggestion/data/repositories/`.
/// No Supabase or UI imports are permitted in this file.
abstract interface class SuggestionRepository {
  /// Returns a randomly selected [Task] from the pending pool, or `null`
  /// when no eligible tasks are available.
  ///
  /// [categoryId] — if provided, constrains the selection to that category.
  /// [excludeTaskIds] — task IDs to exclude from the random draw (e.g. recently
  ///   shown suggestions that the user has already dismissed).
  Future<Either<Failure, Task?>> getRandomSuggestion({
    String? categoryId,
    List<String> excludeTaskIds = const [],
  });
}
