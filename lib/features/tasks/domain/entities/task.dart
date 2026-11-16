import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';
part 'task.g.dart';

// ── Enums ──────────────────────────────────────────────────────────────────

/// Priority level of a [Task].
@JsonEnum()
enum TaskPriority {
  low,
  medium,
  high,
}

/// Lifecycle status of a [Task].
@JsonEnum()
enum TaskStatus {
  pending,
  @JsonValue('in_progress')
  inProgress,
  completed,
  archived,
}

// ── Entity ─────────────────────────────────────────────────────────────────

/// Immutable domain entity representing a single actionable task.
///
/// Maps directly to the `tasks` Supabase table row.
@freezed
abstract class Task with _$Task {
  const factory Task({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'category_id') required String categoryId,
    required String title,
    String? description,
    @Default(TaskPriority.medium) TaskPriority priority,
    @JsonKey(name: 'estimated_duration') int? estimatedDuration,
    String? link,
    @Default(TaskStatus.pending) TaskStatus status,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}
