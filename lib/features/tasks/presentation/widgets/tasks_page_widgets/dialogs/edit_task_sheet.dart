import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wsidappp/config/theme/app_colors.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/features/categories/domain/entities/category.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_cubit.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_state.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_cubit.dart';
import 'package:wsidappp/features/tasks/presentation/widgets/tasks_page_widgets/shared/task_status_badge.dart';

/// Bottom sheet for editing an existing [Task].
class EditTaskSheet extends StatefulWidget {
  const EditTaskSheet({
    super.key,
    required this.task,
    required this.taskListCubit,
    required this.categoryCubit,
  });

  final Task task;
  final TaskListCubit taskListCubit;
  final CategoryCubit categoryCubit;

  static Future<void> show(
    BuildContext context, {
    required Task task,
    required TaskListCubit taskListCubit,
    required CategoryCubit categoryCubit,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      constraints: const BoxConstraints(maxWidth: 600),
      isScrollControlled: true,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: context.radius.lg.topLeft),
      ),
      builder: (_) => EditTaskSheet(
        task: task,
        taskListCubit: taskListCubit,
        categoryCubit: categoryCubit,
      ),
    );
  }

  @override
  State<EditTaskSheet> createState() => _EditTaskSheetState();
}

class _EditTaskSheetState extends State<EditTaskSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController =
      TextEditingController(text: widget.task.title);
  late final TextEditingController _durationController = TextEditingController(
    text: widget.task.estimatedDuration?.toString() ?? '',
  );
  late final TextEditingController _linkController =
      TextEditingController(text: widget.task.link ?? '');
  late final TextEditingController _notesController =
      TextEditingController(text: widget.task.description ?? '');

  late String _categoryId = widget.task.categoryId;
  late TaskPriority _priority = widget.task.priority;
  bool _saving = false;
  bool _saveFailed = false;

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    _linkController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _nullIfBlank(String value) {
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _submit() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _saving = true;
      _saveFailed = false;
    });

    final String durationText = _durationController.text.trim();
    final Task updated = widget.task.copyWith(
      title: _titleController.text.trim(),
      categoryId: _categoryId,
      priority: _priority,
      estimatedDuration: durationText.isEmpty ? null : int.parse(durationText),
      link: _nullIfBlank(_linkController.text),
      description: _nullIfBlank(_notesController.text),
    );

    final bool succeeded = await widget.taskListCubit.updateTask(updated);
    if (!mounted) return;
    if (succeeded) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _saving = false;
        _saveFailed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<CategoryCubit, CategoryState>(
      bloc: widget.categoryCubit,
      builder: (BuildContext context, CategoryState categoryState) {
        final List<Category> categories = categoryState.maybeWhen(
          loaded: (List<Category> categories, _) => categories,
          orElse: () => const <Category>[],
        );
        final bool categoryKnown =
            categories.any((Category c) => c.id == _categoryId);

        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            0,
            20,
            24 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    l10n.editTask,
                    style: context.txt.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _titleController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(labelText: l10n.taskTitle),
                    validator: (String? value) =>
                        (value == null || value.trim().isEmpty)
                            ? l10n.taskTitleRequired
                            : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: categoryKnown ? _categoryId : null,
                    decoration: InputDecoration(labelText: l10n.category),
                    items: categories
                        .map(
                          (Category category) => DropdownMenuItem<String>(
                            value: category.id,
                            child: Row(
                              children: <Widget>[
                                CircleAvatar(
                                  radius: 5,
                                  backgroundColor:
                                      AppColors.parseHexColor(category.color) ??
                                          context.colors.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(category.name),
                              ],
                            ),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (String? value) {
                      if (value != null) setState(() => _categoryId = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.priority,
                    style: context.txt.labelLarge?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: TaskPriority.values
                        .map(
                          (TaskPriority priority) => ChoiceChip(
                            label: Text(priority.label(l10n)),
                            selected: _priority == priority,
                            onSelected: (bool selected) {
                              if (selected) {
                                setState(() => _priority = priority);
                              }
                            },
                          ),
                        )
                        .toList(growable: false),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          controller: _durationController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.estimatedMinutes,
                          ),
                          validator: (String? value) {
                            final String text = value?.trim() ?? '';
                            if (text.isEmpty) return null;
                            final int? parsed = int.tryParse(text);
                            return (parsed == null || parsed <= 0)
                                ? l10n.positiveNumber
                                : null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _linkController,
                          keyboardType: TextInputType.url,
                          decoration: InputDecoration(labelText: l10n.link),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 4,
                    minLines: 2,
                    decoration: InputDecoration(labelText: l10n.notesLabel),
                  ),
                  if (_saveFailed) ...<Widget>[
                    const SizedBox(height: 12),
                    Text(
                      l10n.saveFailed,
                      style: context.txt.bodyMedium?.copyWith(
                        color: context.colors.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: _saving ? null : _submit,
                    child: _saving
                        ? SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.colors.onPrimary,
                            ),
                          )
                        : Text(l10n.saveChanges),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
