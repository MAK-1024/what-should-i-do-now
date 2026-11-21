import 'package:flutter/material.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/constants/category_appearance.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/features/categories/domain/entities/category.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';
import 'package:wsidappp/features/tasks/presentation/widgets/tasks_page_widgets/shared/task_status_badge.dart';
import 'package:wsidappp/shared/widgets/brand_surface_card.dart';

class TaskDetailHeroCard extends StatelessWidget {
  const TaskDetailHeroCard({
    super.key,
    required this.task,
    required this.category,
  });

  final Task task;
  final Category? category;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final brand = context.brand;
    final CategoryColorOption color =
        CategoryAppearance.colorForHex(category?.color);
    final CategoryIconOption icon =
        CategoryAppearance.iconForKey(category?.icon);
    final int? minutes = task.estimatedDuration;

    return BrandSurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: brand.categoryIconCircle(color.iconCircleColor),
                  borderRadius: context.radius.lg,
                ),
                child: Icon(icon.icon, size: 32, color: brand.iconOnTint),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  task.title,
                  style: context.isLightTheme
                      ? context.typo.h1Bold.copyWith(
                          color: brand.headlineText,
                          fontSize: 20,
                          height: 1.5,
                        )
                      : context.txt.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              if (minutes != null)
                _DetailBadge(
                  icon: Icons.schedule_outlined,
                  label: l10n.minutesLong(minutes),
                  foreground: brand.warningAccent,
                ),
              if (category != null)
                _DetailBadge(
                  icon: icon.icon,
                  label: category!.name,
                  foreground: brand.categoryBadgeTint,
                ),
              _StatusChip(status: task.status, l10n: l10n),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailBadge extends StatelessWidget {
  const _DetailBadge({
    required this.icon,
    required this.label,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: context.radius.md,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 4),
          Text(
            label,
            style: context.isLightTheme
                ? context.typo.captionBold.copyWith(color: foreground)
                : context.txt.labelMedium!.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.l10n});

  final TaskStatus status;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final bool pendingLike =
        status == TaskStatus.pending || status == TaskStatus.archived;

    if (!context.isLightTheme) {
      return TaskStatusBadge(status: status);
    }

    final Color foreground =
        pendingLike ? brand.warningAccent : status.color(context);
    final Color background = pendingLike
        ? brand.warningSurface
        : foreground.withValues(alpha: 0.12);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: context.radius.md,
      ),
      child: Text(
        status.label(l10n).toLowerCase(),
        style: context.typo.captionBold.copyWith(color: foreground),
      ),
    );
  }
}