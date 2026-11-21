import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/features/categories/domain/entities/category.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_cubit.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_state.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_cubit.dart';
import 'package:wsidappp/features/tasks/presentation/widgets/tasks_page_widgets/sections/task_form_body.dart';
import 'package:wsidappp/shared/widgets/custom_app_bar.dart';

/// Full-screen create task form (`333:1834`).
class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  String? _categoryId;
  TaskPriority _priority = TaskPriority.low;
  int? _durationMinutes = 20;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final List<Category> categories =
        context.read<CategoryCubit>().state.maybeWhen(
              loaded: (List<Category> items, _) => items,
              orElse: () => const <Category>[],
            );
    if (categories.isNotEmpty) _categoryId = categories.first.id;
  }

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
    final String? categoryId = _categoryId;
    if (categoryId == null) return;

    setState(() => _isSaving = true);
    final TaskListCubit cubit = context.read<TaskListCubit>();
    final bool ok = await cubit.createTask(
      categoryId: categoryId,
      title: _titleController.text.trim(),
      description: _nullIfBlank(_notesController.text),
      priority: _priority,
      estimatedDuration: _durationMinutes,
      link: _nullIfBlank(_linkController.text),
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (ok) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: context.brand.pageBackground,
      appBar: WsidAppBar.sub(
        title: l10n.screenAddTask,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: SizedBox(
            height: 48,
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSaving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: context.brand.primaryAction,
                foregroundColor: context.brand.onPrimaryAction,
                shape: RoundedRectangleBorder(borderRadius: context.radius.lg),
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
                  : Text(l10n.saveTask),
            ),
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