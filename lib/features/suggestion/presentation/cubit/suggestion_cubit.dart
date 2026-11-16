import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:wsidappp/core/services/notification_service.dart';
import 'package:wsidappp/core/utils/app_motion.dart';
import 'package:wsidappp/features/suggestion/domain/usecases/get_random_suggestion_use_case.dart';
import 'package:wsidappp/features/suggestion/presentation/cubit/suggestion_state.dart';
import 'package:wsidappp/features/tasks/domain/usecases/complete_task_use_case.dart';
import 'package:wsidappp/features/tasks/domain/usecases/get_active_task_use_case.dart';
import 'package:wsidappp/features/tasks/domain/usecases/return_task_to_pool_use_case.dart';
import 'package:wsidappp/features/tasks/domain/usecases/take_task_use_case.dart';

@injectable
class SuggestionCubit extends Cubit<SuggestionState> {
  SuggestionCubit(
    this._getRandomSuggestionUseCase,
    this._getActiveTaskUseCase,
    this._takeTaskUseCase,
    this._completeTaskUseCase,
    this._returnTaskToPoolUseCase,
    this._notificationService,
  ) : super(const SuggestionState.initial());

  final GetRandomSuggestionUseCase _getRandomSuggestionUseCase;
  final GetActiveTaskUseCase _getActiveTaskUseCase;
  final TakeTaskUseCase _takeTaskUseCase;
  final CompleteTaskUseCase _completeTaskUseCase;
  final ReturnTaskToPoolUseCase _returnTaskToPoolUseCase;
  final NotificationService _notificationService;

  static const Duration _minDeciderAnimationDuration = AppMotion.cycleTotal;

  final List<String> _excludedIds = <String>[];

  Future<void> checkActiveTask() async {
    final result = await _getActiveTaskUseCase();
    result.fold(
      (failure) => emit(SuggestionState.error(message: failure.message)),
      (activeTask) {
        if (activeTask != null) {
          emit(SuggestionState.hasActiveTask(activeTask: activeTask));
        } else {
          emit(const SuggestionState.initial());
        }
      },
    );
  }

  Future<void> getRandomSuggestion({
    String? categoryId,
    Duration minAnimationDuration = _minDeciderAnimationDuration,
  }) async {
    emit(const SuggestionState.suggesting());
    final delayFuture = Future<void>.delayed(minAnimationDuration);
    final result = await _getRandomSuggestionUseCase(
      categoryId: categoryId,
      excludeTaskIds: _excludedIds,
    );
    await delayFuture;

    await result.fold(
      (failure) async {
        emit(SuggestionState.error(message: failure.message));
      },
      (task) async {
        if (task != null) {
          _excludedIds.add(task.id);
          emit(
            SuggestionState.hasSuggestion(
              suggestedTask: task,
              excludedIds: List<String>.unmodifiable(_excludedIds),
            ),
          );
        } else if (_excludedIds.isNotEmpty) {
          _excludedIds.clear();
          final retryResult = await _getRandomSuggestionUseCase(
            categoryId: categoryId,
            excludeTaskIds: _excludedIds,
          );
          retryResult.fold(
            (retryFailure) =>
                emit(SuggestionState.error(message: retryFailure.message)),
            (retryTask) {
              if (retryTask != null) {
                _excludedIds.add(retryTask.id);
                emit(
                  SuggestionState.hasSuggestion(
                    suggestedTask: retryTask,
                    excludedIds: List<String>.unmodifiable(_excludedIds),
                  ),
                );
              } else {
                emit(
                  const SuggestionState.empty(
                    message:
                        'No pending tasks found. Add tasks to get started!',
                  ),
                );
              }
            },
          );
        } else {
          emit(
            const SuggestionState.empty(
              message: 'No pending tasks found. Add tasks to get started!',
            ),
          );
        }
      },
    );
  }

  Future<void> takeTask(String taskId) async {
    emit(const SuggestionState.loading());
    final result = await _takeTaskUseCase(taskId);
    result.fold(
      (failure) => emit(SuggestionState.error(message: failure.message)),
      (updatedTask) {
        _excludedIds.clear();
        emit(SuggestionState.hasActiveTask(activeTask: updatedTask));
        if (updatedTask.estimatedDuration != null &&
            updatedTask.estimatedDuration! > 0) {
          _notificationService.scheduleTaskTimer(updatedTask);
        }
      },
    );
  }

  Future<void> completeTask(String taskId) async {
    emit(const SuggestionState.loading());
    final result = await _completeTaskUseCase(taskId);
    result.fold(
      (failure) => emit(SuggestionState.error(message: failure.message)),
      (completedTask) {
        _excludedIds.clear();
        emit(const SuggestionState.initial());
        _notificationService.cancelTaskTimer();
        _notificationService.showTaskCompletedCelebration(completedTask);
      },
    );
  }

  Future<void> returnToPool(String taskId) async {
    emit(const SuggestionState.loading());
    final result = await _returnTaskToPoolUseCase(taskId);
    result.fold(
      (failure) => emit(SuggestionState.error(message: failure.message)),
      (_) {
        _excludedIds.clear();
        emit(const SuggestionState.initial());
        _notificationService.cancelTaskTimer();
      },
    );
  }
}
