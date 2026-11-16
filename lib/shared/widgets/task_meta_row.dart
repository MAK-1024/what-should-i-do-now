import 'package:flutter/material.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';

/// Category (sage green) and estimated-duration (amber) metadata for a task.
class TaskMetaRow extends StatelessWidget {
  const TaskMetaRow({
    super.key,
    required this.categoryName,
    required this.estimatedMinutes,
    this.alignment = WrapAlignment.center,
  });

  final String? categoryName;
  final int? estimatedMinutes;
  final WrapAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final int? minutes = estimatedMinutes;

    return Wrap(
      alignment: alignment,
      spacing: 16,
      runSpacing: 8,
      children: <Widget>[
        _MetaChip(
          icon: Icons.folder_outlined,
          label: categoryName ?? context.l10n.uncategorized,
          color: context.colors.primary,
        ),
        if (minutes != null)
          _MetaChip(
            icon: Icons.schedule_outlined,
            label: context.l10n.minutesLong(minutes),
            color: context.colors.tertiary,
          ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: context.txt.labelLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
