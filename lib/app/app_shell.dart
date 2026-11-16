import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wsidappp/app/widgets/shell_nav_item.dart';
import 'package:wsidappp/config/routes/route_list.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/di/injection.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_cubit.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_cubit.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_state.dart';
import 'package:wsidappp/features/tasks/presentation/widgets/tasks_page_widgets/dialogs/create_task_sheet.dart';

/// Application shell providing persistent bottom navigation, a central
/// create-task action, and the task/category cubits shared by shell tabs.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TaskListCubit>(create: (_) => getIt<TaskListCubit>()),
        BlocProvider<CategoryCubit>(create: (_) => getIt<CategoryCubit>()),
      ],
      child: _ShellScaffold(child: child),
    );
  }
}

class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({required this.child});

  final Widget child;

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(RouteList.tasks)) return 1;
    if (location.startsWith(RouteList.categories)) return 2;
    if (location.startsWith(RouteList.profile)) return 3;
    return 0;
  }

  Future<void> _openCreateTaskSheet(BuildContext context) async {
    unawaited(HapticFeedback.lightImpact());
    final taskListCubit = context.read<TaskListCubit>();
    final categoryCubit = context.read<CategoryCubit>();
    await categoryCubit.loadCategories();
    if (!context.mounted) return;
    await CreateTaskSheet.show(
      context,
      taskListCubit: taskListCubit,
      categoryCubit: categoryCubit,
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _selectedIndex(context);
    final l10n = context.l10n;

    return BlocListener<TaskListCubit, TaskListState>(
      listenWhen: (_, TaskListState current) => _actionFailure(current) != null,
      listener: (BuildContext context, TaskListState state) {
        final TaskActionFailure? failure = _actionFailure(state);
        if (failure == null) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              failure.when(
                activeTaskExists: () => l10n.activeTaskExists,
                server: (String message) => message,
              ),
            ),
            backgroundColor: context.colors.error,
          ),
        );
        context.read<TaskListCubit>().clearActionError();
      },
      child: _buildScaffold(context, selectedIndex, l10n),
    );
  }

  TaskActionFailure? _actionFailure(TaskListState state) =>
      state.mapOrNull(loaded: (l) => l.actionFailure);

  void _onDestinationSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(RouteList.home);
      case 1:
        context.go(RouteList.tasks);
      case 2:
        context.go(RouteList.categories);
      case 3:
        context.go(RouteList.profile);
    }
  }

  Widget _buildScaffold(
    BuildContext context,
    int selectedIndex,
    AppLocalizations l10n,
  ) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) =>
          constraints.maxWidth < _wideLayoutBreakpoint
              ? _buildMobileScaffold(context, selectedIndex, l10n)
              : _buildWideScaffold(context, selectedIndex, l10n),
    );
  }

  static const double _wideLayoutBreakpoint = 700;
  static const double _maxContentWidth = 680;

  Widget _buildWideScaffold(
    BuildContext context,
    int selectedIndex,
    AppLocalizations l10n,
  ) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: <Widget>[
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (int index) =>
                  _onDestinationSelected(context, index),
              labelType: NavigationRailLabelType.all,
              groupAlignment: -0.9,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: FloatingActionButton(
                  heroTag: null,
                  elevation: 1,
                  tooltip: l10n.newTask,
                  shape: const CircleBorder(),
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.onPrimary,
                  onPressed: () => _openCreateTaskSheet(context),
                  child: const Icon(Icons.add, size: 28),
                ),
              ),
              destinations: <NavigationRailDestination>[
                NavigationRailDestination(
                  icon: const Icon(Icons.casino_outlined),
                  selectedIcon: const Icon(Icons.casino),
                  label: Text(l10n.decide),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.checklist_outlined),
                  selectedIcon: const Icon(Icons.checklist),
                  label: Text(l10n.tasks),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.folder_outlined),
                  selectedIcon: const Icon(Icons.folder),
                  label: Text(l10n.categories),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.person_outline),
                  selectedIcon: const Icon(Icons.person),
                  label: Text(l10n.profile),
                ),
              ],
            ),
            VerticalDivider(width: 1, color: context.colors.outlineVariant),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _maxContentWidth),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileScaffold(
    BuildContext context,
    int selectedIndex,
    AppLocalizations l10n,
  ) {
    return Scaffold(
      body: child,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        tooltip: l10n.newTask,
        shape: const CircleBorder(),
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.onPrimary,
        onPressed: () => _openCreateTaskSheet(context),
        child: const Icon(Icons.add, size: 30),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        padding: EdgeInsets.zero,
        child: Row(
          children: <Widget>[
            ShellNavItem(
              icon: Icons.casino_outlined,
              selectedIcon: Icons.casino,
              label: l10n.decide,
              selected: selectedIndex == 0,
              onTap: () => _onDestinationSelected(context, 0),
            ),
            ShellNavItem(
              icon: Icons.checklist_outlined,
              selectedIcon: Icons.checklist,
              label: l10n.tasks,
              selected: selectedIndex == 1,
              onTap: () => _onDestinationSelected(context, 1),
            ),
            const SizedBox(width: 72),
            ShellNavItem(
              icon: Icons.folder_outlined,
              selectedIcon: Icons.folder,
              label: l10n.categories,
              selected: selectedIndex == 2,
              onTap: () => _onDestinationSelected(context, 2),
            ),
            ShellNavItem(
              icon: Icons.person_outline,
              selectedIcon: Icons.person,
              label: l10n.profile,
              selected: selectedIndex == 3,
              onTap: () => _onDestinationSelected(context, 3),
            ),
          ],
        ),
      ),
    );
  }
}
