import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_cubit.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_state.dart';

/// Rounded search field filtering tasks by title or description.
class TaskSearchBar extends StatefulWidget {
  const TaskSearchBar({super.key});

  @override
  State<TaskSearchBar> createState() => _TaskSearchBarState();
}

class _TaskSearchBarState extends State<TaskSearchBar> {
  late final TextEditingController _controller = TextEditingController(
    text: context.read<TaskListCubit>().state.mapOrNull(
          loaded: (l) => l.searchQuery,
        ) ?? '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    context.read<TaskListCubit>().setSearchQuery('');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TextField(
      controller: _controller,
      textInputAction: TextInputAction.search,
      onChanged: context.read<TaskListCubit>().setSearchQuery,
      decoration: InputDecoration(
        hintText: l10n.searchTasks,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (BuildContext context, TextEditingValue value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              tooltip: l10n.clearSearch,
              icon: const Icon(Icons.close),
              onPressed: _clear,
            );
          },
        ),
        border: OutlineInputBorder(
          borderRadius: context.radius.full,
          borderSide: BorderSide(color: context.colors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: context.radius.full,
          borderSide: BorderSide(color: context.colors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: context.radius.full,
          borderSide: BorderSide(color: context.colors.primary, width: 2),
        ),
      ),
    );
  }
}
