import 'package:fpdart/fpdart.dart' hide Task;
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wsidappp/core/constants/supabase_tables.dart';
import 'package:wsidappp/core/errors/failure.dart';
import 'package:wsidappp/core/errors/supabase_error_handler.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';
import 'package:wsidappp/features/suggestion/domain/repositories/suggestion_repository.dart';

/// Supabase-backed implementation of [SuggestionRepository].
///
/// Delegates to the [SupabaseTables.getRandomTaskSuggestion] RPC function,
/// which applies server-side randomisation and optional filtering.
@LazySingleton(as: SuggestionRepository)
class SuggestionRepositoryImpl implements SuggestionRepository {
  const SuggestionRepositoryImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<Either<Failure, Task?>> getRandomSuggestion({
    String? categoryId,
    List<String> excludeTaskIds = const [],
  }) async {
    try {
      final result = await _supabase.rpc<List<dynamic>>(
        SupabaseTables.getRandomTaskSuggestion,
        params: {
          'p_category_id': categoryId,
          'p_exclude_ids': excludeTaskIds,
        },
      );
      final list = result;
      if (list.isEmpty) return right(null);
      return right(Task.fromJson(list.first as Map<String, dynamic>));
    } catch (e) {
      return left(handleSupabaseError(e));
    }
  }
}
