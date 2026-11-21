import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wsidappp/shared/widgets/wsid_button.dart';
import 'package:wsidappp/config/theme/app_colors.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/core/utils/app_motion.dart';
import 'package:wsidappp/features/categories/domain/entities/category.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_cubit.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_state.dart';
import 'package:wsidappp/features/suggestion/presentation/cubit/suggestion_cubit.dart';
import 'package:wsidappp/features/suggestion/presentation/cubit/suggestion_state.dart';
import 'package:wsidappp/features/suggestion/presentation/widgets/home_suggestion_page_widgets/cards/active_task_card.dart';
import 'package:wsidappp/features/suggestion/presentation/widgets/home_suggestion_page_widgets/cards/suggestion_decider_card.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_cubit.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_state.dart';

/// Main decider area: idle prompt, cycling card, revealed suggestion, or the
/// currently active task.
class DeciderSection extends StatefulWidget {
  const DeciderSection({super.key});

  @override
  State<DeciderSection> createState() => _DeciderSectionState();
}

class _DeciderSectionState extends State<DeciderSection> {
  static const Key _deciderCardKey = ValueKey<String>('decider-card');

  late final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(milliseconds: 1500),
  );

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _suggest(BuildContext context) {
    HapticFeedback.mediumImpact();
    context.read<SuggestionCubit>().getRandomSuggestion();
  }

  @override
  Widget build(BuildContext context) {
    final SuggestionState state = context.watch<SuggestionCubit>().state;

    final Task? activeTask = state.maybeWhen(
      hasActiveTask: (Task task) => task,
      orElse: () => null,
    );
    if (activeTask != null) return ActiveTaskCard(task: activeTask);

    final List<Task> candidates = context.select<TaskListCubit, List<Task>>(
      (TaskListCubit cubit) =>
          cubit.state.mapOrNull(
            loaded: (l) => l.tasks
                .where((Task task) => task.status == TaskStatus.pending)
                .toList(growable: false),
          ) ??
          const <Task>[],
    );
    final Map<String, String> categoryNames =
        context.select<CategoryCubit, Map<String, String>>(
      (CategoryCubit cubit) => cubit.state.maybeWhen(
        loaded: (List<Category> categories, _) => <String, String>{
          for (final Category category in categories) category.id: category.name,
        },
        orElse: () => const <String, String>{},
      ),
    );

    Widget deciderCard(Task? winner) => SuggestionDeciderCard(
          key: _deciderCardKey,
          candidates: candidates,
          winner: winner,
          categoryNames: categoryNames,
          onDoIt: (Task task) {
            HapticFeedback.lightImpact();
            context.read<SuggestionCubit>().takeTask(task.id);
          },
          onRollAgain: () => _suggest(context),
        );

    final Widget body = state.maybeWhen(
      suggesting: () => deciderCard(null),
      hasSuggestion: (Task task, _) => deciderCard(task),
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(),
      ),
      empty: (_) => _EmptyBody(onRetry: () => _suggest(context)),
      error: (String message) => _ErrorBody(
        message: message,
        onRetry: () => context.read<SuggestionCubit>().checkActiveTask(),
      ),
      orElse: () => _SuggestButton(onPressed: () => _suggest(context)),
    );

    return BlocListener<SuggestionCubit, SuggestionState>(
      listenWhen: (SuggestionState previous, SuggestionState current) {
        final bool wasSuggesting = previous.maybeWhen(
          suggesting: () => true,
          orElse: () => false,
        );
        final bool isNowSuggested = current.maybeWhen(
          hasSuggestion: (_, _) => true,
          orElse: () => false,
        );
        return wasSuggesting && isNowSuggested;
      },
      listener: (BuildContext context, SuggestionState state) {
        _confettiController.play();
      },
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const _DeciderHeading(),
              const SizedBox(height: 24),
              AnimatedSize(
                duration: AppMotion.of(context, AppMotion.medium),
                curve: AppMotion.standard,
                alignment: Alignment.topCenter,
                child: body,
              ),
            ],
          ),
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 25,
              maxBlastForce: 25,
              minBlastForce: 8,
              emissionFrequency: 0.05,
              gravity: 0.15,
              colors: const <Color>[
                AppColors.primary,
                AppColors.primaryLight,
                AppColors.primaryDark,
                AppColors.accent,
                Color(0xFF2A9D8F),
                Color(0xFFE76F51),
                Color(0xFFF4A261),
                Colors.amber,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeciderHeading extends StatelessWidget {
  const _DeciderHeading();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: <Widget>[
        Text(
          l10n.stuckInTasks,
          textAlign: TextAlign.center,
          style: context.txt.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.weWillPickTask,
          textAlign: TextAlign.center,
          style: context.txt.bodyLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: AppMotion.of(context, AppMotion.medium))
        .slideY(
          begin: 0.1,
          end: 0,
          duration: AppMotion.of(context, AppMotion.medium),
          curve: AppMotion.standard,
        );
  }
}

class _SuggestButton extends StatelessWidget {
  const _SuggestButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return WsidButton(
      onPressed: onPressed,
      label: context.l10n.suggestTask,
      size: WsidButtonSize.large,
    ).animate()
        .fadeIn(
          delay: AppMotion.of(context, AppMotion.staggerStep),
          duration: AppMotion.of(context, AppMotion.medium),
        )
        .scaleXY(
          begin: 0.92,
          end: 1,
          duration: AppMotion.of(context, AppMotion.medium),
          curve: AppMotion.emphasized,
        );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.inbox_outlined,
          size: 48,
          color: context.colors.onSurfaceVariant,
        ),
        const SizedBox(height: 12),
        Text(
          context.l10n.noPendingTasks,
          textAlign: TextAlign.center,
          style: context.txt.bodyLarge,
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: onRetry,
          child: Text(context.l10n.tryAgain),
        ),
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(Icons.error_outline, size: 48, color: context.colors.error),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: context.txt.bodyLarge?.copyWith(color: context.colors.error),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: onRetry,
          child: Text(context.l10n.retry),
        ),
      ],
    );
  }
}
