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

/// Bottom sheet dialog for creating a new backlog task.
class CreateTaskSheet extends StatefulWidget {
  const CreateTaskSheet({
    super.key,
    required this.taskListCubit,
    required this.categoryCubit,
  });

  final TaskListCubit taskListCubit;
  final CategoryCubit categoryCubit;

  static Future<void> show(
    BuildContext context, {
    required TaskListCubit taskListCubit,
    required CategoryCubit categoryCubit,
  }) {
    final topRadius = context.radius.lg.topLeft;
    return showModalBottomSheet<void>(
      context: context,
      constraints: const BoxConstraints(maxWidth: 600),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: topRadius),
      ),
      builder: (_) => CreateTaskSheet(
        taskListCubit: taskListCubit,
        categoryCubit: categoryCubit,
      ),
    );
  }

  @override
  State<CreateTaskSheet> createState() => _CreateTaskSheetState();
}

class _CreateTaskSheetState extends State<CreateTaskSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  String? _selectedCategoryId;
  TaskPriority _selectedPriority = TaskPriority.medium;

  @override
  void initState() {
    super.initState();
    final categories = widget.categoryCubit.state.maybeWhen(
      loaded: (List<Category> cats, Category? selected) => cats,
      orElse: () => <Category>[],
    );
    if (categories.isNotEmpty) {
      _selectedCategoryId = categories.first.id;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) return;

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final durationText = _durationController.text.trim();
    final link = _linkController.text.trim();

    final int? duration =
        durationText.isNotEmpty ? int.tryParse(durationText) : null;

    widget.taskListCubit.createTask(
      categoryId: _selectedCategoryId!,
      title: title,
      description: description.isNotEmpty ? description : null,
      priority: _selectedPriority,
      estimatedDuration: duration,
      link: link.isNotEmpty ? link : null,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mediaQuery = MediaQuery.of(context);

    return BlocBuilder<CategoryCubit, CategoryState>(
      bloc: widget.categoryCubit,
      builder: (BuildContext context, CategoryState categoryState) {
        final categories = categoryState.maybeWhen(
          loaded: (List<Category> cats, _) => cats,
          orElse: () => <Category>[],
        );

        if (categories.isEmpty) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              top: 24.0,
              bottom: mediaQuery.viewInsets.bottom + 32.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 48,
                  color: AppColors.accent,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.noCategoriesAvailable,
                  style: context.txt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.createCategoryFirst,
                  textAlign: TextAlign.center,
                  style: context.txt.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.gotIt),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 20.0,
            bottom: mediaQuery.viewInsets.bottom + 24.0,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16.0),
                      decoration: BoxDecoration(
                        color: AppColors.outline,
                        borderRadius: context.radius.full,
                      ),
                    ),
                  ),
                  Text(
                    l10n.addNewTask,
                    style: context.txt.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title Field
                  TextFormField(
                    controller: _titleController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: '${l10n.taskTitle} *',
                      hintText: l10n.taskTitleHint,
                    ),
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.taskTitleRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategoryId ?? categories.first.id,
                    decoration: InputDecoration(
                      labelText: '${l10n.category} *',
                    ),
                    items: categories.map((Category cat) {
                      final catColor = AppColors.parseHexColor(cat.color);
                      return DropdownMenuItem<String>(
                        value: cat.id,
                        child: Row(
                          children: <Widget>[
                            if (catColor != null) ...<Widget>[
                              CircleAvatar(
                                radius: 5,
                                backgroundColor: catColor,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(cat.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Priority Selector
                  Text(
                    l10n.priority,
                    style: context.txt.labelLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: TaskPriority.values.map((TaskPriority p) {
                      final isSelected = _selectedPriority == p;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(p.label(l10n)),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            if (selected) {
                              setState(() {
                                _selectedPriority = p;
                              });
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: context.radius.full,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Estimated Duration & Link Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          controller: _durationController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.estimatedMinutes,
                            hintText: l10n.minutesHint,
                          ),
                          validator: (String? value) {
                            if (value != null && value.trim().isNotEmpty) {
                              final parsed = int.tryParse(value.trim());
                              if (parsed == null || parsed <= 0) {
                                return l10n.positiveNumber;
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _linkController,
                          keyboardType: TextInputType.url,
                          decoration: InputDecoration(
                            labelText: l10n.link,
                            hintText: l10n.urlHint,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description Field
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: l10n.descriptionOptional,
                      hintText: l10n.descriptionHint,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  FilledButton(
                    onPressed: _submit,
                    child: Text(l10n.addTask),
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
