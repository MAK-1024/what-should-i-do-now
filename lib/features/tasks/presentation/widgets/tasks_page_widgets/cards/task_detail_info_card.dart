import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/features/tasks/domain/entities/task.dart';
import 'package:wsidappp/features/tasks/presentation/widgets/tasks_page_widgets/shared/task_status_badge.dart';
import 'package:wsidappp/shared/widgets/brand_surface_card.dart';

class TaskDetailInfoCard extends StatelessWidget {
  const TaskDetailInfoCard({
    super.key,
    required this.task,
    required this.localeName,
  });

  final Task task;
  final String localeName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final String created = DateFormat.yMMMd(localeName).format(task.createdAt);

    return BrandSurfaceCard(
      child: Column(
        children: <Widget>[
          _InfoRow(
            label: l10n.createdAtLabel,
            value: created,
            showDivider: true,
          ),
          _InfoRow(
            label: l10n.priority,
            value: task.priority.chipLabel(l10n),
            valueColor: task.priority.detailTint(context),
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.showDivider,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool showDivider;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
          child: Row(
            children: <Widget>[
              Text(
                label,
                style: context.isLightTheme
                    ? context.typo.body.copyWith(color: brand.mutedText)
                    : context.txt.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
              ),
              const Spacer(),
              Text(
                value,
                style: context.isLightTheme
                    ? context.typo.bodyBold.copyWith(
                        color: valueColor ?? brand.headlineText,
                      )
                    : context.txt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: valueColor ?? context.colors.onSurface,
                      ),
              ),
            ],
          ),
        ),
        if (showDivider)
          brand.groupedCardDividers
              ? const Divider(height: 1, indent: 16, endIndent: 16)
              : Divider(height: 1, thickness: 1, color: brand.divider),
      ],
    );
  }
}