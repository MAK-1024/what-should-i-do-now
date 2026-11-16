import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wsidappp/config/routes/route_list.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/di/injection.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_cubit.dart';
import 'package:wsidappp/features/suggestion/presentation/cubit/suggestion_cubit.dart';
import 'package:wsidappp/features/suggestion/presentation/cubit/suggestion_state.dart';
import 'package:wsidappp/features/suggestion/presentation/widgets/home_suggestion_page_widgets/sections/decider_section.dart';
import 'package:wsidappp/features/suggestion/presentation/widgets/home_suggestion_page_widgets/sections/home_brand_title.dart';
import 'package:wsidappp/features/suggestion/presentation/widgets/home_suggestion_page_widgets/sections/pending_tasks_section.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_cubit.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_state.dart';
import 'package:wsidappp/shared/widgets/custom_app_bar.dart';

/// The core decider screen allowing users to get randomized task suggestions.
class HomeSuggestionPage extends StatelessWidget {
  const HomeSuggestionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SuggestionCubit>(
      create: (_) => getIt<SuggestionCubit>()..checkActiveTask(),
      child: const _HomeSuggestionView(),
    );
  }
}

class _HomeSuggestionView extends StatefulWidget {
  const _HomeSuggestionView();

  @override
  State<_HomeSuggestionView> createState() => _HomeSuggestionViewState();
}

class _HomeSuggestionViewState extends State<_HomeSuggestionView> {
  @override
  void initState() {
    super.initState();
    _refreshBacklog();
  }

  Future<void> _refreshBacklog() => Future.wait(<Future<void>>[
        context.read<TaskListCubit>().loadTasks(),
        context.read<CategoryCubit>().loadCategories(),
      ]);

  bool _isLoading(SuggestionState state) =>
      state.maybeWhen(loading: () => true, orElse: () => false);

  bool _isSuggestion(SuggestionState state) =>
      state.maybeWhen(hasSuggestion: (_, _) => true, orElse: () => false);

  /// Called on a fresh suggestion, or when a mutation (`loading`) settles.
  void _onSuggestionStateChanged(BuildContext context, SuggestionState current) {
    if (_isSuggestion(current)) {
      HapticFeedback.heavyImpact();
      return;
    }

    final String? mutationError = current.maybeWhen(
      error: (String message) => message,
      orElse: () => null,
    );
    if (mutationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mutationError),
          backgroundColor: context.colors.error,
        ),
      );
      return;
    }
    context.read<TaskListCubit>().loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleWidget: const HomeBrandTitle(),
        centerTitle: false,
        showBackButton: false,
        toolbarHeight: 88,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: context.l10n.profile,
            onPressed: () => context.push(RouteList.profile),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<SuggestionCubit, SuggestionState>(
            listenWhen: (SuggestionState previous, SuggestionState current) =>
                _isSuggestion(current) ||
                (_isLoading(previous) && !_isLoading(current)),
            listener: _onSuggestionStateChanged,
          ),
          BlocListener<TaskListCubit, TaskListState>(
            listenWhen: (_, TaskListState current) =>
                current.mapOrNull(loaded: (l) => l.actionErrorMessage) != null,
            listener: (BuildContext context, TaskListState state) {
              final String? message =
                  state.mapOrNull(loaded: (l) => l.actionErrorMessage);
              if (message == null) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: context.colors.error,
                ),
              );
              context.read<TaskListCubit>().clearActionError();
            },
          ),
        ],
        child: RefreshIndicator(
          onRefresh: _refreshBacklog,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(height: 16),
                    DeciderSection(),
                    SizedBox(height: 40),
                    PendingTasksSection(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
