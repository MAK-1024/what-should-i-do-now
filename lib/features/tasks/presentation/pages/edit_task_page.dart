import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_cubit.dart';
import 'package:wsidappp/features/tasks/presentation/widgets/tasks_page_widgets/sections/task_form_body.dart';
import 'package:wsidappp/shared/widgets/custom_app_bar.dart';

/// Full-screen edit task form (`446:3056`).
class EditTaskPage extends StatefulWidget {
  const EditTaskPage({super.key, required this.task});

  final Task task;

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController =
      TextEditingController(text: widget.task.title);
  late final TextEditingController _notesController =
      TextEditingController(text: widget.task.description ?? '');
  late final TextEditingController _linkController =
      TextEditingController(text: widget.task.link ?? '');

  late String _categoryId = widget.task.categoryId;
  late TaskPriority _priority = widget.task.priority;
  late int? _durationMinutes = widget.task.estimatedDuration;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  String? _nullIfBlank(String value) {
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final TaskListCubit cubit = context.read<TaskListCubit>();
    final Task updated = widget.task.copyWith(
      title: _titleController.text.trim(),
      categoryId: _categoryId,
      priority: _priority,
      estimatedDuration: _durationMinutes,
      link: _nullIfBlank(_linkController.text),
      description: _nullIfBlank(_notesController.text),
    );
    final bool ok = await cubit.updateTask(updated);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (ok) Navigator.of(context).pop(updated);
  }

  Future<void> _confirmDelete() async {
    final l10n = context.l10n;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: dialogContext.radius.lg),
          title: Text(l10n.deleteTask),
          content: Text(l10n.deleteTaskConfirm(widget.task.title)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: dialogContext.colors.error,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;
    final bool ok = await context.read<TaskListCubit>().deleteTask(widget.task.id);
    if (!mounted) return;
    if (ok) Navigator.of(context).pop<Task>(null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: context.brand.pageBackground,
      appBar: CustomAppBar(
        title: l10n.screenEditTask,
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Row(
            children: <Widget>[
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: context.brand.primaryAction,
                      foregroundColor: context.brand.onPrimaryAction,
                      shape: RoundedRectangleBorder(
                        borderRadius: context.radius.lg,
                      ),
                      textStyle: context.typo.title1Bold,
                    ),
                    child: _isSaving
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.brand.onPrimaryAction,
                            ),
                          )
                        : Text(l10n.saveChanges),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _isSaving ? null : _confirmDelete,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.brand.destructiveText,
                      side: BorderSide(color: context.brand.destructiveBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: context.radius.lg,
                      ),
                      textStyle: context.typo.title1Bold,
                    ),
                    child: Text(l10n.deleteTaskAction),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: <Widget>[
            TaskFormBody(
              titleController: _titleController,
              notesController: _notesController,
              linkController: _linkController,
              selectedCategoryId: _categoryId,
              selectedPriority: _priority,
              selectedDurationMinutes: _durationMinutes,
              showLinkClear: true,
              onLinkClear: () => setState(() => _linkController.clear()),
              onCategorySelected: (String id) => setState(() => _categoryId = id),
              onPrioritySelected: (TaskPriority value) =>
                  setState(() => _priority = value),
              onDurationSelected: (int? minutes) =>
                  setState(() => _durationMinutes = minutes),
              titleValidator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.taskTitleRequired;
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}