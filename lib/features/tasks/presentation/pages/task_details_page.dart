import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/core/services/external_link_launcher.dart';
import 'package:wsidappp/features/categories/domain/entities/category.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_cubit.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_state.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_cubit.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_state.dart';
import 'package:wsidappp/features/tasks/presentation/pages/edit_task_page.dart';
import 'package:wsidappp/features/tasks/presentation/widgets/tasks_page_widgets/cards/task_detail_hero_card.dart';
import 'package:wsidappp/features/tasks/presentation/widgets/tasks_page_widgets/cards/task_detail_info_card.dart';
import 'package:wsidappp/features/tasks/presentation/widgets/tasks_page_widgets/cards/task_link_preview_card.dart';
import 'package:wsidappp/shared/widgets/brand_surface_card.dart';
import 'package:wsidappp/shared/widgets/custom_app_bar.dart';

/// Task details (`333:1716`).
class TaskDetailsPage extends StatelessWidget {
  const TaskDetailsPage({super.key, required this.task});

  final Task task;

  Category? _category(CategoryState state) => state.maybeWhen(
        loaded: (List<Category> categories, _) {
          for (final Category item in categories) {
            if (item.id == task.categoryId) return item;
          }
          return null;
        },
        orElse: () => null,
      );

  Future<void> _openEdit(BuildContext context, Task current) async {
    await Navigator.of(context).push<Task?>(
      MaterialPageRoute<Task?>(
        builder: (_) => BlocProvider<TaskListCubit>.value(
          value: context.read<TaskListCubit>(),
          child: EditTaskPage(task: current),
        ),
      ),
    );
    if (!context.mounted) return;
    final bool exists =
        context.read<TaskListCubit>().state.taskById(current.id) != null;
    if (!exists) Navigator.of(context).pop();
  }

  Future<void> _openLink(BuildContext context, String url) async {
    if (!await openExternalLink(url)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.couldNotOpenLink),
          backgroundColor: context.colors.error,
        ),
      );
    }
  }

  Future<void> _startTimer(BuildContext context, Task current) async {
    await context.read<TaskListCubit>().changeTaskStatus(
          current,
          TaskStatus.inProgress,
        );
  }

  Future<void> _markDone(BuildContext context, Task current) async {
    final TaskListCubit cubit = context.read<TaskListCubit>();
    if (current.status == TaskStatus.pending ||
        current.status == TaskStatus.archived) {
      final bool started = await cubit.changeTaskStatus(
        current,
        TaskStatus.inProgress,
      );
      if (!started) return;
      final Task? updated = cubit.state.taskById(current.id);
      if (updated == null) return;
      await cubit.changeTaskStatus(updated, TaskStatus.completed);
      return;
    }
    if (current.status == TaskStatus.inProgress) {
      await cubit.changeTaskStatus(current, TaskStatus.completed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final brand = context.brand;
    final String localeName = Localizations.localeOf(context).toString();

    return Scaffold(
      backgroundColor: context.brand.pageBackground,
      appBar: CustomAppBar(
        title: l10n.screenTaskDetails,
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      bottomNavigationBar: BlocBuilder<TaskListCubit, TaskListState>(
        builder: (BuildContext context, TaskListState state) {
          final Task current = state.taskById(task.id) ?? task;
          final bool completed = current.status == TaskStatus.completed;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: completed
                            ? null
                            : () => _startTimer(context, current),
                        style: FilledButton.styleFrom(
                          backgroundColor: brand.primaryAction,
                          foregroundColor: brand.onPrimaryAction,
                          shape: RoundedRectangleBorder(
                            borderRadius: context.radius.lg,
                          ),
                          textStyle: context.typo.title1Bold,
                        ),
                        child: Text(l10n.startTimer),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: completed
                            ? null
                            : () => _markDone(context, current),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: brand.primaryAction,
                          side: BorderSide(color: brand.primaryAction),
                          shape: RoundedRectangleBorder(
                            borderRadius: context.radius.lg,
                          ),
                          textStyle: context.typo.title1Bold,
                        ),
                        child: Text(l10n.markDone),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      body: BlocBuilder<TaskListCubit, TaskListState>(
        builder: (BuildContext context, TaskListState state) {
          final Task current = state.taskById(task.id) ?? task;
          final String? notes = current.description;
          final String? link = current.link;

          return BlocBuilder<CategoryCubit, CategoryState>(
            builder: (BuildContext context, CategoryState categoryState) {
              final Category? category = _category(categoryState);

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: <Widget>[
                  TaskDetailHeroCard(task: current, category: category),
                  if (notes != null && notes.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 16),
                    Text(
                      context.sectionHeaderLabel(l10n.notesSection),
                      style: context.sectionHeaderStyle(),
                    ),
                    const SizedBox(height: 10),
                    _NotesCard(text: notes),
                  ],
                  if (link != null && link.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 16),
                    Text(
                      context.sectionHeaderLabel(l10n.linkSection),
                      style: context.sectionHeaderStyle(),
                    ),
                    const SizedBox(height: 10),
                    TaskLinkPreviewCard(
                      url: link,
                      onTap: () => _openLink(context, link),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    context.sectionHeaderLabel(l10n.taskDetailsSection),
                    style: context.sectionHeaderStyle(),
                  ),
                  const SizedBox(height: 10),
                  TaskDetailInfoCard(task: current, localeName: localeName),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => _openEdit(context, current),
                      icon: const Icon(Icons.edit_outlined),
                      label: Text(l10n.editTask),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return BrandSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Text(
        text,
        style: context.isLightTheme
            ? context.typo.body.copyWith(color: brand.bodyText, height: 1.4)
            : context.txt.bodyMedium,
      ),
    );
  }
}