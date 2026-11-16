import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/features/categories/domain/entities/category.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_cubit.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_state.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_cubit.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_state.dart';

/// Horizontally scrolling category filter: "All" followed by each category.
class TaskCategoryFilterChips extends StatelessWidget {
  const TaskCategoryFilterChips({super.key, this.padding = EdgeInsets.zero});

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final List<Category> categories =
        context.select<CategoryCubit, List<Category>>(
      (CategoryCubit cubit) => cubit.state.maybeWhen(
        loaded: (List<Category> categories, _) => categories,
        orElse: () => const <Category>[],
      ),
    );
    final String? selectedId = context.select<TaskListCubit, String?>(
      (TaskListCubit cubit) =>
          cubit.state.mapOrNull(loaded: (l) => l.filterCategoryId),
    );
    final TaskListCubit cubit = context.read<TaskListCubit>();

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: padding,
        children: <Widget>[
          _FilterChip(
            label: context.l10n.all,
            selected: selectedId == null,
            onTap: () => cubit.setCategoryFilter(null),
          ),
          for (final Category category in categories)
            _FilterChip(
              label: category.name,
              selected: selectedId == category.id,
              onTap: () => cubit.setCategoryFilter(category.id),
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onTap(),
        backgroundColor: context.colors.surface,
        selectedColor: context.colors.primaryContainer,
        side: BorderSide(
          color: selected
              ? context.colors.primary
              : context.colors.outlineVariant,
          width: selected ? 1.5 : 1,
        ),
        labelStyle: context.txt.labelLarge?.copyWith(
          color: selected
              ? context.colors.primary
              : context.colors.onSurfaceVariant,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}
