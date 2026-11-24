import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_cubit.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_state.dart';
import 'package:wsidappp/shared/widgets/wsid_text_field.dart';

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
    return WsidTextField(
      controller: _controller,
      label: l10n.searchTasks,
      hintText: l10n.searchTasks,
      prefixIcon: Icons.search,
      textInputAction: TextInputAction.search,
      showLabel: false,
      onChanged: context.read<TaskListCubit>().setSearchQuery,
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
    );
  }
}
