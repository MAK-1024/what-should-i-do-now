import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/constants/category_appearance.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/core/services/external_link_launcher.dart';
import 'package:wsidappp/core/utils/app_motion.dart';
import 'package:wsidappp/features/categories/domain/entities/category.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';
import 'package:wsidappp/shared/widgets/task_meta_row.dart';
import 'package:wsidappp/shared/widgets/wsid_button.dart';

/// Slot-machine style card: cycles through [candidates] while [winner] is
/// null, then expands to reveal the winning task with its actions.
class SuggestionDeciderCard extends StatefulWidget {
  const SuggestionDeciderCard({
    super.key,
    required this.candidates,
    required this.winner,
    this.categoryNames = const <String, String>{},
    this.categoriesById = const <String, Category>{},
    required this.onDoIt,
    required this.onRollAgain,
  });

  final List<Task> candidates;
  final Task? winner;
  final Map<String, String> categoryNames;
  final Map<String, Category> categoriesById;
  final ValueChanged<Task> onDoIt;
  final VoidCallback onRollAgain;

  @override
  State<SuggestionDeciderCard> createState() => _SuggestionDeciderCardState();
}

class _SuggestionDeciderCardState extends State<SuggestionDeciderCard> {
  final Random _random = Random();
  Timer? _cycleTimer;
  int _tick = 0;
  int _currentDelayMs = 50;

  bool get _isCycling => widget.winner == null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTimer();
  }

  @override
  void didUpdateWidget(SuggestionDeciderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.winner == null && widget.winner != null) {
      _cycleTimer?.cancel();
      _cycleTimer = null;
      HapticFeedback.heavyImpact();
    } else if (oldWidget.winner != null && widget.winner == null) {
      _currentDelayMs = 50;
      if (widget.candidates.isNotEmpty) {
        _tick = _random.nextInt(widget.candidates.length);
      }
      _scheduleNextTick();
    } else {
      _syncTimer();
    }
  }

  @override
  void dispose() {
    _cycleTimer?.cancel();
    super.dispose();
  }

  void _syncTimer() {
    final bool shouldCycle = _isCycling &&
        widget.candidates.isNotEmpty &&
        AppMotion.isEnabled(context);
    if (shouldCycle && _cycleTimer == null) {
      if (_tick == 0 && widget.candidates.isNotEmpty) {
        _tick = _random.nextInt(widget.candidates.length);
      }
      _scheduleNextTick();
    } else if (!shouldCycle && _cycleTimer != null) {
      _cycleTimer?.cancel();
      _cycleTimer = null;
    }
  }

  void _scheduleNextTick() {
    _cycleTimer?.cancel();
    if (!_isCycling ||
        !mounted ||
        widget.candidates.isEmpty ||
        !AppMotion.isEnabled(context)) {
      return;
    }
    _cycleTimer = Timer(Duration(milliseconds: _currentDelayMs), _onTick);
  }

  void _onTick() {
    if (!mounted || !_isCycling) return;
    HapticFeedback.lightImpact();
    setState(() {
      _tick++;
      _currentDelayMs = min(400, (_currentDelayMs * 1.25).round());
    });
    _scheduleNextTick();
  }

  @override
  Widget build(BuildContext context) {
    final Task? winner = widget.winner;

    final Task? currentTask = widget.candidates.isEmpty
        ? null
        : widget.candidates[_tick % widget.candidates.length];
    final Category? currentCat = currentTask != null
        ? widget.categoriesById[currentTask.categoryId]
        : null;
    final String? currentCategory = currentCat?.name ??
        (currentTask != null ? widget.categoryNames[currentTask.categoryId] : null);

    final Category? winnerCategory = winner != null
        ? widget.categoriesById[winner.categoryId]
        : null;
    final IconData? winnerIcon = winnerCategory != null
        ? CategoryAppearance.iconForKey(winnerCategory.icon).icon
        : null;
    final Color? winnerColor = winnerCategory != null
        ? CategoryAppearance.colorForHex(winnerCategory.color).iconCircleColor
        : null;
    final String? winnerCategoryName = winnerCategory?.name ??
        (winner != null ? widget.categoryNames[winner.categoryId] : null);

    return Card(
      elevation: 0,
      color: context.isLightTheme ? Colors.white : context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: context.isLightTheme
              ? const Color(0xFFE5E9EB)
              : context.colors.outlineVariant,
        ),
      ),
      child: AnimatedSize(
        duration: AppMotion.of(context, AppMotion.slow),
        curve: AppMotion.standard,
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          child: winner == null
              ? _CyclingContent(
                  task: currentTask,
                  tick: _tick,
                  categoryName: currentCategory,
                )
              : _RevealedContent(
                  key: ValueKey<String>(winner.id),
                  task: winner,
                  categoryName: winnerCategoryName,
                  categoryIcon: winnerIcon,
                  categoryColor: winnerColor,
                  onDoIt: () => widget.onDoIt(winner),
                  onRollAgain: widget.onRollAgain,
                ),
        ),
      ),
    );
  }
}

