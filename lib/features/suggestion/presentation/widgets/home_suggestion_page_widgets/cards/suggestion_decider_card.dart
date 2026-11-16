import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/core/services/external_link_launcher.dart';
import 'package:wsidappp/core/utils/app_motion.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';
import 'package:wsidappp/shared/widgets/task_meta_row.dart';

/// Slot-machine style card: cycles through [candidates] while [winner] is
/// null, then expands to reveal the winning task with its actions.
class SuggestionDeciderCard extends StatefulWidget {
  const SuggestionDeciderCard({
    super.key,
    required this.candidates,
    required this.winner,
    required this.categoryNames,
    required this.onDoIt,
    required this.onRollAgain,
  });

  final List<Task> candidates;
  final Task? winner;
  final Map<String, String> categoryNames;
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

    return Card(
      child: AnimatedSize(
        duration: AppMotion.of(context, AppMotion.slow),
        curve: AppMotion.standard,
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: winner == null
              ? _CyclingContent(
                  task: widget.candidates.isEmpty
                      ? null
                      : widget.candidates[_tick % widget.candidates.length],
                  tick: _tick,
                )
              : _RevealedContent(
                  key: ValueKey<String>(winner.id),
                  task: winner,
                  categoryName: widget.categoryNames[winner.categoryId],
                  onDoIt: () => widget.onDoIt(winner),
                  onRollAgain: widget.onRollAgain,
                ),
        ),
      ),
    );
  }
}

class _CyclingContent extends StatelessWidget {
  const _CyclingContent({required this.task, required this.tick});

  final Task? task;
  final int tick;

  @override
  Widget build(BuildContext context) {
    final Task? current = task;

    return SizedBox(
      width: double.infinity,
      height: 72,
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
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (current.description?.isNotEmpty ?? false) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(
                      current.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: context.txt.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
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
    required this.onDoIt,
    required this.onRollAgain,
  });

  final Task task;
  final String? categoryName;
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          task.title,
          textAlign: TextAlign.center,
          style: context.txt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        if (description != null && description.isNotEmpty) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: context.txt.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 16),
        TaskMetaRow(
          categoryName: categoryName,
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
        const SizedBox(height: 20),
        Row(
          children: <Widget>[
            Expanded(
              child: FilledButton(
                onPressed: onDoIt,
                child: Text(l10n.doIt, maxLines: 1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colors.primary,
                  side: BorderSide(color: context.colors.primary),
                ),
                onPressed: onRollAgain,
                child: Text(l10n.rollAgain, maxLines: 1),
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
