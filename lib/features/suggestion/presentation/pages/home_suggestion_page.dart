import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/di/injection.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_cubit.dart';
import 'package:wsidappp/features/suggestion/presentation/cubit/suggestion_cubit.dart';
import 'package:wsidappp/features/suggestion/presentation/cubit/suggestion_state.dart';
import 'package:wsidappp/features/suggestion/presentation/widgets/home_suggestion_page_widgets/cards/active_task_card.dart';
import 'package:wsidappp/features/suggestion/presentation/widgets/home_suggestion_page_widgets/sections/decider_section.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';
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
      appBar: const WsidAppBar.logo(
        onLeadingPressed: null,
        onNotificationsPressed: null,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 16),
                    const DeciderSection(),
                    BlocBuilder<TaskListCubit, TaskListState>(
                      builder: (BuildContext context, TaskListState state) {
                        final Task? activeTask = state.mapOrNull(
                          loaded: (l) {
                            for (final Task t in l.tasks) {
                              if (t.status == TaskStatus.inProgress) return t;
                            }
                            return null;
                          },
                        );
                        if (activeTask == null) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: ActiveTaskCard(task: activeTask),
                        );
                      },
                    ),
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
