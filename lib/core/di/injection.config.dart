// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;
import 'package:wsidappp/core/di/register_module.dart' as _i151;
import 'package:wsidappp/core/network/network_cubit.dart' as _i178;
import 'package:wsidappp/core/network/network_info.dart' as _i739;
import 'package:wsidappp/core/network/network_info_impl.dart' as _i108;
import 'package:wsidappp/core/services/notification_service.dart' as _i1002;
import 'package:wsidappp/core/settings/app_settings_cubit.dart' as _i977;
import 'package:wsidappp/features/auth/data/repositories/auth_repository_impl.dart'
    as _i899;
import 'package:wsidappp/features/auth/domain/repositories/auth_repository.dart'
    as _i847;
import 'package:wsidappp/features/auth/domain/usecases/get_current_profile_use_case.dart'
    as _i877;
import 'package:wsidappp/features/auth/domain/usecases/sign_in_use_case.dart'
    as _i689;
import 'package:wsidappp/features/auth/domain/usecases/sign_out_use_case.dart'
    as _i432;
import 'package:wsidappp/features/auth/domain/usecases/sign_up_use_case.dart'
    as _i653;
import 'package:wsidappp/features/auth/presentation/cubit/auth_cubit.dart'
    as _i95;
import 'package:wsidappp/features/categories/data/repositories/category_repository_impl.dart'
    as _i837;
import 'package:wsidappp/features/categories/domain/repositories/category_repository.dart'
    as _i890;
import 'package:wsidappp/features/categories/domain/usecases/create_category_use_case.dart'
    as _i751;
import 'package:wsidappp/features/categories/domain/usecases/delete_category_use_case.dart'
    as _i187;
import 'package:wsidappp/features/categories/domain/usecases/get_categories_use_case.dart'
    as _i656;
import 'package:wsidappp/features/categories/presentation/cubit/category_cubit.dart'
    as _i1051;
import 'package:wsidappp/features/profile/data/repositories/profile_repository_impl.dart'
    as _i132;
import 'package:wsidappp/features/profile/domain/repositories/profile_repository.dart'
    as _i1016;
import 'package:wsidappp/features/profile/domain/usecases/delete_account_use_case.dart'
    as _i321;
import 'package:wsidappp/features/profile/domain/usecases/update_profile_use_case.dart'
    as _i90;
import 'package:wsidappp/features/profile/presentation/cubit/profile_cubit.dart'
    as _i676;
import 'package:wsidappp/features/suggestion/data/repositories/suggestion_repository_impl.dart'
    as _i105;
import 'package:wsidappp/features/suggestion/domain/repositories/suggestion_repository.dart'
    as _i529;
import 'package:wsidappp/features/suggestion/domain/usecases/get_random_suggestion_use_case.dart'
    as _i237;
import 'package:wsidappp/features/suggestion/presentation/cubit/suggestion_cubit.dart'
    as _i242;
import 'package:wsidappp/features/tasks/data/repositories/task_repository_impl.dart'
    as _i799;
import 'package:wsidappp/features/tasks/domain/repositories/task_repository.dart'
    as _i468;
import 'package:wsidappp/features/tasks/domain/usecases/complete_task_use_case.dart'
    as _i956;
import 'package:wsidappp/features/tasks/domain/usecases/create_task_use_case.dart'
    as _i1068;
import 'package:wsidappp/features/tasks/domain/usecases/delete_task_use_case.dart'
    as _i717;
import 'package:wsidappp/features/tasks/domain/usecases/get_active_task_use_case.dart'
    as _i94;
import 'package:wsidappp/features/tasks/domain/usecases/get_tasks_use_case.dart'
    as _i133;
import 'package:wsidappp/features/tasks/domain/usecases/return_task_to_pool_use_case.dart'
    as _i990;
import 'package:wsidappp/features/tasks/domain/usecases/take_task_use_case.dart'
    as _i1026;