class _CyclingContent extends StatelessWidget {
  const _CyclingContent({
    required this.task,
    required this.tick,
    this.categoryName,
  });

  final Task? task;
  final int tick;
  final String? categoryName;

  @override
  Widget build(BuildContext context) {
    final Task? current = task;
    final l10n = context.l10n;

    final String subtitleText = current?.description?.isNotEmpty == true
        ? current!.description!
        : (categoryName?.isNotEmpty == true
            ? categoryName!
            : l10n.taskDescription);

    return SizedBox(
      width: double.infinity,
      height: 76,
      child: ClipRect(
        child: current == null
            ? Icon(
                Icons.shuffle_rounded,
                size: 32,
                color: context.colors.primary,
              )
                .animate(onPlay: (controller) => controller.repeat())
                .shake(duration: AppMotion.of(context, AppMotion.slow))
            : Column(
                key: ValueKey<int>(tick),
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    current.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: context.txt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: context.isLightTheme
                          ? const Color(0xFF1E293B)
                          : context.colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitleText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: context.txt.bodyMedium?.copyWith(
                      color: context.isLightTheme
                          ? const Color(0xFF64748B)
                          : context.colors.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ],
              )
                .animate(key: ValueKey<int>(tick))
                .fadeIn(duration: 80.ms)
                .slideY(
                  begin: 0.6,
                  end: 0,
                  duration: 120.ms,
                  curve: Curves.easeOutQuad,
                )
                .blurY(
                  begin: 3.0,
                  end: 0,
                  duration: 120.ms,
                  curve: Curves.easeOutQuad,
                ),
      ),
    );
  }
}

class _RevealedContent extends StatelessWidget {
  const _RevealedContent({
    super.key,
    required this.task,
    required this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    required this.onDoIt,
    required this.onRollAgain,
  });

  final Task task;
  final String? categoryName;
  final IconData? categoryIcon;
  final Color? categoryColor;
  final VoidCallback onDoIt;
  final VoidCallback onRollAgain;

  Future<void> _openLink(BuildContext context, String url) async {
    final messenger = ScaffoldMessenger.of(context);
    final errorText = context.l10n.couldNotOpenLink;
    final errorColor = context.colors.error;
    if (!await openExternalLink(url)) {
      messenger.showSnackBar(
        SnackBar(content: Text(errorText), backgroundColor: errorColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final String? description = task.description;
    final String? link = task.link;
    final String subtitleText = description?.isNotEmpty == true
        ? description!
        : l10n.taskDescription;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          task.title,
          textAlign: TextAlign.center,
          style: context.txt.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: context.isLightTheme
                ? const Color(0xFF1E293B)
                : context.colors.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitleText,
          textAlign: TextAlign.center,
          style: context.txt.bodyMedium?.copyWith(
            color: context.isLightTheme
                ? const Color(0xFF64748B)
                : context.colors.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        TaskMetaRow(
          categoryName: categoryName,
          categoryIcon: categoryIcon,
          categoryColor: categoryColor,
          estimatedMinutes: task.estimatedDuration,
        ),
        if (link != null && link.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          TextButton.icon(
            icon: const Icon(Icons.open_in_new, size: 18),
            label: Text(l10n.openLink),
            onPressed: () => _openLink(context, link),
          ),
        ],
        const SizedBox(height: 24),
        Row(
          children: <Widget>[
            Expanded(
              child: WsidButton(
                onPressed: onDoIt,
                label: l10n.startNow,
                icon: Icons.sentiment_satisfied_alt,
                iconOnLeading: false,
                variant: WsidButtonVariant.primary,
                size: WsidButtonSize.medium,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: WsidButton(
                onPressed: onRollAgain,
                label: l10n.pickAnother,
                icon: Icons.sync_rounded,
                iconOnLeading: false,
                variant: WsidButtonVariant.outlined,
                size: WsidButtonSize.medium,
              ),
            ),
          ],
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 250.ms)
        .scale(
          begin: const Offset(0.75, 0.75),
          end: const Offset(1.0, 1.0),
          curve: Curves.elasticOut,
          duration: 800.ms,
        )
        .shake(
          hz: 3,
          offset: const Offset(2, 2),
          duration: 400.ms,
        );
  }
}
