import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/constants/task_duration_presets.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/features/auth/presentation/widgets/auth_page_widgets/shared/auth_field_label.dart';
import 'package:wsidappp/features/categories/domain/entities/category.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_cubit.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_state.dart';
import 'package:wsidappp/features/categories/presentation/pages/add_category_page.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';
import 'package:wsidappp/features/tasks/presentation/widgets/tasks_page_widgets/shared/task_selection_chip.dart';
import 'package:wsidappp/features/tasks/presentation/widgets/tasks_page_widgets/shared/task_status_badge.dart';

/// Shared add/edit task form (`333:1834`, `446:3056`).
class TaskFormBody extends StatelessWidget {
  const TaskFormBody({
    super.key,
    required this.titleController,
    required this.notesController,
    required this.linkController,
    required this.selectedCategoryId,
    required this.selectedPriority,
    required this.selectedDurationMinutes,
    required this.onCategorySelected,
    required this.onPrioritySelected,
    required this.onDurationSelected,
    this.showLinkClear = false,
    this.onLinkClear,
    this.titleValidator,
  });

  final TextEditingController titleController;
  final TextEditingController notesController;
  final TextEditingController linkController;
  final String? selectedCategoryId;
  final TaskPriority selectedPriority;
  final int? selectedDurationMinutes;
  final ValueChanged<String> onCategorySelected;
  final ValueChanged<TaskPriority> onPrioritySelected;
  final ValueChanged<int?> onDurationSelected;
  final bool showLinkClear;
  final VoidCallback? onLinkClear;
  final String? Function(String?)? titleValidator;

  Future<void> _openCustomDuration(BuildContext context) async {
    final l10n = context.l10n;
    final TextEditingController minutesController = TextEditingController();
    final int? value = await showDialog<int>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: dialogContext.radius.lg),
          title: Text(l10n.customDurationTitle),
          content: TextField(
            controller: minutesController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: l10n.customDurationHint),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                final int? parsed = int.tryParse(minutesController.text.trim());
                if (parsed == null || parsed <= 0) return;
                Navigator.of(dialogContext).pop(parsed);
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
    minutesController.dispose();
    if (value != null) onDurationSelected(value);
  }

  void _openAddCategory(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider<CategoryCubit>.value(
          value: context.read<CategoryCubit>(),
          child: const AddCategoryPage(),
        ),
      ),
    );
  }

  String _durationLabel(AppLocalizations l10n, int minutes) =>
      minutes == 60 ? l10n.durationOneHour : l10n.durationPreset(minutes);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (BuildContext context, CategoryState categoryState) {
        final List<Category> categories = categoryState.maybeWhen(
          loaded: (List<Category> items, _) => items,
          orElse: () => const <Category>[],
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _TaskNameField(
              controller: titleController,
              label: l10n.taskNameLabel,
              hintText: l10n.taskNamePlaceholder,
              helperText: l10n.keepItShort,
              validator: titleValidator,
            ),
            const SizedBox(height: 16),
            _NotesField(
              controller: notesController,
              label: l10n.notesSection,
              hintText: l10n.notesPlaceholder,
            ),
            const SizedBox(height: 16),
            _LinkField(
              controller: linkController,
              label: l10n.linkSection,
              hintText: l10n.pasteLinkPlaceholder,
              showClear: showLinkClear,
              onClear: onLinkClear,
            ),
            const SizedBox(height: 16),
            _ChipSection(
              title: l10n.category,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (final Category category in categories)
                    TaskSelectionChip(
                      label: category.name,
                      selected: category.id == selectedCategoryId,
                      onTap: () => onCategorySelected(category.id),
                    ),
                  TaskSelectionChip.add(
                    onTap: () => _openAddCategory(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _ChipSection(
              title: l10n.priority,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TaskPriority.values.map((TaskPriority priority) {
                  return TaskSelectionChip(
                    label: priority.chipLabel(l10n),
                    selected: priority == selectedPriority,
                    onTap: () => onPrioritySelected(priority),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            _ChipSection(
              title: l10n.timeNeeded,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (final int minutes in TaskDurationPresets.minutes)
                    TaskSelectionChip(
                      label: _durationLabel(l10n, minutes),
                      selected: selectedDurationMinutes == minutes,
                      onTap: () => onDurationSelected(minutes),
                    ),
                  TaskSelectionChip.add(
                    onTap: () => _openCustomDuration(context),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ChipSection extends StatelessWidget {
  const _ChipSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: context.typo.bodyBold.copyWith(color: context.brand.sectionLabel),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _NotesField extends StatelessWidget {
  const _NotesField({
    required this.controller,
    required this.label,
    required this.hintText,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AuthFieldLabel(label: label),
        TextFormField(
          controller: controller,
          minLines: 2,
          maxLines: 4,
          style: context.typo.body.copyWith(color: brand.headlineText),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: context.typo.body.copyWith(color: brand.hintText),
            filled: true,
            fillColor: brand.inputFill,
            alignLabelWithHint: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Icon(Icons.notes_outlined, color: brand.iconMuted, size: 24),
            ),
            prefixIconConstraints: const BoxConstraints(minHeight: 48),
            border: OutlineInputBorder(
              borderRadius: context.radius.md,
              borderSide: BorderSide(color: brand.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: context.radius.md,
              borderSide: BorderSide(color: brand.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: context.radius.md,
              borderSide: BorderSide(color: brand.inputBorderFocused, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _TaskNameField extends StatelessWidget {
  const _TaskNameField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.helperText,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final String helperText;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              label,
              style: context.typo.title1Bold.copyWith(color: brand.fieldLabel),
            ),
            Text(
              ' *',
              style: context.typo.body.copyWith(color: context.colors.error),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          style: context.typo.body.copyWith(color: brand.fieldValue),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: context.typo.body.copyWith(color: brand.hintText),
            filled: true,
            fillColor: brand.inputFill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            prefixIcon: Icon(
              Icons.edit_outlined,
              color: brand.iconMuted,
              size: 24,
            ),
            border: OutlineInputBorder(
              borderRadius: context.radius.md,
              borderSide: BorderSide(color: brand.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: context.radius.md,
              borderSide: BorderSide(color: brand.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: context.radius.md,
              borderSide: BorderSide(color: brand.inputBorderFocused, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: context.radius.md,
              borderSide: BorderSide(color: context.colors.error),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          helperText,
          style: context.metaTextStyle,
        ),
      ],
    );
  }
}

class _LinkField extends StatelessWidget {
  const _LinkField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.showClear,
    this.onClear,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final bool showClear;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AuthFieldLabel(label: label),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.url,
          style: context.typo.body.copyWith(color: brand.headlineText),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: context.typo.body.copyWith(color: brand.hintText),
            filled: true,
            fillColor: brand.inputFill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            prefixIcon: Icon(Icons.link, color: brand.iconMuted, size: 24),
            suffixIcon: showClear
                ? IconButton(
                    icon: Icon(Icons.close, color: brand.iconMuted),
                    onPressed: onClear,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: context.radius.md,
              borderSide: BorderSide(color: brand.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: context.radius.md,
              borderSide: BorderSide(color: brand.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: context.radius.md,
              borderSide: BorderSide(color: brand.inputBorderFocused, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}