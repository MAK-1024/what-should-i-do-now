import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide Task;
import 'package:wsidappp/core/errors/failure.dart';
import 'package:wsidappp/core/services/notification_service.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';
import 'package:wsidappp/features/tasks/domain/repositories/task_repository.dart';
import 'package:wsidappp/features/tasks/domain/usecases/complete_task_use_case.dart';
import 'package:wsidappp/features/tasks/domain/usecases/create_task_use_case.dart';
import 'package:wsidappp/features/tasks/domain/usecases/delete_task_use_case.dart';
import 'package:wsidappp/features/tasks/domain/usecases/get_tasks_use_case.dart';
import 'package:wsidappp/features/tasks/domain/usecases/return_task_to_pool_use_case.dart';
import 'package:wsidappp/features/tasks/domain/usecases/take_task_use_case.dart';
import 'package:wsidappp/features/tasks/domain/usecases/update_task_use_case.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_cubit.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_state.dart';

final Task _sampleTask = Task(
  id: 'task-1',
  userId: 'user-1',
  categoryId: 'cat-1',
  title: 'Clean Room',
  priority: TaskPriority.high,
  estimatedDuration: 30,
  status: TaskStatus.pending,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

class _FakeTaskRepository implements TaskRepository {
  _FakeTaskRepository({this.failCreation = false});

  final bool failCreation;
  final List<Task> tasks = <Task>[_sampleTask];

  @override
  Future<Either<Failure, List<Task>>> getTasks({
    String? categoryId,
    TaskStatus? status,
  }) async =>
      right(tasks);

  @override
  Future<Either<Failure, Task>> createTask({
    required String categoryId,
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.medium,
    int? estimatedDuration,
    String? link,
  }) async {
    if (failCreation) {
      return left(const ServerFailure(message: 'Could not create task'));
    }
    return right(_sampleTask);
  }

  @override
  Future<Either<Failure, Task>> updateTask(Task task) async => right(task);

  @override
  Future<Either<Failure, void>> deleteTask(String taskId) async => right(null);

  @override
  Future<Either<Failure, Task?>> getActiveTask() async => right(null);

  @override
  Future<Either<Failure, Task>> takeTask(String taskId) async =>
      right(_sampleTask.copyWith(status: TaskStatus.inProgress));

  @override
  Future<Either<Failure, Task>> completeTask(String taskId) async =>
      right(_sampleTask.copyWith(status: TaskStatus.completed));

  @override
  Future<Either<Failure, Task>> returnToPool(String taskId) async =>
      right(_sampleTask.copyWith(status: TaskStatus.pending));
}

class _FakeNotificationService implements NotificationService {
  int scheduledTimers = 0;
  int cancelledTimers = 0;
  int celebrations = 0;

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<void> scheduleDailyReminder({int hour = 9, int minute = 0}) async {}

  @override
  Future<void> scheduleTaskTimer(Task task, {int? durationMinutes}) async {
    scheduledTimers++;
  }

  @override
  Future<void> showTaskCompletedCelebration(Task task) async {
    celebrations++;
  }

  @override
  Future<void> cancelTaskTimer() async {
    cancelledTimers++;
  }

  @override
  Future<void> cancelAllNotifications() async {}

  @override
  Future<bool> areNotificationsEnabled() async => true;

  @override
  Future<bool> isPermissionGranted() async => true;

  @override
  Future<void> cancelDailyReminder() async {}

  @override
  Future<bool> checkAndRequestFirstLaunchPermission() async => true;

  @override
  Future<bool> requestPermissionOrOpenSettings() async => true;

  @override
  Future<void> completeFirstLaunchPermissionPrompt({required bool userWantsNotifications}) {
    // TODO: implement completeFirstLaunchPermissionPrompt
    throw UnimplementedError();
  }

  @override
  bool shouldPromptFirstLaunchPermission() {
    // TODO: implement shouldPromptFirstLaunchPermission
    throw UnimplementedError();
  }
}

TaskListCubit _buildCubit(
  _FakeTaskRepository repo, {
  NotificationService? notificationService,
}) {
  return TaskListCubit(
    GetTasksUseCase(repo),
    CreateTaskUseCase(repo),
    UpdateTaskUseCase(repo),
    DeleteTaskUseCase(repo),
    TakeTaskUseCase(repo),
    CompleteTaskUseCase(repo),
    ReturnTaskToPoolUseCase(repo),
    notificationService ?? _FakeNotificationService(),
  );
}

void main() {
  group('TaskListCubit action error handling', () {
    blocTest<TaskListCubit, TaskListState>(
      'emits loaded state when loadTasks succeeds',
      build: () => _buildCubit(_FakeTaskRepository()),
      act: (TaskListCubit cubit) => cubit.loadTasks(),
      expect: () => <dynamic>[
        const TaskListState.loading(),
        isA<TaskListState>().having(
          (s) => s.mapOrNull(loaded: (l) => l.tasks.length),
          'tasks length',
          1,
        ),
      ],
    );

    blocTest<TaskListCubit, TaskListState>(
      'mutation failure emits actionErrorMessage without losing existing loaded tasks',
      build: () => _buildCubit(_FakeTaskRepository(failCreation: true)),
      seed: () => TaskListState.loaded(
        tasks: <Task>[_sampleTask],
        searchQuery: '',
        filterStatus: TaskStatus.pending,
        filterCategoryId: null,
      ),
      act: (TaskListCubit cubit) => cubit.createTask(
        categoryId: 'cat-1',
        title: 'New Task',
      ),
      expect: () => <dynamic>[
        isA<TaskListState>()
            .having(
              (s) => s.mapOrNull(loaded: (l) => l.actionErrorMessage),
              'actionErrorMessage',
              'Could not create task',
            )
            .having(
              (s) => s.mapOrNull(loaded: (l) => l.tasks.length),
              'tasks length preserved',
              1,
            ),
      ],
    );

    blocTest<TaskListCubit, TaskListState>(
      'clearActionError resets actionErrorMessage to null',
      build: () => _buildCubit(_FakeTaskRepository()),
      seed: () => TaskListState.loaded(
        tasks: <Task>[_sampleTask],
        searchQuery: '',
        filterStatus: TaskStatus.pending,
        filterCategoryId: null,
        actionErrorMessage: 'An error occurred',
      ),
      act: (TaskListCubit cubit) => cubit.clearActionError(),
      expect: () => <dynamic>[
        isA<TaskListState>().having(
          (s) => s.mapOrNull(loaded: (l) => l.actionErrorMessage),
          'actionErrorMessage is null',
          isNull,
        ),
      ],
    );
  });

  group('TaskListCubit notification triggers', () {
    test('changeTaskStatus to inProgress schedules task timer', () async {
      final fakeNotif = _FakeNotificationService();
      final cubit = _buildCubit(_FakeTaskRepository(), notificationService: fakeNotif);

      await cubit.changeTaskStatus(_sampleTask, TaskStatus.inProgress);
      expect(fakeNotif.scheduledTimers, 1);
    });

    test('changeTaskStatus to completed cancels timer and celebrates', () async {
      final fakeNotif = _FakeNotificationService();
      final cubit = _buildCubit(_FakeTaskRepository(), notificationService: fakeNotif);

      await cubit.changeTaskStatus(_sampleTask, TaskStatus.completed);
      expect(fakeNotif.cancelledTimers, 1);
      expect(fakeNotif.celebrations, 1);
    });

    test('changeTaskStatus to pending cancels timer', () async {
      final fakeNotif = _FakeNotificationService();
      final cubit = _buildCubit(_FakeTaskRepository(), notificationService: fakeNotif);

      await cubit.changeTaskStatus(
        _sampleTask.copyWith(status: TaskStatus.inProgress),
        TaskStatus.pending,
      );
      expect(fakeNotif.cancelledTimers, 1);
    });
  });
}
