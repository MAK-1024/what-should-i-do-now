import 'package:fpdart/fpdart.dart' hide Task;
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wsidappp/core/constants/supabase_tables.dart';
import 'package:wsidappp/core/errors/failure.dart';
import 'package:wsidappp/core/errors/supabase_error_handler.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';
import 'package:wsidappp/features/tasks/domain/repositories/task_repository.dart';

/// Supabase-backed implementation of [TaskRepository].
@LazySingleton(as: TaskRepository)
class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl(this._supabase);

  final SupabaseClient _supabase;

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Converts [TaskStatus.inProgress] to its DB string `'in_progress'`;
  /// all other statuses use their [Enum.name].
  String _statusToDb(TaskStatus status) =>
      status == TaskStatus.inProgress ? 'in_progress' : status.name;

  // ── TaskRepository ────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Task>>> getTasks({
    String? categoryId,
    TaskStatus? status,
  }) async {
    try {
      var query = _supabase.from(SupabaseTables.tasks).select();
      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }
      if (status != null) {
        query = query.eq('status', _statusToDb(status));
      }
      final data = await query.order('created_at', ascending: false);
      final tasks = (data as List<dynamic>)
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList();
      return right(tasks);
    } catch (e) {
      return left(handleSupabaseError(e));
    }
  }

  @override
  Future<Either<Failure, Task>> createTask({
    required String categoryId,
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.medium,
    int? estimatedDuration,
    String? link,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        return left(const AuthFailure(message: 'User not authenticated'));
      }
      final data = await _supabase
          .from(SupabaseTables.tasks)
          .insert({
            'user_id': currentUser.id,
            'category_id': categoryId,
            'title': title,
            'description': description,
            'priority': priority.name,
            'estimated_duration': estimatedDuration,
            'link': link,
            'status': 'pending',
          })
          .select()
          .single();
      return right(Task.fromJson(data));
    } catch (e) {
      return left(handleSupabaseError(e));
    }
  }

  @override
  Future<Either<Failure, Task>> updateTask(Task task) async {
    try {
      final data = await _supabase
          .from(SupabaseTables.tasks)
          .update(task.toJson())
          .eq('id', task.id)
          .select()
          .single();
      return right(Task.fromJson(data));
    } catch (e) {
      return left(handleSupabaseError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String taskId) async {
    try {
      await _supabase
          .from(SupabaseTables.tasks)
          .delete()
          .eq('id', taskId);
      return right(null);
    } catch (e) {
      return left(handleSupabaseError(e));
    }
  }

  @override
  Future<Either<Failure, Task?>> getActiveTask() async {
    try {
      final data = await _supabase
          .from(SupabaseTables.tasks)
          .select()
          .eq('status', 'in_progress')
          .maybeSingle();
      return right(data != null ? Task.fromJson(data) : null);
    } catch (e) {
      return left(handleSupabaseError(e));
    }
  }

  @override
  Future<Either<Failure, Task>> takeTask(String taskId) async {
    try {
      final data = await _supabase
          .from(SupabaseTables.tasks)
          .update({'status': 'in_progress'})
          .eq('id', taskId)
          .select()
          .single();
      return right(Task.fromJson(data));
    } catch (e) {
      return left(handleSupabaseError(e));
    }
  }

  @override
  Future<Either<Failure, Task>> completeTask(String taskId) async {
    try {
      final data = await _supabase
          .from(SupabaseTables.tasks)
          .update({
            'status': 'completed',
            'completed_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', taskId)
          .select()
          .single();
      return right(Task.fromJson(data));
    } catch (e) {
      return left(handleSupabaseError(e));
    }
  }

  @override
  Future<Either<Failure, Task>> returnToPool(String taskId) async {
    try {
      final data = await _supabase
          .from(SupabaseTables.tasks)
          .update({'status': 'pending', 'completed_at': null})
          .eq('id', taskId)
          .select()
          .single();
      return right(Task.fromJson(data));
    } catch (e) {
      return left(handleSupabaseError(e));
    }
  }
}
