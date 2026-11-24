import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide Task;
import 'package:wsidappp/core/constants/app_assets.dart';
import 'package:wsidappp/core/errors/failure.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/core/services/notification_service.dart';
import 'package:wsidappp/features/categories/domain/entities/category.dart';
import 'package:wsidappp/features/categories/domain/repositories/category_repository.dart';
import 'package:wsidappp/features/categories/domain/usecases/create_category_use_case.dart';
import 'package:wsidappp/features/categories/domain/usecases/delete_category_use_case.dart';
import 'package:wsidappp/features/categories/domain/usecases/get_categories_use_case.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_cubit.dart';
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
import 'package:wsidappp/features/tasks/presentation/pages/tasks_page.dart';

class _MockNotificationService implements NotificationService {
  @override
  Future<void> cancelTaskTimer() async {}
  @override
  Future<void> scheduleTaskTimer(Task task) async {}
  @override
  Future<void> showTaskCompletedCelebration(Task task) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeTaskRepo implements TaskRepository {
  _FakeTaskRepo({this.tasks = const []});
  final List<Task> tasks;

  @override
  Future<Either<Failure, List<Task>>> getTasks({String? categoryId, TaskStatus? status}) async =>
      right(tasks);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCategoryRepo implements CategoryRepository {
  @override
  Future<Either<Failure, List<Category>>> getCategories() async => right([]);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildWidget({List<Task> tasks = const []}) {
    final taskRepo = _FakeTaskRepo(tasks: tasks);
    final catRepo = _FakeCategoryRepo();
    final notifService = _MockNotificationService();

    final taskListCubit = TaskListCubit(
      GetTasksUseCase(taskRepo),
      CreateTaskUseCase(taskRepo),
      UpdateTaskUseCase(taskRepo),
      DeleteTaskUseCase(taskRepo),
      TakeTaskUseCase(taskRepo),
      CompleteTaskUseCase(taskRepo),
      ReturnTaskToPoolUseCase(taskRepo),
      notifService,
    );

    final catCubit = CategoryCubit(
      GetCategoriesUseCase(catRepo),
      CreateCategoryUseCase(catRepo),
      DeleteCategoryUseCase(catRepo),
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<TaskListCubit>.value(value: taskListCubit),
        BlocProvider<CategoryCubit>.value(value: catCubit),
      ],
      child: const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: TasksPage(),
      ),
    );
  }

  testWidgets('renders to do and done tabs and shows corresponding empty states',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildWidget(tasks: []));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Tab labels
    expect(find.text('to do'), findsOneWidget);
    expect(find.text('done'), findsOneWidget);

    // Initial tab is "to do", empty state:
    expect(find.text('no tasks ... yet!'), findsOneWidget);
    expect(
      find.text('Add some tasks and let\'s get things rolling!'),
      findsOneWidget,
    );

    // Switch to "done" tab
    await tester.tap(find.text('done'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Empty state for "done" tab matching Figma design:
    expect(find.text('no completed tasks'), findsOneWidget);
    expect(
      find.text('finished tasks show up here. let\'s get to it!'),
      findsOneWidget,
    );

    // Verify star asset is rendered for completed empty state
    final starFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName == AppAssets.star,
    );
    expect(starFinder, findsOneWidget);
  });
}
