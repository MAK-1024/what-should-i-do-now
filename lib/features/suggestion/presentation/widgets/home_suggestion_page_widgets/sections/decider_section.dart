import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wsidappp/config/theme/app_colors.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/constants/app_assets.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/core/utils/app_motion.dart';
import 'package:wsidappp/features/categories/domain/entities/category.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_cubit.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_state.dart';
import 'package:wsidappp/features/suggestion/presentation/cubit/suggestion_cubit.dart';
import 'package:wsidappp/features/suggestion/presentation/cubit/suggestion_state.dart';
import 'package:wsidappp/features/suggestion/presentation/widgets/home_suggestion_page_widgets/cards/suggestion_decider_card.dart';
import 'package:wsidappp/shared/widgets/wsid_confirmation_dialog.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_cubit.dart';
import 'package:wsidappp/features/tasks/presentation/cubit/task_list_state.dart';
import 'package:wsidappp/features/tasks/presentation/task_flow_navigation.dart';
import 'package:wsidappp/shared/widgets/floating_mascot.dart';
import 'package:wsidappp/shared/widgets/mascot_state_view.dart';
import 'package:wsidappp/shared/widgets/shimmer/wsid_shimmer.dart';
import 'package:wsidappp/shared/widgets/wsid_button.dart';

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

  Future<void> _suggest(BuildContext context) async {
    // Check if an in-progress task already exists
    final Task? activeTask = context.read<TaskListCubit>().state.mapOrNull(
      loaded: (l) {
        for (final Task t in l.tasks) {
          if (t.status == TaskStatus.inProgress) return t;
        }
        return null;
      },
    );
    if (activeTask != null) {
      await HapticFeedback.heavyImpact();
      if (!context.mounted) return;
      await WsidConfirmationDialog.show(
        context,
        title: context.l10n.activeTaskLimitWarningTitle,
        message: context.l10n.activeTaskLimitWarningMessage,
        confirmLabel: context.l10n.gotIt,
        cancelLabel: null,
        mascotAsset: AppAssets.qustion,
      );
      return;
    }

    await HapticFeedback.mediumImpact();
    if (context.mounted) {
      await context.read<SuggestionCubit>().getRandomSuggestion();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final brand = context.brand;
    final SuggestionState state = context.watch<SuggestionCubit>().state;

    final List<Task> candidates = context.select<TaskListCubit, List<Task>>(
      (TaskListCubit cubit) =>
          cubit.state.mapOrNull(
            loaded: (l) => l.tasks
                .where((Task task) => task.status == TaskStatus.pending)
                .toList(growable: false),
          ) ??
          const <Task>[],
    );
    final Map<String, Category> categoriesById =
        context.select<CategoryCubit, Map<String, Category>>(
      (CategoryCubit cubit) => cubit.state.maybeWhen(
        loaded: (List<Category> categories, _) => <String, Category>{
          for (final Category category in categories) category.id: category,
        },
        orElse: () => const <String, Category>{},
      ),
    );
    final Map<String, String> categoryNames = <String, String>{
      for (final MapEntry<String, Category> entry in categoriesById.entries)
        entry.key: entry.value.name,
    };

    Widget deciderCard(Task? winner) => SuggestionDeciderCard(
          key: _deciderCardKey,
          candidates: candidates,
          winner: winner,
          categoryNames: categoryNames,
          categoriesById: categoriesById,
          onDoIt: (Task task) async {
            await HapticFeedback.lightImpact();
            if (!context.mounted) return;
            await context.read<SuggestionCubit>().takeTask(task.id);
            if (context.mounted) {
              await context.read<TaskListCubit>().loadTasks();
            }
          },
          onRollAgain: () => unawaited(_suggest(context)),
        );

    final Widget body = state.maybeWhen(
      suggesting: () => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FloatingMascot(
            child: Image.asset(
              AppAssets.choosing,
              width: 170,
              height: 170,
              fit: BoxFit.contain,
            )
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 300))
                .scaleXY(begin: 0.9, duration: const Duration(milliseconds: 300)),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.pickingForYou,
            textAlign: TextAlign.center,
            style: context.typo.h3Bold.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: context.isLightTheme
                  ? context.colors.primary
                  : brand.headlineText,
            ),
          )
              .animate()
              .fadeIn(duration: AppMotion.of(context, AppMotion.medium))
              .slideY(
                begin: 0.15,
                duration: AppMotion.of(context, AppMotion.medium),
              ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.pickingForYouSubtitle,
              textAlign: TextAlign.center,
              style: context.screenSubtitleStyle.copyWith(
                fontSize: 15,
                height: 1.45,
              ),
            ),
          )
              .animate()
              .fadeIn(duration: AppMotion.of(context, AppMotion.medium))
              .slideY(
                begin: 0.15,
                duration: AppMotion.of(context, AppMotion.medium),
              ),
          const SizedBox(height: 24),
          deciderCard(null),
        ],
      ),
      hasSuggestion: (Task task, _) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FloatingMascot(
            child: Image.asset(
              AppAssets.letsgo,
              width: 170,
              height: 170,
              fit: BoxFit.contain,
            )
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 300))
                .scaleXY(begin: 0.9, duration: const Duration(milliseconds: 300)),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.heresYourPick,
            textAlign: TextAlign.center,
            style: context.typo.h3Bold.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: context.isLightTheme
                  ? context.colors.primary
                  : brand.headlineText,
            ),
          )
              .animate()
              .fadeIn(duration: AppMotion.of(context, AppMotion.medium))
              .slideY(
                begin: 0.15,
                duration: AppMotion.of(context, AppMotion.medium),
              ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.readyToStart,
              textAlign: TextAlign.center,
              style: context.screenSubtitleStyle.copyWith(
                fontSize: 15,
                height: 1.45,
              ),
            ),
          )
              .animate()
              .fadeIn(duration: AppMotion.of(context, AppMotion.medium))
              .slideY(
                begin: 0.15,
                duration: AppMotion.of(context, AppMotion.medium),
              ),
          const SizedBox(height: 24),
          deciderCard(task),
        ],
      ),
      loading: () => const WsidShimmerDeciderCard(),
      empty: (_) => _EmptyBody(onRetry: () => _suggest(context)),
      error: (String message) => _ErrorBody(
        message: message,
        onRetry: () => context.read<SuggestionCubit>().checkActiveTask(),
      ),
      orElse: () => _IdleDeciderView(onPressed: () => _suggest(context)),
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
          AnimatedSize(
            duration: AppMotion.of(context, AppMotion.medium),
            curve: AppMotion.standard,
            alignment: Alignment.topCenter,
            child: body,
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

class _IdleDeciderView extends StatelessWidget {
  const _IdleDeciderView({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final brand = context.brand;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 20),
            FloatingMascot(
              child: Image.asset(
                AppAssets.cantDecide,
                width: 180,
                height: 175,
                fit: BoxFit.contain,
              )
                  .animate()
                  .fadeIn(duration: AppMotion.of(context, AppMotion.medium))
                  .scaleXY(
                    begin: 0.92,
                    duration: AppMotion.of(context, AppMotion.medium),
                    curve: AppMotion.emphasized,
                  ),
            ),
            const SizedBox(height: 28),
            Text(
              l10n.cantDecideTitle,
              textAlign: TextAlign.center,
              style: context.typo.h3Bold.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                color: context.isLightTheme
                    ? context.colors.primary
                    : brand.headlineText,
              ),
            )
                .animate()
                .fadeIn(duration: AppMotion.of(context, AppMotion.medium))
                .slideY(
                  begin: 0.15,
                  duration: AppMotion.of(context, AppMotion.medium),
                  curve: AppMotion.standard,
                ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.cantDecideSubtitle,
                textAlign: TextAlign.center,
                style: context.screenSubtitleStyle.copyWith(
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            )
                .animate()
                .fadeIn(duration: AppMotion.of(context, AppMotion.medium))
                .slideY(
                  begin: 0.15,
                  duration: AppMotion.of(context, AppMotion.medium),
                  curve: AppMotion.standard,
                ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: WsidButton(
                onPressed: onPressed,
                label: l10n.pickForMe,
                icon: Icons.alt_route,
                iconOnLeading: false,
                size: WsidButtonSize.large,
              ),
            )
                .animate()
                .fadeIn(
                  delay: AppMotion.of(context, AppMotion.staggerStep),
                  duration: AppMotion.of(context, AppMotion.medium),
                )
                .scaleXY(
                  begin: 0.94,
                  duration: AppMotion.of(context, AppMotion.medium),
                  curve: AppMotion.emphasized,
                ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return MascotStateView.empty(
      title: l10n.noTasksYet,
      subtitle: l10n.noTasksYetSubtitle,
      actionLabel: l10n.addATask,
      actionIcon: Icons.add,
      onAction: () => TaskFlowNavigation.openAddTask(context),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return MascotStateView.error(
      title: context.l10n.somethingWentWrong,
      subtitle: message,
      actionLabel: context.l10n.retry,
      onAction: onRetry,
    );
  }
}
