import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';

part 'suggestion_state.freezed.dart';

@freezed
class SuggestionState with _$SuggestionState {
  const factory SuggestionState.initial() = _Initial;
  const factory SuggestionState.loading() = _Loading;
  const factory SuggestionState.suggesting() = _Suggesting;
  const factory SuggestionState.hasActiveTask({
    required Task activeTask,
  }) = _HasActiveTask;
  const factory SuggestionState.hasSuggestion({
    required Task suggestedTask,
    required List<String> excludedIds,
  }) = _HasSuggestion;
  const factory SuggestionState.empty({required String message}) = _Empty;
  const factory SuggestionState.error({required String message}) = _Error;
}