import 'package:wsidappp/features/tasks/domain/usecases/update_task_use_case.dart'
    as _i606;
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_cubit.dart'
    as _i992;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i454.SupabaseClient>(() => registerModule.supabaseClient);
    gh.lazySingleton<_i895.Connectivity>(() => registerModule.connectivity);
    await gh.lazySingletonAsync<_i460.SharedPreferences>(
      () => registerModule.sharedPreferences,
      preResolve: true,
    );
    gh.lazySingleton<_i529.SuggestionRepository>(
      () => _i105.SuggestionRepositoryImpl(gh<_i454.SupabaseClient>()),
    );
    gh.factory<_i237.GetRandomSuggestionUseCase>(
      () => _i237.GetRandomSuggestionUseCase(gh<_i529.SuggestionRepository>()),
    );
    gh.lazySingleton<_i890.CategoryRepository>(
      () => _i837.CategoryRepositoryImpl(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i1016.ProfileRepository>(
      () => _i132.ProfileRepositoryImpl(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i468.TaskRepository>(
      () => _i799.TaskRepositoryImpl(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i847.AuthRepository>(
      () => _i899.AuthRepositoryImpl(gh<_i454.SupabaseClient>()),
    );
    gh.factory<_i877.GetCurrentProfileUseCase>(
      () => _i877.GetCurrentProfileUseCase(gh<_i847.AuthRepository>()),
    );
    gh.factory<_i689.SignInUseCase>(
      () => _i689.SignInUseCase(gh<_i847.AuthRepository>()),
    );
    gh.factory<_i432.SignOutUseCase>(
      () => _i432.SignOutUseCase(gh<_i847.AuthRepository>()),
    );
    gh.factory<_i653.SignUpUseCase>(
      () => _i653.SignUpUseCase(gh<_i847.AuthRepository>()),
    );
    gh.factory<_i751.CreateCategoryUseCase>(
      () => _i751.CreateCategoryUseCase(gh<_i890.CategoryRepository>()),
    );
    gh.factory<_i187.DeleteCategoryUseCase>(
      () => _i187.DeleteCategoryUseCase(gh<_i890.CategoryRepository>()),
    );
    gh.factory<_i656.GetCategoriesUseCase>(
      () => _i656.GetCategoriesUseCase(gh<_i890.CategoryRepository>()),
    );
    gh.lazySingleton<_i1002.NotificationService>(
      () => _i1002.NotificationService(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i95.AuthCubit>(
      () => _i95.AuthCubit(
        gh<_i689.SignInUseCase>(),
        gh<_i653.SignUpUseCase>(),
        gh<_i432.SignOutUseCase>(),
        gh<_i877.GetCurrentProfileUseCase>(),
        gh<_i847.AuthRepository>(),
      ),
    );
    gh.factory<_i956.CompleteTaskUseCase>(
      () => _i956.CompleteTaskUseCase(gh<_i468.TaskRepository>()),
    );
    gh.factory<_i1068.CreateTaskUseCase>(
      () => _i1068.CreateTaskUseCase(gh<_i468.TaskRepository>()),
    );
    gh.factory<_i717.DeleteTaskUseCase>(
      () => _i717.DeleteTaskUseCase(gh<_i468.TaskRepository>()),
    );
    gh.factory<_i94.GetActiveTaskUseCase>(
      () => _i94.GetActiveTaskUseCase(gh<_i468.TaskRepository>()),
    );
    gh.factory<_i133.GetTasksUseCase>(
      () => _i133.GetTasksUseCase(gh<_i468.TaskRepository>()),
    );
    gh.factory<_i990.ReturnTaskToPoolUseCase>(
      () => _i990.ReturnTaskToPoolUseCase(gh<_i468.TaskRepository>()),
    );
    gh.factory<_i1026.TakeTaskUseCase>(
      () => _i1026.TakeTaskUseCase(gh<_i468.TaskRepository>()),
    );
    gh.factory<_i606.UpdateTaskUseCase>(
      () => _i606.UpdateTaskUseCase(gh<_i468.TaskRepository>()),
    );
    gh.lazySingleton<_i739.NetworkInfo>(
      () => _i108.NetworkInfoImpl(gh<_i895.Connectivity>()),
    );
    gh.factory<_i992.TaskListCubit>(
      () => _i992.TaskListCubit(
        gh<_i133.GetTasksUseCase>(),
        gh<_i1068.CreateTaskUseCase>(),
        gh<_i606.UpdateTaskUseCase>(),
        gh<_i717.DeleteTaskUseCase>(),
        gh<_i1026.TakeTaskUseCase>(),
        gh<_i956.CompleteTaskUseCase>(),
        gh<_i990.ReturnTaskToPoolUseCase>(),
        gh<_i1002.NotificationService>(),
      ),
    );
    gh.factory<_i321.DeleteAccountUseCase>(
      () => _i321.DeleteAccountUseCase(gh<_i1016.ProfileRepository>()),
    );
    gh.factory<_i90.UpdateProfileUseCase>(
      () => _i90.UpdateProfileUseCase(gh<_i1016.ProfileRepository>()),
    );
    gh.lazySingleton<_i178.NetworkCubit>(
      () => _i178.NetworkCubit(gh<_i739.NetworkInfo>()),
    );
    gh.factory<_i676.ProfileCubit>(
      () => _i676.ProfileCubit(
        gh<_i877.GetCurrentProfileUseCase>(),
        gh<_i90.UpdateProfileUseCase>(),
        gh<_i321.DeleteAccountUseCase>(),
      ),
    );
    gh.lazySingleton<_i977.AppSettingsCubit>(
      () => _i977.AppSettingsCubit(
        gh<_i460.SharedPreferences>(),
        gh<_i1002.NotificationService>(),
      ),
    );
    gh.factory<_i242.SuggestionCubit>(
      () => _i242.SuggestionCubit(
        gh<_i237.GetRandomSuggestionUseCase>(),
        gh<_i94.GetActiveTaskUseCase>(),
        gh<_i1026.TakeTaskUseCase>(),
        gh<_i956.CompleteTaskUseCase>(),
        gh<_i990.ReturnTaskToPoolUseCase>(),
        gh<_i1002.NotificationService>(),
      ),
    );
    gh.factory<_i1051.CategoryCubit>(
      () => _i1051.CategoryCubit(
        gh<_i656.GetCategoriesUseCase>(),
        gh<_i751.CreateCategoryUseCase>(),
        gh<_i187.DeleteCategoryUseCase>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i151.RegisterModule {}
